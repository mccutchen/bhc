<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
	exclude-result-prefixes="xs utils fn">

	<!--=====================================================================
		Setup
		======================================================================-->
	<xsl:include href="output-utils.xsl" />
	<xsl:output
		method="xhtml"
		encoding="us-ascii"
		indent="yes"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />


	<!--=====================================================================
		Parameters
		======================================================================-->
	<!-- is this an "enrolling now" schedule? -->
	<xsl:param name="enrolling-now"/>	
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="output-type" as="xs:string" select="'web'"  />
	<xsl:variable name="ext"         as="xs:string" select="'aspx'" />
	
	
	<!--=====================================================================
		Processing Variables
		
		This section will need to change somewhat. Title and header info
		should be pulled from date based on all terms, not just the first.
		======================================================================-->
    <!-- multiple terms? -->
    <xsl:variable name="multiple-terms" select="count(//term) &gt; 1" />

	<!-- schedule title -->
	<xsl:variable name="schedule-title" select="fn:make-title(//term/@semester, //term/@year)" as="xs:string" />

    <!-- the text for the channel-header on each schedule page -->
    <xsl:variable name="channel-header" select="concat($schedule-title, ' Course Schedule')" />
	
	<!-- special methods (handled slightly differently) -->
	<xsl:variable name="special-methods" select="('INET', 'TVP', 'IDL', 'TV')" />
	
	
	<!--=====================================================================
		Additional Stylesheets
		======================================================================-->
    <xsl:include href="includes/page-template.xsl"  />
    <xsl:include href="includes/index-template.xsl" />




	<!--=====================================================================
		Initialization
		
		creates all result documents for the schedule
		======================================================================-->
    <xsl:template match="/">
        <xsl:apply-templates select="schedule" mode="init"/>
    </xsl:template>

    <xsl:template match="schedule[utils:has-classes(.)]" mode="init">
    	
    	<xsl:variable name="outdir" select="concat(utils:generate-outdir(term[1]/@year, utils:base-semester(term[1]/@semester)), '_web')" as="xs:string" />
    	
        <!-- full schedule index -->
        <xsl:result-document href="{$outdir}/index.{$ext}">
            <xsl:call-template name="page-template">
                <xsl:with-param name="page-title"    select="concat($schedule-title, ' Course Index')" />
            </xsl:call-template>
        </xsl:result-document>

        <xsl:apply-templates select="term" mode="init">
            <xsl:with-param name="page-type" select="'subindex'" as="xs:string" tunnel="yes" />
        	<xsl:with-param name="outdir" select="$outdir"  as="xs:string" />
        </xsl:apply-templates>
    </xsl:template>

	<xsl:template match="term[utils:has-classes(.)]" mode="init">
		<xsl:param name="outdir" as="xs:string" />
		
		<xsl:variable name="subdir" select="concat($outdir, '/', utils:make-url(@semester))" as="xs:string" />
		
		<!-- index page -->
		<xsl:result-document href="{$subdir}/index.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="concat(@semester, ' Course Index')" />
			</xsl:call-template>
		</xsl:result-document>
		
		<!-- subject pages -->
		<xsl:apply-templates select="descendant::subject" mode="init">
			<xsl:sort select="@name" data-type="text" />
			<xsl:with-param name="outdir" select="$subdir" as="xs:string" />
		</xsl:apply-templates>
		
		
		<!-- create special subjects -->
		<!-- distance learning -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="classes" select="descendant::type[@id = 'DL']/course[utils:has-classes(.)]" as="element()*" />
			<xsl:with-param name="title"   select="'Distance Learning'" as="xs:string"  />
			<xsl:with-param name="outdir"  select="$subdir"             as="xs:string"  />
		</xsl:call-template>
		<!-- flex term -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="classes" select="descendant::type[@id = ('FD','FN')]/course[utils:has-classes(.)]" as="element()*" />
			<xsl:with-param name="title"   select="'Flex Term'"  as="xs:string"  />
			<xsl:with-param name="outdir"  select="$subdir"             as="xs:string"  />
		</xsl:call-template>
		<!-- weekend -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="classes" select="descendant::type[@id = 'W']/course[utils:has-classes(.)]" as="element()*" />
			<xsl:with-param name="title"   select="'Weekend'"  as="xs:string"  />
			<xsl:with-param name="outdir"  select="$subdir"             as="xs:string"  />
		</xsl:call-template>
		<!-- weekend core curriculum -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="classes" select="descendant::type[@id = 'W']/descendant::course[@core-code and @core-code != '' and utils:has-classes(.)]" as="element()*" />
			<xsl:with-param name="title"   select="'Weekend Core Curriculum'"  as="xs:string"  />
			<xsl:with-param name="outdir"  select="$subdir"             as="xs:string"  />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="subject[utils:has-classes(.)]" mode="init">
		<xsl:param name="outdir" as="xs:string" />
		
			<xsl:result-document href="{$outdir}/{utils:make-url(@name)}.{$ext}">
				<xsl:call-template name="page-template">
					<xsl:with-param name="page-title" select="@name"/>
				</xsl:call-template>
			</xsl:result-document>
	</xsl:template>
	

	<!--=====================================================================
		Special Section Templates
		
		templates for creating special sections.
		======================================================================-->
	<xsl:template name="create-special-section">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="title"   as="xs:string"  />
		<xsl:param name="outdir"  as="xs:string"  />
		
		<!-- set up result documents -->
		<xsl:variable name="subdir"  select="concat($outdir, '/', utils:make-url($title))" as="xs:string" />
		
		<!-- write index -->
		<xsl:result-document href="{$subdir}/index.{$ext}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="concat($title, ' Course Index')"/>
			</xsl:call-template>
		</xsl:result-document>
		
		<!-- write subjects -->
		<!-- ugh. This'll be a chore -->
	</xsl:template>
	
	<!-- ==========================================================================
         Normal templates:

         These templates are responsible for building the subject page content. The
         index pages are built by the included indexer.xsl.
         =========================================================================== -->
	<xsl:template match="subject[utils:has-classes(.)]">

			<!-- if this is not supposed to display, display a warning -->
			<xsl:if test="@display = 'false'">
				<xsl:message>
					<xsl:text>!Warning! Unsorted subject: </xsl:text>
					<xsl:value-of select="@name" />
					<xsl:text>.</xsl:text>
				</xsl:message>
			</xsl:if>
			
			<div class="subject">
				<xsl:apply-templates select="comments"/>
				<xsl:call-template name="subject-summary"/>
				
				<!-- insert a list of the Core courses -->
				<xsl:call-template name="make-core-list"/>
				
				<!-- Output any stand-alone types before topics or
					subtopics.  This allows some special regroupings to
					have courses that aren't in a subgroup (topic, etc.)
					and courses that are in a subgroup.  See, e.g. EMS
					courses. -->
				<xsl:apply-templates select="type">
					<xsl:sort select="@sortkey" data-type="number"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="topic">
					<xsl:sort select="@sortkey" data-type="number"/>
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
				
				<xsl:if test="count(//term) &gt; 1">
					<!-- link to the other terms at the bottom of the page -->
					<xsl:call-template name="other-terms"/>
				</xsl:if>
			</div>
    </xsl:template>

	<xsl:template match="topic[utils:has-classes(.)] | subtopic[utils:has-classes(.)]">
			<div class="{name()}">
				<a name="{utils:make-url(@name)}"/>
				<h1 class="{name()}">
					<xsl:value-of select="@name"/>
				</h1>
				<xsl:apply-templates select="comments"/>
				
				<!-- output any stand-alone types before topics or subtopics -->
				<xsl:apply-templates select="type">
					<xsl:sort select="@sortkey" data-type="number"/>
				</xsl:apply-templates>
				
				<xsl:apply-templates select="subtopic">
					<xsl:sort select="@sortkey" data-type="number"/>
					<xsl:sort select="@name"/>
				</xsl:apply-templates>
			</div>
			<hr/>
    </xsl:template>

	<xsl:template match="type[utils:has-classes(.)]">
			<a name="{utils:make-url(@name)}"/>
			<div class="schedule-type-section {utils:make-url(@name)}">
				<h2 class="schedule-type"><xsl:value-of select="@name"/> Courses</h2>
				
				<xsl:apply-templates select="course">
					<xsl:sort select="@sortkey" data-type="number"/>
					<xsl:sort select="@rubric" />
					<xsl:sort select="@number" />
					<xsl:sort select="min(descendant::class/@section)"/>
				</xsl:apply-templates>
			</div>
			<hr/>
    </xsl:template>
	
	<xsl:template match="course[@core-name and @core-name != '']">
		<xsl:if test="utils:has-classes(.)">
			<div class="core-course">
				<xsl:next-match/>
			</div>
		</xsl:if>
    </xsl:template>

    <xsl:template match="course">
    	<!-- do not include classes with XX or ZZ for a topic code -->
    	<xsl:variable name="classes" select="class[utils:has-classes(.)]" as="element()*" />
    	
    	<!-- if there are courses to display -->
    	<xsl:if test="count($classes) &gt; 0">
    		<xsl:call-template name="group-comments">
    			<xsl:with-param name="classes" select="$classes" />
    			<xsl:with-param name="min-index" select="1" />
    			<xsl:with-param name="max-index" select="utils:max-comment-match($classes, 1) + 1" />
    		</xsl:call-template>
    	</xsl:if>
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
				<xsl:variable name="course" select="$classes/parent::course" as="element()" />
				<div class="course-section">
					<xsl:apply-templates select="$course" mode="setup" />
					<table border="0" cellpadding="10" cellspacing="0" class="class-list">
						<xsl:apply-templates select="$course" mode="output" />
						<xsl:apply-templates select="$classes[position() &gt;= $min-index and position() &lt; $max-index]" />
					</table>
					<div class="comments">
						<xsl:apply-templates select="$classes[$min-index]/comments">
							<xsl:sort select="@sortkey" data-type="number" />
							<xsl:sort select="@sortkey-days"  data-type="number" />
							<xsl:sort select="@sortkey-times" data-type="number" />
							<xsl:sort select="@sortkey-date"  data-type="number" />
							<xsl:sort select="@section"       data-type="number" />
						</xsl:apply-templates>
					</div>
					
					<div class="course-comments">
						<xsl:apply-templates select="$course/comments" />
					</div>
					
					<p class="back-to-top">
						<a href="#top">Back to the top</a>
					</p>
				</div>
				
				<xsl:call-template name="group-comments">
					<xsl:with-param name="classes" select="$classes" />
					<xsl:with-param name="min-index" select="$max-index" />
					<xsl:with-param name="max-index" select="utils:max-comment-match($classes, $max-index) + 1" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="course" mode="setup">
		<a name="{@rubric}-{@number}-{min(class/@section)}"/>
		<a name="{@rubric}-{@number}-{min(class/@section)}-{utils:make-url(@title-long)}"/>
		<h3>
			<xsl:value-of select="@title-long"/>
			<xsl:if test="@core-name and @core-name != ''">
				<span class="core">&#160;&#8226;&#160;Core Curriculum</span>
			</xsl:if>
		</h3>
	</xsl:template>
	<xsl:template match="course" mode="output">
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
	</xsl:template>
	
	<xsl:template match="class">
        <tr>
            <td class="course-number"><xsl:call-template name="class-number"/></td>
            <td class="reg-number"><xsl:value-of select="@synonym"/></td>
            <td class="credit-hours"><xsl:value-of select="ancestor::course/@credit-hours"/></td>
            <td class="dates">
                <xsl:value-of select="utils:format-dates(@date-start, @date-end)" />
                <xsl:apply-templates select="@weeks"/>
            </td>
        	
        	<!-- fill out the rest of the info -->
            <xsl:apply-templates select="meeting">
            	<xsl:sort select="@sortkey"        data-type="number" />
            	<xsl:sort select="@sortkey-method" data-type="number" />
            	<xsl:sort select="@sortkey-days"   data-type="number" />
            	<xsl:sort select="@sortkey-times"  data-type="number" />
            </xsl:apply-templates>
        </tr>
    </xsl:template>

	<xsl:template match="meeting[@method = ('LEC','')]">
		<td class="days"><xsl:value-of select="@days" /></td>
		<td class="times"><xsl:value-of select="utils:format-times(@time-start, @time-end)" /></td>
		<td class="method"><xsl:value-of select="@method" /></td>
		<td class="room"><xsl:value-of select="@room" /></td>
		<td class="faculty"><xsl:if test="not(faculty)">Staff</xsl:if><xsl:apply-templates select="faculty" /></td>
	</xsl:template>
	
	<xsl:template match="meeting[@method = 'INET']">
		<td class="days">NA</td>
		<td class="times">NA</td>
		<td class="method">OL</td>
		<td class="room"><xsl:if test="not(@topic-code) or @topic-code = ''">OL</xsl:if><xsl:value-of select="parent::class/@topic-code" /></td>
		<td class="faculty"><xsl:if test="not(faculty)">Staff</xsl:if><xsl:apply-templates select="faculty" /></td>
	</xsl:template>
	
	<xsl:template match="meeting[@method = 'LAB' and @room = 'INET']">
		<tr class="extra">
			<td><xsl:text>&#160;</xsl:text></td>
			<td><xsl:text>&#160;</xsl:text></td>
			<td><xsl:text>&#160;</xsl:text></td>
			<td><xsl:text>&#160;</xsl:text></td>
			<td class="days">TBA</td>
			<td class="times">TBA</td>
			<td class="method"><xsl:value-of select="@method" /></td>
			<td class="room">OL</td>
			<td class="faculty"><xsl:if test="not(faculty)">Staff</xsl:if><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="meeting">
		<tr class="extra">
			<td><xsl:text>&#160;</xsl:text></td>
			<td><xsl:text>&#160;</xsl:text></td>
			<td><xsl:text>&#160;</xsl:text></td>
			<td><xsl:text>&#160;</xsl:text></td>
			<td class="days"><xsl:value-of select="@days"/></td>
			<td class="times"><xsl:value-of select="utils:format-times(@time-start, @time-end)"/></td>
			<td class="method"><xsl:value-of select="@method"/></td>
			<td class="room"><xsl:value-of select="@room"/></td>
			<td class="faculty"><xsl:if test="not(faculty)">Staff</xsl:if><xsl:apply-templates select="faculty" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="faculty">
		<xsl:value-of select="@name-last" />
		<xsl:if test="position() != last()"><xsl:value-of select="', '" /></xsl:if>
	</xsl:template>
	
	<xsl:template name="class-number">
        <xsl:if test="ancestor::course/@core-name and ancestor::course/@core-name != ''">
            <span>+&#160;</span>
        </xsl:if>
        <a
            href="https://www1.dcccd.edu/catalog/coursedescriptions/detail.cfm?course={../@rubric}&amp;number={../@number}&amp;loc=2"
            target="_blank">
            <xsl:value-of select="../@rubric"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="../@number"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="@section"/>
        </a>
    </xsl:template>

    <xsl:template match="class/@weeks"> (<xsl:value-of select="."/>&#160;Wks) </xsl:template>

    <xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@weeks"
        priority="1">
        <!-- don't output the number of weeks for Senior Adult courses -->
    </xsl:template>

    <xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@days">
        <!-- spell out the days of the week for Senior Adult courses -->
        <xsl:value-of select="utils:senior-adult-days(.)"/>
    </xsl:template>

    <xsl:template match="class[@method = $special-methods]/@method">
        <xsl:variable name="description">
            <xsl:choose>
                <xsl:when test=". = 'INET'">IDL courses are individual study courses that use print
                    materials and required activities related to course topics. This self-paced
                    course requires a faculty-to-student agreement contract for specific work
                    assignments and/or projects. Additional requirements include a student-faculty
                    orientation, written assignments, and tests. Contact your instructor for more
                    information.</xsl:when>
                <xsl:when test=". = 'TV'">Also known as INET, online courses are delivered using
                    only computers and multimedia components. Students are required to have Internet
                    access and the latest version of a browser (Netscape or Internet Explorer). Some
                    online courses may require additional components such as CDs, and
                    audio/streaming video.</xsl:when>
                <xsl:when test=". = 'TVP'">Telecourses require the viewer to access a local TV cable
                    channel, or a VHS format videocassette player to record the programs. Videotapes
                    may be leased from our online bookstore, viewed on campus in the media center,
                    available on CD-ROM and audio/ streaming video.</xsl:when>
                <xsl:when test=". = 'IDL'">TVP courses are delivered using a combination of
                    multimedia online computer activities and video programs. Students are required
                    to have Internet access and the latest version of a browser (Netscape or
                    Internet Explorer). Video programs require the viewer to access a local TV cable
                    channel, or a VHS format videocassette player to record the programs. Videotapes
                    may also be leased from our online bookstore, viewed on campus in the media
                    center, available on CDs and audio/ streaming video.</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <a href="/course-schedules/credit/distance-learning/#formats" title="{$description}"
            rel="special-format">
            <xsl:value-of select="."/>
        </a>
    </xsl:template>




    <!-- ==========================================================================
     Comments

     Comments can have a small subset of HTML elements embedded within them,
     as well as the special elements <url> and <email>.  The set of legal
     HTML for comments is:

     h1, p, b, i, table, tr, td
=========================================================================== -->
    <xsl:template match="comments">
        <div class="comments">
            <xsl:choose>
                <xsl:when test="not(p)">
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template
        match="comments//h1 | comments//p | comments//b | comments//i | comments//table | comments//tr | comments//td | comments//@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="comments//h1" priority="1">
        <h3>
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="url">
        <xsl:variable name="address">
            <xsl:if test="substring(current(), 1, 7) != 'http://'">http://</xsl:if>
            <xsl:value-of select="current()"/>
        </xsl:variable>
        <a href="{$address}" target="_blank">
            <xsl:value-of select="current()"/>
        </a>
    </xsl:template>

    <xsl:template match="email">
        <a href="mailto:{current()}">
            <xsl:value-of select="current()"/>
        </a>
    </xsl:template>



    <!-- ==========================================================================
     Named templates

     Specialty templates to create the division-info and the HTML template
     for each page.
=========================================================================== -->
    <xsl:template name="subject-summary">
    	
    	<!-- processing vars -->
    	<xsl:variable name="topics" select="topic[@name != '' and count(descendant::class[@topic-code != 'XX' and @topic-code != 'ZZ']) &gt; 0]" as="element()*" />
    	<xsl:variable name="types"  select="type[@name != '' and count(descendant::class[@topic-code != 'XX' and @topic-code != 'ZZ']) &gt; 0]" as="element()*" />

    	<xsl:if test="$types or $topics">
            <div class="summary">
                <xsl:choose>
                    <xsl:when test="$topics">
                        <p>Course topics in this subject:</p>
                        <ul>
                            <xsl:for-each select="$topics">
                                <xsl:sort select="@name"/>
                                <li>
                                    <a href="#{utils:make-url(@name)}">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:when test="$types">
                        <p>Course types offered in this subject:</p>
                        <ul>
                        	<xsl:for-each select="$types">
                                <xsl:sort select="@sortkey"/>
                                <li>
                                    <a href="#{utils:make-url(@name)}">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="make-core-list">
        <xsl:variable name="core-courses"
            select="descendant::course[@core-component and @core-component != '']"/>
        <xsl:if test="$core-courses">
            <xsl:variable name="core-component"
                select="lower-case((descendant::course/@core-component)[1])"/>
            <div class="core-list">
                <p> The following courses <xsl:if test="$core-component = 'other'">in this
                    subject</xsl:if> are part of the <xsl:if test="$core-component != 'other'"
                            ><xsl:value-of select="$core-component"/> component of the </xsl:if>
                    <a href="/course-schedules/credit/core/">Core Curriculum</a>: <br/>
                    <xsl:for-each-group select="$core-courses" group-by="@rubric">
                        <xsl:sort select="@rubric"/>

                        <xsl:for-each-group select="current-group()" group-by="@number">
                            <xsl:sort select="@number"/>
                            <a href="#{@rubric}-{@number}-{class[1]/@section}">
                                <xsl:value-of select="concat(@rubric, ' ', @number)"/>
                            </a>

                            <xsl:if test="position() != last()">
                                <xsl:value-of select="', '"/>
                            </xsl:if>
                        </xsl:for-each-group>

                        <xsl:if test="position() != last()">
                            <xsl:value-of select="', '"/>
                        </xsl:if>
                    </xsl:for-each-group>
                </p>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="other-terms">
        <p>If you don't find the course you're looking for in this term, try <xsl:choose>
                <xsl:when test="ancestor::term/@name = 'Summer I/May Term'">
                    <a href="../summer_i/">Summer I</a> or <a href="../summer_ii/">Summer II</a>. </xsl:when>
                <xsl:when test="ancestor::term/@name = 'Summer I'">
                    <a href="../summer_i_may_term/">Summer I/May Term</a> or <a href="../summer_ii/"
                        >Summer II</a>. </xsl:when>
                <xsl:when test="ancestor::term/@name = 'Summer II'">
                    <a href="../summer_i_may_term/">Summer I/May Term</a> or <a href="../summer_i/"
                        >Summer I</a>. </xsl:when>
            </xsl:choose>
        </p>
    </xsl:template>
	
	<xsl:template name="br">
		<xsl:text disable-output-escaping="yes">&lt;br /&gt;</xsl:text>
	</xsl:template>
	
	<!--
		Functions
	-->
	<xsl:function name="fn:make-title" as="xs:string">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />
		
		<xsl:variable name="term-list" select="fn:make-term-list($semesters, $years)" as="xs:string" />
		<xsl:variable name="enrolling" select="if ($enrolling-now and $enrolling-now != '') then 'Enrolling Now&#8212;' else ''" as="xs:string" />
		
		<xsl:value-of select="concat($enrolling, $term-list, ' Credit')" />
	</xsl:function>
	
	<xsl:function name="fn:make-term-list" as="xs:string">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />
		
		<xsl:choose>
			<!-- when invalid data passed -->
			<xsl:when test="count($semesters) != count($years) or count($semesters) = 0">
				<xsl:value-of select="'Invalid Semester List'" />
			</xsl:when>
			<!-- there is only one semester -->
			<xsl:when test="count($semesters) = 1">
				<xsl:value-of select="concat($semesters[1], ' ', $years[1])" />
			</xsl:when>
			<!-- otherwise, go deeper -->
			<xsl:otherwise>
				<xsl:value-of select="fn:make-term-list($semesters, $years, 1, '')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:make-term-list" as="xs:string">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />
		<xsl:param name="index"     as="xs:integer" />
		<xsl:param name="string"    as="xs:string" />

		<xsl:choose>
			<!-- if we're done -->
			<xsl:when test="$index &gt; count($semesters)">
				<xsl:value-of select="$string" />
			</xsl:when>
			<!-- we're not dealing with summer -->
			<xsl:when test="not(contains('Summer', $semesters[$index]))">
				<xsl:variable name="string-new" select="concat(', ', $semesters[$index], ' ', $years[$index])" as="xs:string" />
				<xsl:value-of select="fn:make-term-list($semesters, $years, $index + 1, concat($string, $string-new))" />
			</xsl:when>
			<!-- we're dealing with summer, but it is the first one in the given year -->
			<xsl:when test="not(contains($string, concat('Summer ', $years[$index])))">
				<xsl:variable name="string-new" select="concat(', Summer ', $years[$index])" as="xs:string" />
				<xsl:value-of select="fn:make-term-list($semesters, $years, $index + 1, concat($string, $string-new))" />
			</xsl:when>
			<!-- we're dealing with summer, and it is NOT the first one in the given year -->
			<xsl:otherwise>
				<xsl:value-of select="fn:make-term-list($semesters, $years, $index + 1, $string)" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>

</xsl:stylesheet>
