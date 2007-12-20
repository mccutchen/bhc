<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	exclude-result-prefixes="xs utils">
	
	<!--=====================================================================
		Description
		
		This stylesheet handles all of the tasks associated with displaying
		a subject's courses.
		======================================================================-->
	
	<!--=====================================================================
		Content
		
		Creates the subject page content w/links, etc.
		======================================================================-->
	<xsl:template match="subject" mode="page">
		<!-- comments -->
		<xsl:apply-templates select="comments" />
		
		<!-- summary -->
		<xsl:call-template name="make-summary" />
		
		<!-- core list -->
		<xsl:call-template name="make-core" />
		
		
		<!-- stand-alone types -->
		<xsl:apply-templates select="type" />
		
		<!-- topics -->
		<xsl:apply-templates select="topic" />
	</xsl:template>
	
	<xsl:template match="topic">
		<div class="topic">
			<a name="{utils:make-url(@name)}"></a>
			<h1 class="topic"><xsl:value-of select="@name" /></h1>
			
			<!-- comments -->
			<xsl:apply-templates select="comments" />
			
			<!-- types -->
			<xsl:apply-templates select="type" />
			
			<!-- subtopics -->
			<xsl:apply-templates select="subtopic" />
		</div>
	</xsl:template>
	
	<xsl:template match="subtopic">
		<div class="subtopic">
			<a name="{utils:make-url(@name)}"></a>
			<h1 class="subtopic"><xsl:value-of select="@name" /></h1>
			
			<!-- comments -->
			<xsl:apply-templates select="comments" />
			
			<!-- types -->
			<xsl:apply-templates select="type" />
		</div>
	</xsl:template>
	
	<xsl:template match="type">
		<a name="{utils:make-url(@name)}"></a>
		<div class="schedule-type-section {utils:make-url(@name)}">
			<h2 class="schedule-type"><xsl:value-of select="@name" /> Courses</h2>
			
			<xsl:apply-templates select="course" />
		</div>
	</xsl:template>
	
	<xsl:template match="course[@core-name]">
		<div class="core-course">
			<xsl:next-match />
		</div>
	</xsl:template>
	
	<xsl:template match="course">
		<div class="course-section">
			<a name="{@rubric}-{@number}-{min(class/@section)}"></a>
			<a name="{@rubric}-{@number}-{min(class/@section)}-{utils:make-url(@title-long)}"></a>
			<h3><xsl:value-of select="@title-long" />
				<xsl:if test="@core-name"> <span class="core">&#160;&#8226;&#160;Core Curriculum</span></xsl:if></h3>
			<xsl:apply-templates select="comments" />
			
			<!-- stick the comments together if they are identical -->
			<xsl:variable name="classes" select="class" as="element()*" />
			<xsl:call-template name="group-comments">
				<xsl:with-param name="classes" select="$classes" />
				<xsl:with-param name="min-index" select="1" />
				<xsl:with-param name="max-index" select="utils:max-comment-match($classes, 1) + 1" />
			</xsl:call-template>
			
			<p class="back-to-top"><a href="#top">Back to the top</a></p>
			<xsl:call-template name="br" />
		</div>
	</xsl:template>
	
	<xsl:template name="group-comments">
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
				<xsl:apply-templates select="." mode="output">
					<xsl:with-param name="classes" select="$classes[position() &gt;= $min-index and position() &lt; $max-index]" />
				</xsl:apply-templates>
				<xsl:apply-templates select="comments" />
				<xsl:if test="$max-index - 1 &lt; count($classes)"><xsl:call-template name="br" /></xsl:if>
				
				<xsl:call-template name="group-comments">
					<xsl:with-param name="classes" select="$classes" />
					<xsl:with-param name="min-index" select="$max-index" />
					<xsl:with-param name="max-index" select="utils:max-comment-match($classes, $max-index) + 1" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="course" mode="output">
		<xsl:param name="classes" as="element()*" />
		
		<table border="0" cellpadding="0" cellspacing="0" class="class-list">
			<tr>
				<th class="course-number">Course #</th>
				<th class="reg-number">Reg. #</th>
				<th class="credit-hours">Credit<xsl:call-template name="br" />Hrs.</th>
				<th class="dates">Dates</th>
				<th class="days">Days</th>
				<th class="times">Times</th>
				<th class="format">Format</th>
				<th class="room">Room</th>
				<th class="instructor">Instructor</th>
			</tr>
			
			<!-- class info -->
			<xsl:apply-templates select="$classes" />
		</table>
		<xsl:apply-templates select="$classes[1]/comments" />
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:apply-templates select="meeting" />
	</xsl:template>
	
	<xsl:template match="class" mode="display">
		<xsl:variable name="link" select="'https://www1.dcccd.edu/catalogue/coursedescriptions/detail.cfm'" as="xs:string" />
		<xsl:variable name="cid"  select="concat(../@rubric, '&#160;', ../@number, '-', @section)"        as="xs:string" />
		
		<td class="course-number">
			<xsl:if test="parent::course/@core-code"><span>+&#160;</span></xsl:if>
			<a href="{$link}?course={../@rubric}&amp;number={../@number}&amp;loc=2" target="_blank"><xsl:value-of select="$cid" /></a>
		</td>
		<td class="reg-number"><xsl:value-of select="@synonym" /></td>
		<td class="credit-hours"><xsl:value-of select="../@credit-hours" /></td>
		<td class="dates">
			<xsl:value-of select="utils:format-dates(@date-start, @date-end)" />&#160;
			<xsl:apply-templates select="@weeks" />
		</td>
	</xsl:template>
	
	<xsl:template match="meeting[@method = ('LEC','')]">
		<tr>
			<xsl:apply-templates select="parent::class" mode="display" />
			<td class="days"><xsl:apply-templates select="@days" /></td>
			<xsl:variable name="times" select="utils:format-times(@time-start, @time-end)" as="xs:string" />
			<td class="times"><xsl:value-of select="if ($times = 'NA' and @room != 'INET') then 'TBA' else $times" /></td>
			<td class="format"><xsl:apply-templates select="@method" /></td>
			<td class="room"><xsl:value-of select="@room" /></td>
			<td class="faculty"><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	<xsl:template match="meeting[@method = ('INET')]">
		<tr>
			<xsl:apply-templates select="parent::class" mode="display" />
			<td class="days">NA</td>
			<td class="times">NA</td>
			<td class="format"><xsl:apply-templates select="@method" /></td>
			<td class="room"><xsl:value-of select="@room" /></td>
			<td class="faculty"><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="meeting[@method = ('LAB')]">
		<tr class="extra">
			<td>&#160;</td>
			<td>&#160;</td>
			<td>&#160;</td>
			<td>&#160;</td>
			<td class="days"><xsl:apply-templates select="@days" /></td>
			<xsl:variable name="times" select="utils:format-times(@time-start, @time-end)" as="xs:string" />
			<td class="times"><xsl:value-of select="if ($times = 'NA') then 'TBA' else $times" /></td>
			<td class="format"><xsl:apply-templates select="@method" /></td>
			<td class="room"><xsl:value-of select="@room" /></td>
			<td class="faculty"><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	<xsl:template match="meeting">
		<tr class="extra">
			<td>&#160;</td>
			<td>&#160;</td>
			<td>&#160;</td>
			<td>&#160;</td>
			<td class="days"><xsl:apply-templates select="@days" /></td>
			<td class="times"><xsl:value-of select="utils:format-times(@time-start, @time-end)" /></td>
			<td class="format"><xsl:apply-templates select="@method" /></td>
			<td class="room"><xsl:value-of select="if (@method = 'COOP' and @room = 'TBA') then 'NA' else @room" /></td>
			<td class="faculty"><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="class/@weeks">
		(<xsl:value-of select="." />&#160;Wks)
	</xsl:template>
	
	<xsl:template match="meeting[starts-with(ancestor::subject/@name, 'Senior Adult')]/@weeks" priority="1">
		<!-- don't output the number of weeks for Senior Adult courses -->
	</xsl:template>
	
	<xsl:template match="meeting[starts-with(ancestor::subject/@name, 'Senior Adult')]/@days">
		<!-- spell out the days of the week for Senior Adult courses -->
		<xsl:value-of select="utils:senior-adult-days(.)" />
	</xsl:template>
	
	<xsl:template match="meeting[@method = 'LAB' and @room = 'INET']/@days" priority="2">
		<xsl:value-of select="'TBA'" />
	</xsl:template>
	
	<xsl:template match="meeting[@method = ('INET', 'TV', 'TVP', 'IDL')]/@method">
		<xsl:variable name="description">
			<xsl:choose>
				<xsl:when test=". = 'INET'">IDL courses are individual study courses that use print materials and required activities related to course topics. This self-paced course requires a faculty-to-student agreement contract for specific work assignments and/or projects. Additional requirements include a student-faculty orientation, written assignments, and tests. Contact your instructor for more information.</xsl:when>
				<xsl:when test=". = 'TV'">Also known as INET, online courses are delivered using only computers and multimedia components. Students are required to have Internet access and the latest version of a browser (Netscape or Internet Explorer). Some online courses may require additional components such as CDs, and audio/streaming video.</xsl:when>
				<xsl:when test=". = 'TVP'">Telecourses require the viewer to access a local TV cable channel, or a VHS format videocassette player to record the programs. Videotapes may be leased from our online bookstore, viewed on campus in the media center, available on CD-ROM and audio/ streaming video.</xsl:when>
				<xsl:when test=". = 'IDL'">TVP courses are delivered using a combination of multimedia online computer activities and video programs. Students are required to have Internet access and the latest version of a browser (Netscape or Internet Explorer). Video programs require the viewer to access a local TV cable channel, or a VHS format videocassette player to record the programs. Videotapes may also be leased from our online bookstore, viewed on campus in the media center, available on CDs and audio/ streaming video.</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<a href="/course-schedules/credit/distance-learning/#formats" title="{$description}" rel="special-format"><xsl:value-of select="." /></a>
	</xsl:template>
	
	<xsl:template match="faculty">
		<xsl:value-of select="@name-last" />
	</xsl:template>
	
	
	<!-- ==========================================================================
		Comments
		
		Comments can have a small subset of HTML elements embedded within them,
		as well as the special elements <url> and <email>.  The set of legal
		HTML for comments is:
		
		h1, p, b, i, table, tr, td
		=========================================================================== -->
	<xsl:template match="comments[parent::course]" priority="2">
		<div class="comments course-comments">
			<xsl:next-match />
		</div>
	</xsl:template>
	<xsl:template match="comments[parent::class]" priority="2">
		<div class="comments class-comments">
			<xsl:next-match />
		</div>
	</xsl:template>
	<xsl:template match="comments[not(parent::class or parent::course)]" priority="2">
		<div class="comments">
			<xsl:next-match />
		</div>
	</xsl:template>
	<xsl:template match="comments[not(p)]">
		<p>
			<xsl:apply-templates />
		</p>
	</xsl:template>
	<xsl:template match="comments">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="comments//h1 | comments//p | comments//b | comments//i | comments//table | comments//tr | comments//td | comments//@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="comments//h1" priority="1">
		<h3><xsl:apply-templates /></h3>
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
	
	
	<!--=====================================================================
		Make Templates
		
		Creates specific portions of the page
		======================================================================-->
	<xsl:template name="preview-special-notice">
		<p class="special-notice">
			<xsl:text>Registration for continuing students begins April 18.</xsl:text>
			<xsl:call-template name="br" />
			<xsl:text>Registration for new students begins April 24.</xsl:text>
		</p>
	</xsl:template>
	






<!-- ==========================================================================
     Named templates

     Specialty templates to create the division-info and the HTML template
     for each page.
=========================================================================== -->
    <xsl:template name="make-summary">
        <xsl:if test="type or topic">
            <div class="summary">
                <xsl:choose>
                    <xsl:when test="topic">
                        <p>Course topics in this subject:</p>
                        <ul>
                            <xsl:for-each select="topic[@name != 'none']">
                                <xsl:sort select="@name" />
                                <li><a href="#{utils:make-url(@name)}"><xsl:value-of select="@name" /></a></li>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:when test="type">
                        <p>Course types offered in this subject:</p>
                        <ul>
                            <xsl:for-each select="type">
                                <xsl:sort select="@sortkey" />
                                <li><a href="#{utils:make-url(@name)}"><xsl:value-of select="@name" /></a></li>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="make-core">
        <xsl:variable name="core-courses" select="descendant::course[@core-name]" />
        <xsl:if test="$core-courses">
            <xsl:variable name="core-name" select="lower-case((descendant::course/@core-name)[1])" />
            <div class="core-list">
                <p>
                    The following courses
                    <xsl:if test="$core-name = 'other'">in this subject</xsl:if>
                    are part of the
                    <xsl:if test="$core-name != 'other'"><xsl:value-of select="$core-name" /> component of the </xsl:if>
                    <a href="/course-schedules/credit/core/">Core Curriculum</a>:
                    <xsl:call-template name="br" />

                    <xsl:for-each-group select="$core-courses" group-by="@rubric">
                        <xsl:sort select="@rubrik" />

                        <xsl:for-each-group select="current-group()" group-by="@number">
                            <xsl:sort select="@number" />
                            <a href="#{@rubric}-{@number}-{class[1]/@section}">
                                <xsl:value-of select="concat(@rubric, ' ', @number)" />
                            </a>

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
        </xsl:if>
    </xsl:template>


    <xsl:template name="other-terms">
        <p>If you don't find the course you're looking for in this term, try
        <xsl:choose>
            <xsl:when test="ancestor::term/@name = 'May Term'">
                <a href="../summer_i/">Summer I</a> or <a href="../summer_ii/">Summer II</a>.
            </xsl:when>
            <xsl:when test="ancestor::term/@name = 'Summer I'">
                <a href="../may_term/">May Term</a> or <a href="../summer_ii/">Summer II</a>.
            </xsl:when>
            <xsl:when test="ancestor::term/@name = 'Summer II'">
                <a href="../may_term/">May Term</a> or <a href="../summer_i/">Summer I</a>.
            </xsl:when>
        </xsl:choose>
        </p>
    </xsl:template>

</xsl:stylesheet>
