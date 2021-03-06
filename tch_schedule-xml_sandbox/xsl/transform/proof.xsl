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
        method="xhtml"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
    
    
	<!--PARAMETERS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		-highlighting:
		turns highlighting on/off
		
		-output style:
		A switch which controls how many proof documents are generated:
		* If true, only the documents for each individual subject are
		created, for simplicity's sake.
		* If false, all of the possible documents are created, which
		includes one for each term, each division, each special-section
		and each subject, all stowed in appropriate directories.
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:param name="hilight" select="'false'" />
	<xsl:param name="is-full" select="'false'" />
	
	
	<!--GLOBALS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:variable name="output-type" as="xs:string" select="if($is-full = 'true') then 'proof-full' else 'proof'" />
	<xsl:variable name="ext"         as="xs:string" select="'html'"         />
	<xsl:variable name="page-title"  as="xs:string" select="'Proof Report'" />


	<!--STYLESHEET
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <xsl:variable name="doc-css" select="document('includes/proof-css.xml')/styles" as="node()*" />



    <!--INIT
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    	Each template whose @mode="init" has only one purpose:  create an
    	appropriately-located <xsl:result-document /> into which it will
    	insert itself.
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template match="/schedule">
		<xsl:variable name="year" as="xs:string" select="@year"     />
		<xsl:variable name="sem"  as="xs:string" select="@semester" />
		
		<!-- Pick the type of output desired -->
		<xsl:choose>
			
			<!-- if this is a proof-full run -->
			<xsl:when test="$is-full = 'true'">
				<!-- initialize terms -->
				<xsl:apply-templates select="term" mode="init">
					<xsl:with-param name="path" tunnel="yes" select="concat(utils:generate-outdir($year, $sem), '_', $output-type)" />
				</xsl:apply-templates>
			</xsl:when>
			
			<!-- if this is a simple proof run -->
			<xsl:otherwise>
				<!-- initialize subjects for simple output -->
				<xsl:apply-templates select="term/division/subject" mode="init-simple">
					<xsl:with-param name="path" tunnel="yes" select="concat(utils:generate-outdir($year, $sem), '_', $output-type)" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- proof-full chain -->
	
	<xsl:template match="term" mode="init">
		<xsl:param    name="path" as="xs:string" tunnel="yes" />
		<xsl:variable name="term" as="xs:string" select="utils:make-url(@name)" />
		
		<!-- create term-level output: term/divisions/subjects + term/special-divisions/subjects + term/special-section/divsions/subjects -->
		<xsl:result-document href="{$path}/{$term}.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="@name" />
			</xsl:call-template>
		</xsl:result-document>
		
		<!-- initialize divisions -->
		<xsl:apply-templates select="division" mode="init">
			<xsl:with-param name="path" tunnel="yes" select="concat($path,'/',$term)" />
		</xsl:apply-templates>
		
		<!-- initialize special-sections -->
		<xsl:apply-templates select="special-section" mode="init">
			<xsl:with-param name="path" tunnel="yes" select="concat($path,'/',$term)" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="division" mode="init">
		<xsl:param name="path" as="xs:string" tunnel="yes" />
		<xsl:variable name="div"  select="utils:make-url(@name)" as="xs:string" />
		
		<!-- create division-level output: division/subjects -->
		<xsl:result-document href="{$path}/{$div}.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="@name" />
			</xsl:call-template>
		</xsl:result-document>
		
		<!-- create subject-level output -->
		<xsl:apply-templates select="subject" mode="init">
			<xsl:with-param name="path" tunnel="yes" select="concat($path,'/',$div)" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="special-section[special-section]" mode="init">
		<!-- if there's a child special section, drop it down another level -->
		<xsl:apply-templates select="special-section" mode="init" />
	</xsl:template>
	
	<xsl:template match="special-section" mode="init">
		<xsl:param    name="path" as="xs:string" tunnel="yes" />
		<xsl:variable name="name" as="xs:string" select="if(parent::special-section) then concat(parent::special-section/@name,' ',@name) else @name" />
		<xsl:variable name="ss"   as="xs:string" select="utils:make-url($name)" />
		
		<!-- create special-section-level output: special-section/divisions/subjects -->
		<xsl:result-document href="{$path}/{$ss}.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="$name" />
			</xsl:call-template>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="subject" mode="init">
		<xsl:param    name="path" as="xs:string" tunnel="yes" />
		<xsl:variable name="subj" as="xs:string" select="utils:make-url(@name)" />
		
		<!-- create division-level output: division/subjects -->
		<xsl:result-document href="{$path}/{$subj}.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="@name" />
			</xsl:call-template>
		</xsl:result-document>
	</xsl:template>
	
	
	<!-- simple proof chain -->
	
	<xsl:template match="subject" mode="init-simple">
		<xsl:param    name="path" as="xs:string" tunnel="yes" />
		<xsl:variable name="term" as="xs:string" select="utils:make-url(ancestor::term/@name)" />
		<xsl:variable name="div"  as="xs:string" select="utils:make-url(parent::division/@name)" />
		<xsl:variable name="subj" as="xs:string" select="utils:make-url(@name)" />
		
		<xsl:result-document href="{$path}/{$term}/{$div}/{$subj}.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="@name" />
			</xsl:call-template>
		</xsl:result-document>
	</xsl:template>
	

    <!--CALL-BACKS
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    	These templates are used to return from the page-template template,
    	once the document shell has been created.
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template match="term" mode="page-callback">
		<!-- display term header (if applicable) and child subjects -->
		<xsl:call-template name="term-header" />
		
		<!-- display warning if this item has @display = 'false' -->
		<xsl:call-template name="warning-display" />
		
		<!-- display message that this term is being processed -->
		<xsl:call-template name="message-processing" />
		
		<!-- There are apparently some divisions' subjects that are handled a little differently -->
		<xsl:variable name="special-divisions" select="'Senior Adult Education Office', 'School of the Arts'" as="xs:string*" />
		
		<!-- call normal child subjects -->
		<xsl:apply-templates select="division/subject[not(parent::division/@name = $special-divisions)]">
			<xsl:sort select="@name" />
		</xsl:apply-templates>
		
		<!-- call special-section subjects -->
		<xsl:apply-templates select="special-section" />
		
		<!-- call abnormal child subjects -->
		<xsl:apply-templates select="division/subject[parent::division/@name = $special-divisions]">
			<xsl:sort select="@name" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="division" mode="page-callback">
		<!-- display warning if this item has @display = 'false' -->
		<xsl:call-template name="warning-display" />
		
		<xsl:apply-templates select="subject" />
	</xsl:template>
	
	<xsl:template match="special-section" mode="page-callback">
		<div class="subject-section">
			<h1 class="subject-header"><xsl:value-of select="upper-case(@name)" /></h1>
			
			<!-- handle non-flex special-sections -->
			<xsl:apply-templates select="division/subject" mode="special">
				<xsl:sort select="@name" />
			</xsl:apply-templates>
			
			<!-- handle flex terms... somehow... still figuring this one out -->
			<xsl:apply-templates select="special-section" />
		</div>
	</xsl:template>
	
	<xsl:template match="subject" mode="page-callback">
		<!-- display term header if applicable -->
		<xsl:call-template name="term-header" />
		
		<xsl:apply-templates select="." />
	</xsl:template>
	
	
	<!--NORMAL
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		Data is written to the result document, and children ARE processed
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template match="special-section">
		<h1 class="minimester-header"><xsl:value-of select="upper-case(@name)" /></h1>
		
		<xsl:apply-templates select="division/subject" mode="special" />
	</xsl:template>
	
	<xsl:template match="subject">
		<!-- display warning if this item has @display = 'false' -->
		<xsl:call-template name="warning-display" />
		
		<!-- start div -->
        <div class="subject-section">
            <h1 class="subject-header"><xsl:value-of select="upper-case(@name)" /></h1>

            <!-- print the division info -->
            <xsl:call-template name="division-info" />
            
            <!-- paste in comments -->
            <xsl:apply-templates select="comments" />

            <!-- insert a list of the Core courses -->
            <xsl:call-template name="make-core-list" />
        	
        	<!-- include non-topic'd courses -->
        	<xsl:apply-templates select="type" />
        	
        	<!-- include topic'd courses -->
        	<xsl:apply-templates select="topic" />
        </div>
	</xsl:template>
	
	<xsl:template match="subject" mode="special">
		<h1 class="special-subject-header"><xsl:value-of select="upper-case(@name)" /></h1>
		
		<!-- print the division info -->
		<xsl:call-template name="division-info" />
		
		<!-- paste in comments -->
		<xsl:apply-templates select="comments" />
		
		<!-- insert a list of the Core courses -->
		<xsl:call-template name="make-core-list" />
		
		<!-- include non-topic'd courses -->
		<xsl:apply-templates select="type" />
		
		<!-- include topic'd courses -->
		<xsl:apply-templates select="topic" />
	</xsl:template>
    
	<xsl:template match="topic">
		<!-- start div -->
		<div class="topic-section">
			<h2 class="topic-header"><xsl:value-of select="upper-case(@name)" /></h2>
			
			<!-- paste in comments -->
			<xsl:apply-templates select="comments" />
			
			<!-- if there are types, do that -->
			<xsl:apply-templates select="type" />
			
			<!-- if there are subtopics, do that -->
			<xsl:apply-templates select="subtopic" />
		</div>
	</xsl:template>
    
	<xsl:template match="subtopic">
        <!-- start div -->
        <div class="subtopic-section">
        	<h3 class="subtopic-header"><xsl:value-of select="upper-case(@name)" /></h3>
            
        	<xsl:apply-templates select="type" />
        </div>
    </xsl:template>


	<xsl:template match="type">
		<!-- start div -->
		<div class="type-section {@id}">
			<h4 class="type-header"><xsl:value-of select="@name" /> Courses</h4>
			
			<xsl:apply-templates select="course" />
		</div>
	</xsl:template>


	<xsl:template match="course">
        <!-- determine whether or not this is a core course -->
        <xsl:variable name="is-core" select="if (@core-code) then ' core' else ''" />
        
        <!-- stick the comments together if they are identical -->
		<xsl:variable name="classes" select="class" as="element()*" />
        <xsl:call-template name="group-comments">
            <xsl:with-param name="is-core" select="$is-core" />
            <xsl:with-param name="classes" select="$classes" />
            <xsl:with-param name="min-index" select="1" />
            <xsl:with-param name="max-index" select="utils:max-comment-match($classes, 1) + 1" />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="group-comments">
        <xsl:param name="is-core" as="xs:string" />
        <xsl:param name="classes" as="element()*" />
        <xsl:param name="min-index" as="xs:integer" />
        <xsl:param name="max-index" as="xs:integer" />
    	
        <!-- check for stop-conditions -->
        <xsl:choose>
            <!-- if we're done -->
            <xsl:when test="$min-index &lt; 1 or $min-index &gt; count($classes)" />
            <xsl:when test="count($classes) &lt; 1" />
        	<xsl:when test="$min-index &gt;= $max-index" />
        	<xsl:when test="count($classes[position() &gt;= $min-index and position() &lt; $max-index]) = 0" />
            
            <!-- otherwise, do it -->
            <xsl:otherwise>
            	<!--<div class="group-section">-->
				<xsl:variable name="is-group" select="if ($classes[position() = $min-index and position()]/@is-grouped = 'true') then ' group-section' else ''"  as="xs:string" />
	                <div class="course-section{$is-core}{$is-group}">
	                    <table>
	                        <xsl:apply-templates select="$classes[position() &gt;= $min-index and position() &lt; $max-index]/meeting" />
	                    </table>
	                    <xsl:apply-templates select="$classes[$min-index]/comments" />
	                    <xsl:apply-templates select="comments" />
	                </div>
            	<!--</div>-->
            	<xsl:call-template name="group-comments">
                    <xsl:with-param name="is-core" select="$is-core" />
                    <xsl:with-param name="classes" select="$classes" />
                    <xsl:with-param name="min-index" select="$max-index" />
                    <xsl:with-param name="max-index" select="utils:max-comment-match($classes, $max-index) + 1" />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
	<xsl:template match="class">
		<tr>
			<td class="number">
				<!-- the class number is a composite of the course's @rubric and @number and the class's @section -->
				<xsl:value-of select="../@rubric" /><xsl:text> </xsl:text>
				<xsl:value-of select="../@number" /><xsl:text>-</xsl:text>
				<xsl:value-of select="@section" /></td>
			<td class="title"><xsl:value-of select="@title" /></td>
			<td class="synonym"><xsl:value-of select="@synonym" /></td>
			<td class="credit_hours"><xsl:value-of select="../@credit-hours" /></td>
			<td class="dates"><xsl:value-of select="utils:format-dates(@date-start, @date-end)" />&#160;<xsl:apply-templates select="@weeks" /></td>
		</tr>
	</xsl:template>
	<xsl:template match="class/@weeks">
		(<xsl:value-of select="." />&#160;Wks)
	</xsl:template>
	
	<xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@weeks" priority="1">
		<!-- don't output the number of weeks for Senior Adult courses -->
	</xsl:template>
	
	
	<xsl:template match="meeting[@primary = 'true']">
		<xsl:apply-templates select="parent::class" />
		<tr>
			<td class="days"><xsl:value-of select="@days" /></td>
			<td class="times"><xsl:value-of select="fn:pick-times(@method, @time-start, @time-end)" />
				<xsl:text>&#160;/&#160;</xsl:text><xsl:value-of select="@method" /></td>
			<td class="room"><xsl:value-of select="@room" /></td>
			<td></td>
			<td class="faculty"><xsl:if test="not(faculty)">Staff</xsl:if><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	<xsl:template match="meeting[@primary = 'false']">
		<tr class="extra-meeting">
			<td class="method"><xsl:value-of select="if (@method != 'LEC') then @method else ''" /></td>
			<td class="times"><xsl:value-of select="fn:pick-times(@method, @time-start, @time-end)" /></td>
			<td class="days"><xsl:value-of select="@days" /></td>
			<td class="room"><xsl:value-of select="@room" /></td>
			<td class="faculty"><xsl:if test="not(faculty)">Staff</xsl:if><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="meeting[starts-with(ancestor::subject/@name, 'Senior Adult')]/@days">
		<!-- spell out the days of the week for Senior Adult courses -->
		<xsl:value-of select="utils:senior-adult-days(.)" />
	</xsl:template>
	
	<xsl:template match="faculty">
		<xsl:value-of select="concat(@name-last, ', ', upper-case(substring(@name-first, 1, 1)))" />
        <xsl:if test="position() != last()"><xsl:value-of select="', '" /></xsl:if>
	</xsl:template>


    <!--COMMENTS
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    	Comments can have a small subset of HTML elements embedded within 
    	them, as well as the special elements <url> and <email>. The set of 
    	legal HTML for comments is:
    		h1, p, b, i, table, tr, td
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <xsl:template match="comments">
        <!-- only include a row for comments if comments exist -->
        <div class="comments">
            <xsl:choose>
                <xsl:when test="not(p)">
                    <p><xsl:apply-templates /></p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template match="comments" mode="class">
        <!-- only include a row for comments if comments exist -->
        <tr>
            <td class="class-comments" colspan="7">
                <div class="comments">
                    <xsl:choose>
                        <xsl:when test="not(p)">
                            <p><xsl:apply-templates /></p>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates />
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </td>
        </tr>
    </xsl:template>

    <!-- skip any comments inside of <special-section>s -->
    <!--<xsl:template match="comments[ancestor::special-section]" />-->

    <xsl:template match="comments//h1 | comments//p | comments//b | comments//i | comments//table | comments//tr | comments//td | comments//@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="comments//h1" priority="1">
        <h4><xsl:apply-templates /></h4>
    </xsl:template>

    <xsl:template match="url">
        <xsl:variable name="address">
            <xsl:if test="substring(current(), 1, 7) != 'http://'">http://</xsl:if>
            <xsl:value-of select="current()" />
        </xsl:variable>
        <a href="{$address}" target="_blank"><xsl:value-of select="current()" /></a>
    </xsl:template>

    <xsl:template match="email">
        <a href="mailto:{current()}"><xsl:value-of select="current()" /></a>
    </xsl:template>



    <!--NAMED TEMPLATES
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    	Specialty templates to create the division-info and the HTML template
    	for each page, display warnings, etc.
    	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:template name="term-header">
		<xsl:variable name="term" select="ancestor-or-self::term" as="element()" />
		
		<!-- only output the term header if there is more than one term -->
		<xsl:if test="count(ancestor-or-self::schedule//term[@display = 'true']) &gt; 1">
			<h1 class="term-header">
				<xsl:value-of select="concat($term/@name, ' ', $term/parent::schedule/@year)" />
				<span class="term-dates"><xsl:value-of select="$term/@dates-display" /></span>
			</h1>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="division-info">
        <!-- get a pointer to the division node -->
        <xsl:variable name="division" select="ancestor::division" />
        
        <p class="division-info">
            <xsl:choose>
                <!-- if we're inside a division, print the full division contact info -->
                <xsl:when test="ancestor::division">
                    <!-- Get the division info.  Any info on this element overrides the info provided
                    by the ancestor division. -->
                    <xsl:variable name="ext" select="if (contact/@ext) then contact/@ext else $division/contact/@ext" />
                    <xsl:variable name="room" select="if (contact/@room) then contact/@room else $division/contact/@room" />
                    <!--<xsl:variable name="extra-room" select="if (@extra-room) then @extra-room else ancestor::division/@extra-room" />-->
                    <xsl:variable name="email" select="if (contact/@email) then contact/@email else $division/contact/@email" />

                    <!-- division name -->
                    <xsl:value-of select="upper-case($division/@name)" /><xsl:text>&#160;&#160;|&#160;&#160;</xsl:text>

                    <!-- phone number plus extension -->
                    <xsl:text>972-860-</xsl:text><xsl:value-of select="$ext" /><xsl:text>&#160;&#160;|&#160;&#160;</xsl:text>

                    <!-- either room or rooms or location -->
                    <xsl:choose>
                        <!-- if there is a @location, don't print 'ROOM ' first, just print
                             the location -->
                        <xsl:when test="contact/@location">
                            <xsl:value-of select="contact/@location" />
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- if there is an @extra-room, add an S to ROOM -->
                            <!--<xsl:text>ROOM</xsl:text><xsl:value-of select="if ($extra-room) then 'S ' else ' '" /><xsl:value-of select="$room" />-->
                            <xsl:text>ROOM </xsl:text><xsl:value-of select="$room" />

                            <!-- if there's an extra room, add it -->
                            <!--<xsl:if test="$extra-room">
                                <xsl:text> and </xsl:text><xsl:value-of select="$extra-room" />
                            </xsl:if>-->
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text disable-output-escaping="yes">&lt;br /&gt;</xsl:text>

                    <!-- email address -->
                    <xsl:text>E-MAIL:  </xsl:text><xsl:value-of select="$email" />
                </xsl:when>

                <!-- otherwise (we're probably in a special-section), just try to print the division name -->
                <xsl:otherwise><xsl:value-of select="if ($division/@name) then upper-case($division/@name) else 'UNKNOWN DIVISION'" /></xsl:otherwise>
            </xsl:choose>
        </p>
        
        <!-- print out the division comments -->
        <xsl:value-of select="$division/comments" />
    </xsl:template>


    <!-- the next two templates create the list of Core Curriculum courses
         at the top of each subject -->
    <xsl:template name="make-core-list">
        <xsl:variable name="core-courses" select="descendant::course[@core-code and @core-code != '']" as="element()*" />
        
        <xsl:for-each-group select="$core-courses" group-by="@core-name">
            <xsl:sort select="@core-code" data-type="number" />
            
            <xsl:variable name="core-name" select="current-grouping-key()" as="xs:string" />
            <div class="core-list">
                <h2>The following courses are part of the <xsl:value-of select="$core-name" /> component of the Core Curriculum:</h2>
                <p>
                    <xsl:for-each-group select="current-group()" group-by="@rubric">
                        <xsl:sort select="@rubric" />
                        
                        <xsl:for-each-group select="current-group()" group-by="@number">
                            <xsl:sort select="@number" data-type="number" />
                            
                            <xsl:value-of select="concat(@rubric, ' ', @number)" />
                            <xsl:if test="position() != last()">
                                <xsl:value-of select="', '" />
                            </xsl:if>
                        </xsl:for-each-group>
                        <xsl:if test="position() != last()">
                            <xsl:value-of select="', '" />
                        </xsl:if>
                    </xsl:for-each-group>
                </p>
            </div>
        </xsl:for-each-group>
    </xsl:template>
	
	<xsl:template name="warning-display">
		<xsl:if test="@display = 'false'">
			<xsl:message>
				<xsl:text>!Warning! Unsorted: </xsl:text>
				<xsl:value-of select="@name" />
				<xsl:text>.</xsl:text>
			</xsl:message>
		</xsl:if>
	</xsl:template>
	<xsl:template name="message-processing">
		<xsl:message>
			<xsl:text>Processing: </xsl:text>
			<xsl:value-of select="@name" />
			<xsl:text>.</xsl:text>
		</xsl:message>
	</xsl:template>
	
    <xsl:template name="page-template">
        <xsl:param name="page-title" />
        <html>
            <head>
                <title>Proof of <xsl:value-of select="$page-title" /></title>
                
                <!-- paste in the css -->
                <style type="text/css">
                    <xsl:value-of select="$doc-css/text()" disable-output-escaping="yes" />
                    <xsl:if test="$hilight = 'true'">
                        <xsl:value-of select="$doc-css/conditional[@name = 'hilight']/text()" disable-output-escaping="yes" />
                    </xsl:if>
                </style>
            </head>

            <body>
                <!-- apply-templates to whatever element has called this template -->
            	<xsl:apply-templates select="." mode="page-callback" />
            </body>
        </html>
    </xsl:template>
    

	<!--FUNCTIONS
		~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
	<xsl:function name="fn:pick-times" as="xs:string">
        <xsl:param name="method" as="xs:string" />
        <xsl:param name="time-start" as="xs:string" />
        <xsl:param name="time-end" as="xs:string" />
        
        <xsl:variable name="formatted-times" select="utils:format-times($time-start, $time-end)" as="xs:string" />
        
        <xsl:choose>
            <xsl:when test="($formatted-times = 'NA') and ($method = ('LEC','LAB'))">
                <xsl:value-of select="'TBA'" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$formatted-times" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fn:compare-comments" as="xs:boolean">
        <xsl:param name="classes" as="element()*" />
        
        <xsl:choose>
            <xsl:when test="count($classes) &lt; 1">
                <xsl:value-of select="false()" />
            </xsl:when>
            <xsl:when test="count($classes) = 1">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:when test="count($classes) != count($classes/comments)">
                <xsl:value-of select="false()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="comments" select="$classes/comments" as="element()*" />
                <xsl:variable name="base" select="normalize-space($comments[1]/text())" as="xs:string" />
                
                <xsl:value-of select="fn:compare-comments($base, $comments, 2)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fn:compare-comments" as="xs:boolean">
        <xsl:param name="base"     as="xs:string"  />
        <xsl:param name="comments" as="element()*" />
        <xsl:param name="index"    as="xs:integer" />
        
        <xsl:choose>
            <xsl:when test="count($comments) &lt; $index">
                <xsl:value-of select="true()" />
            </xsl:when>
            <xsl:when test="compare($base, normalize-space($comments[$index]/text())) = 0">
                <xsl:value-of select="fn:compare-comments($base, $comments, $index + 1)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
