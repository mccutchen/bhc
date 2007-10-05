<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
    exclude-result-prefixes="xs utils fn">

    <!-- $Id$
         The print output transformer.  This XSLT file generates a set
         of plain text files embedded with Quark XPress Tags.  The
         text files can be imported into Quark XPress, which should
         correctly style the imported text based on the XPress Tags
         therein. -->

	<!--=====================================================================
		Setup
		======================================================================-->
	<xsl:output method="text" encoding="us-ascii" indent="no" />
	<xsl:strip-space elements="*" />
	<xsl:include href="output-utils.xsl" />
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="output-type" as="xs:string" select="'print'" />
	<xsl:variable name="ext"         as="xs:string" select="'txt'"   />
	
	
	<!--=====================================================================
		Start transformation
		======================================================================-->
	
    <!-- for each term, make a new result document -->
    <xsl:template match="//term">
        
        <!-- set up result document -->
    	<xsl:variable name="dir"  select="concat(utils:generate-outdir(@year, @semester), '_', $output-type)"         as="xs:string" />
    	<xsl:variable name="file" select="if (@name != '') then utils:make-url(@name) else utils:make-url(@semester)" as="xs:string" />
    	
        <xsl:result-document href="{$dir}/{$file}.{$ext}">
            <xsl:call-template name="quark-preamble" />
            
            <!-- if multiple terms, output extra info -->
        	<xsl:if test="count(//term) &gt; 1">
                <xsl:value-of select="fn:xtag('Term Header')" /><xsl:value-of select="@name" /><xsl:call-template name="br" />
                <xsl:value-of select="fn:xtag('Term Dates')" /><xsl:value-of select="@dates" /><xsl:call-template name="br" />
            </xsl:if>
            
            <!-- continue transformation -->
            <xsl:apply-templates select="." mode="output" />
        </xsl:result-document>
    </xsl:template>
    
    
	<!--=====================================================================
		Process data
		======================================================================-->
	
	<!-- process terms -->
    <xsl:template match="term" mode="output">
        <!-- first, output everything that's not in the School of the Arts or Senior Adult Education -->
        <xsl:apply-templates select="division[@name != 'School of the Arts' and @name != 'Senior Adult Education Office']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- let it breathe! -->
        <xsl:call-template name="breather" />

        <!-- output School of the Arts -->
        <xsl:apply-templates select="division[@name = 'School of the Arts']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- let it breathe! -->
        <xsl:call-template name="breather" />

        <!-- output the Senior Adult courses -->
        <xsl:apply-templates select="division[@name = 'Senior Adult Education Office']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
    </xsl:template>

	<!-- process subjects -->
    <xsl:template match="subject">
        <xsl:apply-templates select="@name" />

        <!-- print the division information -->
        <xsl:call-template name="division-info" />

        <xsl:apply-templates select="comments" />

        <!-- insert a list of the Core courses -->
        <xsl:call-template name="make-core-list" />

        <!-- if this is the Senior Adults subject, manually add a 'credit courses' topic header -->
        <xsl:if test="@name = 'Senior Adult Education Program'">
            <xsl:value-of select="fn:xtag('Topic Header')" />
            <xsl:text>CREDIT COURSES</xsl:text>
            <xsl:call-template name="br" />
        </xsl:if>

        <!-- Output any stand-alone types before subgroups. This allows some special retroupings
             to have courses that aren't in a subgroup (topic, etc.) and courses that are in a 
             subgroup.  See, e.g. EMS courses. -->
        <xsl:apply-templates select="type">
            <xsl:sort select="@sortkey" data-type="number" />
        </xsl:apply-templates>

        <xsl:apply-templates select="topic">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- each subject section should be followed by three blank lines -->
        <xsl:call-template name="blank-line" />
        <xsl:call-template name="blank-line" />
        <xsl:call-template name="blank-line" />
    </xsl:template>

	<!-- process topics -->
    <xsl:template match="topic">
        <xsl:apply-templates select="@name" />
        <xsl:apply-templates select="comments" />

    	<!-- Output any stand-alone types before subgroups. This allows some special retroupings
    		to have courses that aren't in a subgroup (topic, etc.) and courses that are in a 
    		subgroup.  See, e.g. EMS courses. -->
    	<xsl:apply-templates select="type">
    		<xsl:sort select="@sortkey" data-type="number" />
        </xsl:apply-templates>

        <xsl:apply-templates select="subtopic">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@name" />
        </xsl:apply-templates>

    	<!-- each topic section should be followed by one blank line -->
    	<xsl:if test="position() != last()">
            <xsl:call-template name="blank-line" />
        </xsl:if>
    </xsl:template>

	<!-- process subtopics -->
    <xsl:template match="subtopic">
        <xsl:apply-templates select="@name" />
        <xsl:apply-templates select="comments" />

		<!-- subtopics are the lowest level of subgroup, so output types -->
        <xsl:apply-templates select="type">
        	<xsl:sort select="@sortkey" data-type="number" />
        </xsl:apply-templates>

    	<!-- each subtopic section should be followed by one blank line -->
        <xsl:if test="position() != last()">
            <xsl:call-template name="blank-line" />
        </xsl:if>
    </xsl:template>
	
	<!-- format the names of subjects, topics, and subtopics -->
    <xsl:template match="subject/@name | topic/@name | subtopic/@name">
    	<xsl:variable name="style-name"
    		select="concat(upper-case(substring(../local-name(), 1,1)), lower-case(substring(../local-name(), 2)), ' Header')" />
        <xsl:value-of select="fn:xtag($style-name)" />
        <xsl:value-of select="upper-case(.)" />
        <xsl:call-template name="br" />
    </xsl:template>

	<!-- process types -->
    <xsl:template match="type">
        <xsl:apply-templates select="@name" />

    	<xsl:apply-templates select="course">
    		<xsl:sort select="@sortkey" data-type="number" />
    		<xsl:sort select="@rubric"  data-type="text"   />
    		<xsl:sort select="@number"  data-type="number" />
    		<xsl:sort select="min(descendant::class/@section)" />
    	</xsl:apply-templates>
    	
    	<!-- each type section should be followed by one blank line -->
        <xsl:if test="position() != last()">
            <xsl:call-template name="blank-line" />
        </xsl:if>
    </xsl:template>

	<!-- format the names of types -->
    <xsl:template match="type/@name">
        <!-- only output the type header if we're not in a special-section with the same name -->
        <xsl:if test="normalize-space(.) != normalize-space(ancestor::special-section[1]/@name)">
            <xsl:value-of select="fn:xtag('Type Header')" /><xsl:value-of select="." /> Courses<xsl:call-template name="br" />
        </xsl:if>
    </xsl:template>

	<!-- process courses -->
	<xsl:template match="course">
        <xsl:apply-templates select="class">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@sortkey-days" data-type="number" />
            <xsl:sort select="@sortkey-date" data-type="number" />
			<xsl:sort select="@sortkey-time" data-type="number" order="ascending" />
            <xsl:sort select="@section" />
        </xsl:apply-templates>

        <xsl:apply-templates select="comments" />

        <!-- only add a blank line after the comments if this is not the
             last course and if this isn't part of a <group> -->
        <xsl:if test="(position() != last()) and not(following-sibling::course/@number = self::course/@number)">
            <xsl:call-template name="blank-line" />
        </xsl:if>
    </xsl:template>

	<!-- don't display classes with topic codes of XX or ZZ -->
	<xsl:template match="class[@topic-code = ('XX','ZZ')]" />
	<!-- process classes -->
	<xsl:template match="class">
        <xsl:variable name="type" select="ancestor::type/@name" as="xs:string" />
        <xsl:variable name="main-style-name" as="xs:string">
            <!-- this should define the possible different class-type styles -->
            <xsl:choose>
                <xsl:when test="$type = 'Night' or $type = 'Flex - Night' or $type = 'Fast Track Night'">Night</xsl:when>
                <xsl:when test="$type = 'Distance Learning'">Distance Learning</xsl:when>
                <xsl:otherwise>Normal</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="style-name">
            <!-- prepend Core to the style name if it's a Core Course -->
            <xsl:choose>
                <xsl:when test="parent::course/@core-name and parent::course/@core-name != ''">
                	<xsl:value-of select="concat('Core ',$main-style-name)" />
                </xsl:when>
                <xsl:otherwise>
                	<xsl:value-of select="$main-style-name" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="fn:xtag(concat($style-name, ' Class'))" />

        <!-- the class number is a composite of the course's @rubric and @number and the class's @section -->
        <xsl:value-of select="../@rubric" /><xsl:text> </xsl:text>
        <xsl:value-of select="../@number" /><xsl:text>-</xsl:text>
        <xsl:value-of select="@section" /><xsl:call-template name="sep" />

        <xsl:value-of select="../@title-short" /><xsl:call-template name="sep" />
        <xsl:value-of select="@synonym" /><xsl:call-template name="sep" />
        <xsl:value-of select="../@credit-hours" /><xsl:call-template name="sep" />
        <xsl:value-of select="utils:format-dates(@date-start, @date-end)" />
		<xsl:apply-templates select="@weeks" /><xsl:call-template name="br" />
		<!-- classes do not have this information
			<xsl:apply-templates select="@days" /><xsl:call-template name="sep" />
			<xsl:value-of select="utils:format-times(@time-start, @time-end)" /><xsl:text> / </xsl:text>
			<xsl:value-of select="@method" /><xsl:call-template name="sep" />
			<xsl:value-of select="@room" /><xsl:call-template name="sep" />
			<xsl:value-of select="@faculty-name" /><xsl:call-template name="br" />
		-->
		
        <xsl:apply-templates select="meeting">
            <xsl:sort select="@sortkey" />
        </xsl:apply-templates>
    </xsl:template>

	<!-- format class attributes -->
    <xsl:template match="class/@weeks">
        <xsl:value-of select="concat(' (', ., ' Wks)')" />
    </xsl:template>

    <xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@weeks" priority="1">
        <!-- don't output the number of weeks for Senior Adult courses -->
    </xsl:template>

	<!-- process meetings (normal / extra) -->
    <xsl:template match="meeting[@method = ('LEC','')]">
        <xsl:value-of select="@days" /><xsl:call-template name="sep" />
    	<xsl:value-of select="utils:format-times(@time-start, @time-end)" />
    	<xsl:text> / </xsl:text>
    	<xsl:value-of select="@method" /><xsl:call-template name="sep" />
        <xsl:value-of select="@room" /><xsl:call-template name="sep" />
    	<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:call-template name="br" />
    </xsl:template>

	<xsl:template match="meeting[@method = 'INET']">
		<xsl:value-of select="'NA'" /><xsl:call-template name="sep" />
		<xsl:value-of select="concat('NA / ', parent::class/@topic-code)" /><xsl:call-template name="sep" />
		<xsl:value-of select="'OL'" /><xsl:call-template name="sep" />
		<xsl:value-of select="''" /><xsl:call-template name="sep" />
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:call-template name="br" />
	</xsl:template>
	
	<xsl:template match="meeting[@method = 'COOP']">
		<xsl:value-of select="fn:xtag('Extra Class')" />
		<xsl:value-of select="@method" /><xsl:call-template name="sep" />
		<xsl:value-of select="'NA'" /><xsl:call-template name="sep" />
		<xsl:choose>
			<xsl:when test="@room = 'INET'">
				<xsl:value-of select="'NA'" /><xsl:call-template name="sep" />
				<xsl:value-of select="'OL'" /><xsl:call-template name="sep" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@days" /><xsl:call-template name="sep" />
				<xsl:value-of select="@room" /><xsl:call-template name="sep" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:call-template name="br" />
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:value-of select="fn:xtag('Extra Class')" />
		<xsl:value-of select="@method" /><xsl:call-template name="sep" />
		<xsl:value-of select="if (@time-start != '' and @time-end != '') then utils:format-times(@time-start, @time-end) else 'TBA'" /><xsl:call-template name="sep" />
		<xsl:choose>
			<xsl:when test="@room = 'INET'">
				<xsl:value-of select="'TBA'" /><xsl:call-template name="sep" />
				<xsl:value-of select="'OL'" /><xsl:call-template name="sep" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@days" /><xsl:call-template name="sep" />
				<xsl:value-of select="@room" /><xsl:call-template name="sep" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:call-template name="br" />
	</xsl:template>
	
	<!-- format meeting attributes -->
	<xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@days">
		<!-- spell out the days of the week for Senior Adult courses -->
		<xsl:value-of select="utils:senior-adult-days(.)" />
	</xsl:template>
	
	
	<!--=====================================================================
		Format Comments and Comments Sub-Elements
		
		<comments> elements are allowed to have a small subset of
		HTML elements as children, in addition to the special
		elements <url> and <email>.  The set of HTML elements allowed
		in <comments> elements is:
		
		* h1, p, b, i, table, tr, td
		
		The following templates handle the proper Quark XPress Tag
		generation for the <comments> element and its children.
		======================================================================-->
	<xsl:template match="comments">
        <xsl:variable name="style-name">
            <xsl:choose>
                <xsl:when test="parent::subject">Subject Comments</xsl:when>
                <xsl:when test="parent::topic">Topic Comments</xsl:when>
                <xsl:when test="parent::subtopic">Subtopic Comments</xsl:when>
                <xsl:otherwise>Annotation</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="fn:xtag($style-name)" />

        <xsl:apply-templates>
            <xsl:with-param name="comments-style" select="$style-name" tunnel="yes" />
        </xsl:apply-templates>
		
        <xsl:call-template name="br" />
    </xsl:template>

    <xsl:template match="comments//p">
        <xsl:apply-templates />
        <xsl:if test="position() != last()">
            <xsl:call-template name="br" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="comments//h1">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:value-of select="fn:xtag-inline(concat($comments-style, ' Header'), current())" />
        <xsl:call-template name="br" />
    </xsl:template>

    <xsl:template match="comments//b | comments//i">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:variable name="style-suffix" select="if (local-name() = 'b') then ' Bold' else ' Italic'" />
        <xsl:value-of select="fn:xtag-inline(concat($comments-style, $style-suffix), current())" />
    </xsl:template>

    <xsl:template match="comments//tr">
        <xsl:if test="not(count(td) = (1, 2))">
            <xsl:message>Error in <xsl:value-of select="ancestor::comments/parent::element()/@name" /> comments (from the custom mappings files): Tables must have either one or two columns</xsl:message>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="count(td) = 2">
                <!-- The following line sets the tabs for these two
                     columns to be positioned at 125 pts, aligned
                     left, and filled with blank spaces ("1 ") -->
                <xsl:text>&lt;*t(125.0,0,"1 ")&gt;</xsl:text>
                <xsl:apply-templates select="td[1]" />
                <xsl:call-template name="sep" />
                <xsl:apply-templates select="td[2]" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="td[1]" />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="br" />
    </xsl:template>

    <xsl:template match="comments//td">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="url | email">
        <xsl:value-of select="fn:xtag-inline('website', current())" />
    </xsl:template>


	<!--=====================================================================
		Named Templates
		
		templates for very specific purposes, like creating the division 
		information at the top of each subject and getting a nicely-formatted 
		list of the Core Curriculum courses in each subject.
		======================================================================-->
	
	<!-- spit out the division name and contact information -->
    <xsl:template name="division-info">
        <xsl:value-of select="fn:xtag('Division Info')" />

    	<!-- Get the division info. -->
    	<xsl:variable name="division-name" select="upper-case(ancestor::division/@name)" />
    	<xsl:variable name="ext"           select="if (contact/@ext) then contact/@ext else ancestor::division/contact/@ext" />
    	<xsl:variable name="room"          select="if (contact/@room) then contact/@room else ancestor::division/contact/@room" />
    	<xsl:variable name="extra-room"    select="if (contact/@extra-room) then contact/@extra-room else ancestor::division/contact/@extra-room" />
    	<xsl:variable name="email"         select="if (contact/@email) then contact/@email else ancestor::division/contact/@email" />
    	
    	<!-- division name -->
    	<xsl:value-of select="$division-name" /><xsl:text>  |  </xsl:text>
    	
    	<!-- phone number plus extension -->
    	<xsl:text>972-860-</xsl:text><xsl:value-of select="$ext" /><xsl:text>  |  </xsl:text>
    	
    	<!-- either room or rooms or location -->
    	<xsl:choose>
    		<!-- if there is a @location, don't print 'ROOM ' first, just print
    			the location -->
    		<xsl:when test="@location">
    			<xsl:value-of select="@location" />
    		</xsl:when>
    		<xsl:otherwise>
    			<!-- if there is an @extra-room, add an S to ROOM -->
    			<xsl:text>ROOM</xsl:text><xsl:value-of select="if ($extra-room) then 'S ' else ' '" />
    			
    			<!-- the actual room number -->
    			<xsl:value-of select="$room" />
    			
    			<!-- if there's an extra room, add it -->
    			<xsl:if test="$extra-room">
    				<xsl:text> and </xsl:text><xsl:value-of select="$extra-room" />
    			</xsl:if>
    		</xsl:otherwise>
    	</xsl:choose>
    	<xsl:call-template name="br" />
    	
    	<!-- email address -->
    	<xsl:text>E-MAIL:  </xsl:text><xsl:value-of select="$email" />
    	
    	<xsl:call-template name="br" />
    </xsl:template>

    <!-- create the list of Core Curriculum courses at the top of each subject -->
    <xsl:template name="make-core-list">
    	<xsl:for-each-group select="descendant::course[@core-name and @core-name != '']" group-by="@core-name">
    		<xsl:call-template name="make-core-list-entry">
    			<xsl:with-param name="core-component" select="current-grouping-key()" as="xs:string" />
    			<xsl:with-param name="core-courses"   select="current-group()"        as="element()*" />
    		</xsl:call-template>
    	</xsl:for-each-group>
    </xsl:template>
	<xsl:template name="make-core-list-entry">
		<xsl:param name="core-component" as="xs:string" />
		<xsl:param name="core-courses"   as="element()*" />
		
		<xsl:if test="count($core-courses) &gt; 0">
			<xsl:value-of select="fn:xtag('Core List Header')" />
			<xsl:text>The following courses </xsl:text>
			<xsl:if test="$core-component = 'other'">in this subject </xsl:if>
			<xsl:text>are part of</xsl:text>
			<xsl:call-template name="br" />
			<xsl:text>the </xsl:text>
			<xsl:if test="$core-component != 'other'"><xsl:value-of select="$core-component" /> component of the </xsl:if>
			<xsl:text>Core Curriculum:</xsl:text>
			<xsl:call-template name="br" />
			
			<xsl:value-of select="fn:xtag('Core List')" />
			<xsl:for-each-group select="$core-courses" group-by="@rubric">
				<xsl:sort select="@rubric" />
				
				<xsl:for-each-group select="current-group()" group-by="@number">
					<xsl:sort select="@number" />
					<xsl:value-of select="concat(@rubric, ' ', @number)" />
					
					<xsl:if test="position() != last()">
						<xsl:value-of select="', '" />
					</xsl:if>
				</xsl:for-each-group>
				
				<xsl:if test="position() != last()">
					<xsl:value-of select="', '" />
				</xsl:if>
			</xsl:for-each-group>
			
			<xsl:call-template name="br" />
			<xsl:call-template name="blank-line" />
		</xsl:if>
	</xsl:template>


	<!--=====================================================================
		Named templates for Special Characters
		
		insert special characters into the output
		======================================================================-->
	
	<!-- quark preamble is <v6.50><e0>\r -->
	<xsl:template name="quark-preamble">
		<xsl:text>&lt;v6.50&gt;&lt;e0&gt;</xsl:text><xsl:call-template name="br" />
	</xsl:template>
	
	<!-- quark requires mac-style line markers, '\r' -->
    <xsl:template name="br">
    	<xsl:text>&#13;</xsl:text>
    </xsl:template>

	<!-- a dash -->
    <xsl:template name="sep">
        <xsl:text>&#9;</xsl:text>
    </xsl:template>

	<!-- inserts a blank line into the output -->
	<xsl:template name="blank-line">
		<xsl:value-of select="fn:xtag('Normal Class')" />
		<xsl:call-template name="br" />
	</xsl:template>
	
	<!-- four blank lines -->
	<xsl:template name="breather">
		<xsl:call-template name="br" />
		<xsl:call-template name="br" />
		<xsl:call-template name="br" />
		<xsl:call-template name="br" />
	</xsl:template>
	
	
	<!--=====================================================================
		Quark XPress Tags Functions
		
		insert Quark XPress Tags into the output
		======================================================================-->
	
	<!-- paragraph styles (look like '@style:') -->
	<xsl:function name="fn:xtag" as="xs:string">
		<xsl:param name="style-name" as="xs:string" />
		
		<xsl:value-of select="concat('@', normalize-space($style-name), ':')" />
	</xsl:function>
	
	<!-- character styles (look like '<@style>...<@$p>' -->
	<xsl:function name="fn:xtag-inline" as="xs:string">
		<xsl:param name="style-name"    as="xs:string" />
		<xsl:param name="content"       as="xs:string" />
		
		<xsl:value-of select="concat('&lt;@', normalize-space($style-name), '&gt;', $content, '&lt;@$p&gt;')" />
	</xsl:function>

</xsl:stylesheet>
