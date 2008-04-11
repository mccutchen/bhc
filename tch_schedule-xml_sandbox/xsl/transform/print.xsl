<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
    exclude-result-prefixes="xs utils fn">

	<!--SETUP
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:include href="transform-utils.xsl" />
	<xsl:output
		method="text"
		encoding="us-ascii"
		indent="no" />
	<xsl:strip-space elements="*" />
	
	
	<!--PARAMETERS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-format:
		Determines whether output is formatted for QuarkXpress or InDesign.
		QuarkXpress: 'quark'
		InDesign:    'indesign'
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:param name="format" select="'quark'" />
	
	
	<!--Globals
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:variable name="output-type" as="xs:string" select="'print'" />
	<xsl:variable name="ext"         as="xs:string" select="'txt'"   />
	
	
	<!--START TRANSFORMATION
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		break the process into manageable pieces.
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template match="schedule">
		<!-- check params -->
		<xsl:choose>
			<xsl:when test="lower-case($format) = 'quark'">
				<xsl:apply-templates select="term" mode="setup" />
			</xsl:when>
			<xsl:when test="lower-case($format) = 'indesign'">
				<xsl:apply-templates select="term" mode="setup" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>You must choose either 'quark' or 'indesign' as the output format.</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!--SETUP
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
		<xsl:template match="term" mode="setup">
		<!-- processing vars -->
		<xsl:variable name="year" select="parent::schedule/@year"                   as="xs:string" />
		<xsl:variable name="sem"  select="parent::schedule/@semester"               as="xs:string" />
		<xsl:variable name="pre"  select="utils:generate-outdir($year, $sem)"       as="xs:string" />
		<xsl:variable name="dir"  select="concat($pre, '_', $output-type)"          as="xs:string" />
		<xsl:variable name="term" select="utils:make-url(@name)"                    as="xs:string" />
		<xsl:variable name="path" select="concat($dir,'/',$term)"                   as="xs:string" />
		
		<!-- create single-file output -->
		<xsl:apply-templates select="." mode="init">
			<xsl:with-param name="path"          select="concat($dir,'/',$term,'.',$ext)" />
			<xsl:with-param name="show-comments" select="true()" tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- create multi-file subject output -->
		<xsl:apply-templates select="division/subject" mode="init">
			<xsl:with-param name="path"          select="$path" />
			<xsl:with-param name="show-comments" select="true()" tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- create single-file special-section output -->
		<xsl:apply-templates select="special-section" mode="init">
			<xsl:with-param name="path"          select="$path" />
			<xsl:with-param name="show-comments" select="false()" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>
	

	<!--INIT
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Shuttle data off to required output files
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<!-- for each term, make a new result document -->
	<xsl:template match="term" mode="init">
		<xsl:param name="path" as="xs:string" />
        
        <xsl:result-document href="{$path}">
        	
        	<!-- preamble -->
        	<xsl:value-of select="fn:preamble()" />
            
            <!-- if multiple terms, output extra info -->
        	<xsl:if test="count(//term) &gt; 1">
                <xsl:value-of select="fn:p-tag('Term Header')" /><xsl:value-of select="@name" /><xsl:value-of select="fn:newline()" />
                <xsl:value-of select="fn:p-tag('Term Dates')" /><xsl:value-of select="utils:long-dates(utils:format-dates(@date-start, @date-end))" /><xsl:value-of select="fn:newline()" />
            </xsl:if>
            
            <!-- continue transformation -->
            <xsl:apply-templates select="." />
        </xsl:result-document>
    </xsl:template>
	
	<!-- for each subject make a new result document -->
	<xsl:template match="subject" mode="init">
		<xsl:param name="path" as="xs:string" />
		
		<!-- if this is not supposed to display, display a warning -->
		<xsl:if test="@display = 'false'">
			<xsl:message>
				<xsl:text>!Warning! Unsorted subject: </xsl:text>
				<xsl:value-of select="@name" />
				<xsl:text>.</xsl:text>
			</xsl:message>
		</xsl:if>
		
		<!-- set up single result document -->
		<xsl:variable name="div"  select="utils:make-url(parent::division/@name)" as="xs:string" />
		<xsl:variable name="subj" select="utils:make-url(@name)"                  as="xs:string" />
		
		<xsl:result-document href="{$path}/{$div}/{$subj}.{$ext}">
			<xsl:value-of select="fn:preamble()" />
			
			<!-- continue transformation -->
			<xsl:apply-templates select="." />
		</xsl:result-document>
	</xsl:template>
	
	<!-- for each special section, make a new result document -->
	<xsl:template match="special-section" mode="init">
		<xsl:param name="path" as="xs:string" />
		
		<!-- set up result document -->
		<xsl:variable name="ss"   select="utils:make-url(@name)" as="xs:string" />
		
		<xsl:result-document href="{$path}/{$ss}.{$ext}">
			<xsl:value-of select="fn:preamble()" />
			
			<!-- continue transformation -->
			<xsl:apply-templates select="." />
		</xsl:result-document>
	</xsl:template>
	
	
	<!--PROCESS ELEMENTS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Normal processing
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	
	<!-- process terms -->
	<xsl:template match="term">
        <!-- first, output everything that's not in the special divisions -->
        <xsl:apply-templates select="division[@name != 'School of the Arts' and @name != 'Senior Adult Education Office']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
		
		<!-- output special divisions -->

        <!-- let it breathe! -->
        <xsl:value-of select="fn:newline(4)" />

        <!-- output School of the Arts -->
		<xsl:apply-templates select="division[@name = 'School of the Arts']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- let it breathe! -->
        <xsl:value-of select="fn:newline(4)" />

        <!-- output the Senior Adult courses -->
		<xsl:apply-templates select="division[@name = 'Senior Adult Education Office']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
	</xsl:template>
	
	<!-- process special sections -->
	<xsl:template match="special-section[not(parent::special-section)]">
		
		<!-- place page title header -->
		<xsl:value-of select="fn:p-tag('Subject Header')" />
		<xsl:value-of select="concat(upper-case(@name), ' COURSES')" />
		<xsl:value-of select="fn:newline()" />
		<xsl:value-of select="fn:newline()" />
		
		<xsl:apply-templates select="@name" />
		
		<xsl:apply-templates select="*" />
	</xsl:template>
	
	<!-- process nested special-sections -->
	<xsl:template match="special-section[parent::special-section]">
		
		<xsl:value-of select="fn:p-tag('Minimester Header')" />
		<xsl:value-of select="concat(upper-case(@name), ' ', upper-case(parent::special-section/@name))" />
		
		<xsl:apply-templates select="*" />
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
            <xsl:value-of select="fn:p-tag('Topic Header')" />
            <xsl:text>CREDIT COURSES</xsl:text>
            <xsl:value-of select="fn:newline()" />
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
        <xsl:value-of select="fn:br(3)" />
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
            <xsl:value-of select="fn:br()" />
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
            <xsl:value-of select="fn:br()" />
        </xsl:if>
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
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>

	<!-- process courses -->
	<xsl:template match="course">
		<xsl:param name="show-comments" as="xs:boolean" tunnel="yes" />
		
		<xsl:apply-templates select="class">
			<xsl:sort select="@sortkey" data-type="number" />
			<xsl:sort select="@sortkey-days" data-type="number" />
			<xsl:sort select="@sortkey-date" data-type="number" />
			<xsl:sort select="@sortkey-time" data-type="number" order="ascending" />
			<xsl:sort select="@section" />
		</xsl:apply-templates>
		
		<xsl:if test="$show-comments">
			<xsl:apply-templates select="comments" />
		</xsl:if>
		
        <!-- only add a blank line after the comments if this is not the
             last course and if this isn't part of a <group> -->
        <xsl:if test="(position() != last()) and not(following-sibling::course/@number = self::course/@number)">
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>

	<!-- process classes -->
	<xsl:template match="class">
		<xsl:param name="show-comments" as="xs:boolean" tunnel="yes" />
		
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

        <xsl:value-of select="fn:p-tag(concat($style-name, ' Class'))" />

        <!-- the class number is a composite of the course's @rubric and @number and the class's @section -->
        <xsl:value-of select="../@rubric" /><xsl:text> </xsl:text>
        <xsl:value-of select="../@number" /><xsl:text>-</xsl:text>
        <xsl:value-of select="@section" /><xsl:value-of select="fn:sep()" />

        <xsl:value-of select="@title" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@synonym" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="../@credit-hours" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="utils:format-dates(@date-start, @date-end)" />
		<xsl:apply-templates select="@weeks" /><xsl:value-of select="fn:newline()" />
		
        <xsl:apply-templates select="meeting">
            <xsl:sort select="@sortkey" />
        	<xsl:sort select="@sortkey-method" data-type="number" />
        	<xsl:sort select="@sortkey-days"   data-type="number" />
        	<xsl:sort select="@sortkey-times"  data-type="number" />
        </xsl:apply-templates>
		
		<xsl:if test="$show-comments">
			<xsl:apply-templates select="comments" />
		</xsl:if>
		
	</xsl:template>

	<!-- process meetings (normal / extra) -->
    <xsl:template match="meeting[@method = ('LEC','')]">
    	<xsl:apply-templates select="@days" /><xsl:value-of select="fn:sep()" />
    	<xsl:value-of select="utils:format-times(@time-start, @time-end)" />
    	<xsl:text> / </xsl:text>
    	<xsl:value-of select="@method" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@room" /><xsl:value-of select="fn:sep()" />
    	<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:value-of select="fn:newline()" />
    </xsl:template>

	<xsl:template match="meeting[@method = 'INET']">
		<xsl:value-of select="'NA'" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="concat('NA / ', parent::class/@topic-code)" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="'OL'" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="''" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:value-of select="fn:newline()" />
	</xsl:template>
	
	<xsl:template match="meeting[@method = 'COOP']">
		<xsl:value-of select="fn:p-tag('Extra Class')" />
		<xsl:value-of select="@method" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="'NA'" /><xsl:value-of select="fn:sep()" />
		<xsl:choose>
			<xsl:when test="@room = 'INET'">
				<xsl:value-of select="'NA'" /><xsl:value-of select="fn:sep()" />
				<xsl:value-of select="'OL'" /><xsl:value-of select="fn:sep()" />
			</xsl:when>
			<xsl:when test="@days = 'MTWRFSU'">
				<xsl:value-of select="'NA'" /><xsl:value-of select="fn:sep()" />
				<xsl:value-of select="'NA'" /><xsl:value-of select="fn:sep()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="@days" /><xsl:value-of select="fn:sep()" />
				<xsl:value-of select="@room" /><xsl:value-of select="fn:sep()" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:value-of select="fn:newline()" />
	</xsl:template>
	
	<xsl:template match="meeting[@method = 'OL']">
		<xsl:value-of select="'NA'" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="concat('NA / ', parent::class/@topic-code)" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="'OL'" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="''" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:value-of select="fn:newline()" />
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:value-of select="fn:p-tag('Extra Class')" />
		<xsl:value-of select="@method" /><xsl:value-of select="fn:sep()" />
		<xsl:value-of select="if (@time-start != '' and @time-end != '') then utils:format-times(@time-start, @time-end) else 'TBA'" /><xsl:value-of select="fn:sep()" />
		<xsl:choose>
			<xsl:when test="@room = 'INET'">
				<xsl:value-of select="'TBA'" /><xsl:value-of select="fn:sep()" />
				<xsl:value-of select="'OL'" /><xsl:value-of select="fn:sep()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="@days" /><xsl:value-of select="fn:sep()" />
				<xsl:value-of select="@room" /><xsl:value-of select="fn:sep()" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="if (faculty/@name-last) then faculty/@name-last else 'Staff'" /><xsl:value-of select="fn:newline()" />
	</xsl:template>
	
	<!--PROCESS ATTRIBUTES
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	
	<!-- format the names of subjects, topics, and subtopics -->
	<xsl:template match="subject/@name | topic/@name | subtopic/@name">
		<xsl:variable name="special" select="if(ancestor::special-section) then 'Special ' else ''" as="xs:string" />
		<xsl:variable name="style-name"
			select="concat($special, upper-case(substring(../local-name(), 1,1)), lower-case(substring(../local-name(), 2)), ' Header')" />
		<xsl:value-of select="fn:p-tag($style-name)" />
		<xsl:value-of select="upper-case(.)" />
		<xsl:value-of select="fn:newline()" />
	</xsl:template>
	
	<!-- format the names of types -->
	<xsl:template match="type/@name">
		<!-- only output the type header if we're not in a special-section with the same name -->
		<xsl:if test="normalize-space(.) != normalize-space(ancestor::special-section[1]/@name)">
			<xsl:value-of select="fn:p-tag('Type Header')" /><xsl:value-of select="." /> Courses<xsl:value-of select="fn:newline()" />
		</xsl:if>
	</xsl:template>
	
	<!-- format class attributes -->
	<xsl:template match="class/@weeks">
		<xsl:value-of select="concat(' (', ., ' Wks)')" />
	</xsl:template>
	
	<xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@weeks" priority="1">
		<!-- don't output the number of weeks for Senior Adult courses -->
	</xsl:template>
	
	<!-- format meeting attributes -->
	<xsl:template match="meeting[starts-with(ancestor::subject/@name, 'Senior Adult')]/@days" priority="1">
		<!-- spell out the days of the week for Senior Adult courses -->
		<xsl:value-of select="utils:senior-adult-days(.)" />
	</xsl:template>
	
	
	
	<!--PROCESS COMMENTS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		<comments> elements are allowed to have a small subset of
		HTML elements as children, in addition to the special
		elements <url> and <email>.  The set of HTML elements allowed
		in <comments> elements is:
		
		* h1, p, b, i, table, tr, td
		
		The following templates handle the proper Quark XPress Tag
		generation for the <comments> element and its children.
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template match="comments">
        <xsl:variable name="style-name">
            <xsl:choose>
                <xsl:when test="parent::subject">Subject Comments</xsl:when>
                <xsl:when test="parent::topic">Topic Comments</xsl:when>
                <xsl:when test="parent::subtopic">Subtopic Comments</xsl:when>
                <xsl:otherwise>Annotation</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="fn:p-tag($style-name)" />

        <xsl:apply-templates>
            <xsl:with-param name="comments-style" select="$style-name" tunnel="yes" />
        </xsl:apply-templates>
		
        <xsl:value-of select="fn:newline()" />
    </xsl:template>

    <xsl:template match="comments//p">
        <xsl:apply-templates />
        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="comments//h1">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:value-of select="fn:c-tag(concat($comments-style, ' Header'), current())" />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>

    <xsl:template match="comments//b | comments//i">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:variable name="style-suffix" select="if (local-name() = 'b') then ' Bold' else ' Italic'" />
        <xsl:value-of select="fn:c-tag(concat($comments-style, $style-suffix), current())" />
    </xsl:template>
	
	<xsl:template match="comments//table">
		<xsl:choose>
			<xsl:when test="$format = 'quark'"><xsl:apply-templates select="*" /></xsl:when>
			<xsl:when test="$format = 'indesign'">
				<xsl:value-of select="fn:TableStart(count(tr), count(tr[1]/td))" />
				<xsl:apply-templates select="tr" />
				<xsl:value-of select="fn:TableEnd()" />
				<xsl:value-of select="fn:newline()" />
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="comments//tr">
		<xsl:choose>
			<xsl:when test="$format = 'quark'">
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
						<xsl:value-of select="fn:sep()" />
						<xsl:apply-templates select="td[2]" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="td[1]" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="fn:newline()" />
			</xsl:when>
			<xsl:when test="$format = 'indesign'">
				<xsl:value-of select="fn:RowStart()" />
				<xsl:apply-templates select="td" />
				<xsl:value-of select="fn:RowEnd()" />
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="comments//td">
		<xsl:choose>
			<xsl:when test="$format = 'quark'">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:when test="$format = 'indesign'">
				<xsl:value-of select="fn:CellStart()" />
				<xsl:apply-templates />
				<xsl:value-of select="fn:CellEnd()" />
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="url | email">
        <xsl:value-of select="fn:c-tag('website', current())" />
    </xsl:template>
	
	<xsl:template match="comments//text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>


	<!--NAMED TEMPLATES
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		templates for very specific purposes, like creating the division 
		information at the top of each subject and getting a nicely-formatted 
		list of the Core Curriculum courses in each subject.
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	
	<!-- spit out the division name and contact information -->
    <xsl:template name="division-info">
        <xsl:value-of select="fn:p-tag('Division Info')" />

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
    	<xsl:value-of select="fn:newline()" />
    	
    	<!-- email address -->
    	<xsl:text>E-MAIL:  </xsl:text><xsl:value-of select="$email" />
    	
    	<xsl:value-of select="fn:newline()" />
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
			<xsl:value-of select="fn:p-tag('Core List Header')" />
			<xsl:text>The following courses </xsl:text>
			<xsl:if test="$core-component = 'other'">in this subject </xsl:if>
			<xsl:text>are part of</xsl:text>
			<xsl:value-of select="fn:newline()" />
			<xsl:text>the </xsl:text>
			<xsl:if test="$core-component != 'other'"><xsl:value-of select="$core-component" /> component of the </xsl:if>
			<xsl:text>Core Curriculum:</xsl:text>
			<xsl:value-of select="fn:newline()" />
			
			<xsl:value-of select="fn:p-tag('Core List')" />
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
			
			<xsl:value-of select="fn:newline()" />
			<xsl:value-of select="fn:br()" />
		</xsl:if>
	</xsl:template>
	
	
	<!--PICK-FORMAT NAMED TEMPLATES
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		insert special characters into the output
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<!-- insert preamble -->
	<xsl:function name="fn:preamble" as="xs:string">
		<xsl:choose>
			<xsl:when test="$format = 'quark'">
				<!-- quark preamble is <v6.50><e0>\r -->
				<xsl:value-of select="concat('&lt;v6.50&gt;&lt;e0&gt;', fn:newline())" />
			</xsl:when>
			<xsl:when test="$format = 'indesign'">
				<!-- InDesign preamble is <ASCII-MAC>\n<Version:3><FeatureSet:InDesign-Roman><ColorTable:=<Black:COLOR:CMYK:Process:0,0,0,1>>\n -->
				<xsl:value-of select="concat('&lt;ASCII-MAC&gt;', fn:newline(), '&lt;Version:3&gt;', '&lt;FeatureSet:InDesign-Roman&gt;&lt;ColorTable:=&lt;Black:COLOR:CMYK:Process:0,0,0,1&gt;&gt;', fn:newline())" />
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- insert one or more newline/return/etc characters -->
	<xsl:function name="fn:newline" as="xs:string">
		<xsl:choose>
			<xsl:when test="$format = 'quark'">
				<!-- quark requires mac-style line markers, '\r' -->
				<xsl:text>&#13;</xsl:text>
			</xsl:when>
			<xsl:when test="$format = 'indesign'">
				<!-- newline -->
				<xsl:text>&#13;</xsl:text>
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:newline" as="xs:string">
		<xsl:param name="count" as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="$count &lt; 1"><xsl:value-of select="''" /></xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$format = 'quark'">
						<xsl:value-of select="concat('&#9;', fn:newline($count - 1))" />
					</xsl:when>
					<xsl:when test="$format = 'indesign'">
						<xsl:value-of select="concat('$#13;', fn:newline($count - 1))" />
					</xsl:when>
					<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- insert seperater -->
	<xsl:function name="fn:sep" as="xs:string">
		<xsl:choose>
			<xsl:when test="$format = ('quark', 'indesign')">
				<xsl:text>&#9;</xsl:text>
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- inserts a blank line into the output -->
	<xsl:function name="fn:br" as="xs:string">		
			<xsl:choose>
				<xsl:when test="$format = 'quark'">
					<xsl:value-of select="concat(fn:p-tag('Normal Class'), fn:newline())" />
				</xsl:when>
				<xsl:when test="$format = 'indesign'">
					<xsl:value-of select="concat(fn:p-tag(''), fn:newline())" />
				</xsl:when>
				<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
			</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:br" as="xs:string">
		<xsl:param name="count" as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="$count &lt; 1"><xsl:value-of select="''" /></xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$format = 'quark'">
						<xsl:value-of select="concat(fn:p-tag('Normal Class'), fn:br($count - 1), fn:newline())" />
					</xsl:when>
					<xsl:when test="$format = 'indesign'">
						<xsl:value-of select="concat(fn:p-tag(''), fn:br($count - 1), fn:newline())" />
					</xsl:when>
					<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- insert paragraph style -->
	<xsl:function name="fn:p-tag" as="xs:string">
		<xsl:param name="style-name" as="xs:string" />

		<xsl:choose>
			<xsl:when test="$format = 'quark'">
				<!-- looks like '@style:' -->
				<xsl:value-of select="concat('@', normalize-space($style-name), ':')" />
			</xsl:when>
			<xsl:when test="$format = 'indesign'">
				<!-- looks like '<ParaStyle:[name]>' -->
				<xsl:value-of select="concat('&lt;ParaStyle:', normalize-space($style-name), '&gt;')" />
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- insert character style -->
	<xsl:function name="fn:c-tag" as="xs:string">
		<xsl:param name="style-name"    as="xs:string" />
		<xsl:param name="content"       as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="$format = 'quark'">
				<!-- looks like '<@style>...<@$p>' -->
				<xsl:value-of select="concat('&lt;@', normalize-space($style-name), '&gt;', $content, '&lt;@$p&gt;')" />
			</xsl:when>
			<xsl:when test="$format = 'indesign'">
				<!-- looks like '<CharStyle:[name]>' -->
				<xsl:value-of select="concat('&lt;CharStyle:', normalize-space($style-name), '&gt;', $content, '&lt;CharStyle:&gt;')" />
			</xsl:when>
			<xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:template name="no-such-format" as="xs:string">
		<xsl:message>
			<xsl:text>No format named </xsl:text>
			<xsl:value-of select="$format" />
			<xsl:text>.</xsl:text>
		</xsl:message>
		<xsl:value-of select="''" />
	</xsl:template>
	

	<!--INDESIGN TABLE BUILDER FUNCTIONS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		insert InDesign Tables into the output
		table tags (look like '<TableStart><RowStart><CellStart><CellEnd><RowEnd><TableEnd>
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:function name="fn:TableStart" as="xs:string">
		<xsl:param name="rows" as="xs:integer" />
		<xsl:param name="cols" as="xs:integer" />
		
		<xsl:value-of select="concat(fn:p-tag(''), '&lt;TableStart:', $rows, ',', $cols, ':0:0&gt;')" />
	</xsl:function>
	
	<xsl:function name="fn:TableEnd" as="xs:string">
		<xsl:text>&lt;TableEnd:&gt;</xsl:text>
	</xsl:function>
	
	<xsl:function name="fn:RowStart" as="xs:string">
		<xsl:text>&lt;RowStart:&gt;</xsl:text>
	</xsl:function>
	
	<xsl:function name="fn:RowEnd" as="xs:string">
		<xsl:text>&lt;RowEnd:&gt;</xsl:text>
	</xsl:function>
	
	<xsl:function name="fn:CellStart" as="xs:string">
		<xsl:text>&lt;CellStart:1,1&gt;</xsl:text>
	</xsl:function>
	
	<xsl:function name="fn:CellEnd" as="xs:string">
		<xsl:text>&lt;CellEnd:&gt;</xsl:text>
	</xsl:function>
</xsl:stylesheet>