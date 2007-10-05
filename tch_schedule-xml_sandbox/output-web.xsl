<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils" exclude-result-prefixes="xs utils">

    <xsl:output method="xhtml" encoding="us-ascii" indent="yes" omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>

    <!-- include some handy utility functions -->
    <xsl:include href="output-utils.xsl"/>

    <!-- Parameters -->
    <!-- is this an "enrolling now" schedule? -->
    <xsl:param name="enrolling-now"/>
    
    <!-- Global Variables -->
    <!-- the schedule title -->
    <xsl:variable name="schedule-name"  select="concat(//term[1]/@semester, ' ', //term[1]/@year, ' Credit')" />
    <xsl:variable name="schedule-title" select="if($enrolling-now and string-length($enrolling-now) &gt; 0) then concat('Enrolling Now&#8212;', $schedule-name) else $schedule-name" />

    <!-- the text for the channel-header on each schedule page -->
    <xsl:variable name="channel-header" select="concat($schedule-title, ' Course Schedule')" />

    <!-- output file specifications -->
    <xsl:variable name="output-directory" select="'output/web'" />
    <xsl:variable name="output-extension" select="'.aspx'"      />
    
    <!-- multiple terms? -->
    <xsl:variable name="multiple-terms" select="count(//term) &gt; 1" />

    <!-- Include other required stylesheets -->
    <xsl:include href="includes/page-template.xsl" />
    <xsl:include href="includes/indexer.xsl"       />




    <!-- ========================================================================== -->
    <!-- Initialization:                                                            -->
    <!-- This section creates all of the result documents for this schedule by      -->
    <!--    using the xsl:result-document facility.                                 -->
    <!-- ========================================================================== -->
    <xsl:template match="/">
        <xsl:apply-templates select="schedule" mode="init"/>
    </xsl:template>

    <xsl:template match="schedule" mode="init">
        <!-- full schedule index -->
        <xsl:result-document href="{$output-directory}/index{$output-extension}">
            <xsl:call-template name="page-template">
                <xsl:with-param name="page-title" select="concat($schedule-title, ' Course Index')" />
            </xsl:call-template>
        </xsl:result-document>

        <xsl:apply-templates select="term" mode="init">
            <xsl:with-param name="page-type" select="'subindex'" tunnel="yes" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="term" mode="init">
        <xsl:param name="term-name" select="concat(@year, ' ', @semester)" />
        
        <!-- ideally, this won't mattter
        <xsl:if test="count(//term) &gt; 1"> -->
            <xsl:result-document
                href="{$output-directory}/{utils:make-url(@semester)}/index{$output-extension}">
                <xsl:call-template name="page-template">
                    <xsl:with-param name="page-title" select="concat(@semester, ' Course Index')" />
                </xsl:call-template>
            </xsl:result-document>
        <!-- </xsl:if> -->

        <!-- special sections no longer exist -->
        <!-- special-section indexes
        <xsl:apply-templates select="special-section[not(minimester)] | special-section/minimester" mode="init">
            <xsl:with-param name="page-type" tunnel="yes">subindex</xsl:with-param>
        </xsl:apply-templates> -->

        <!-- subject pages -->
        <xsl:apply-templates select="descendant::subject" mode="init">
            <xsl:with-param name="term-name" select="$term-name" />
        </xsl:apply-templates>
    </xsl:template>

    <!-- special sections no longer exist
    <xsl:template match="special-section | minimester" mode="init">
        <xsl:variable name="path-root">
            <xsl:value-of select="concat($output-directory, '/')"/>
            <xsl:if test="$multiple-terms">
                <xsl:value-of select="concat(utils:make-url(ancestor::term/@name), '/')"/>
            </xsl:if>
            <xsl:value-of select="concat(utils:make-url(@name), '/')"/>
        </xsl:variable>

        <xsl:result-document href="{$path-root}index{$output-extension}">
            <xsl:call-template name="page-template">
                <xsl:with-param name="page-title"><xsl:value-of select="@name"/> Course Index</xsl:with-param>
                <xsl:with-param name="page-type" tunnel="yes">subindex</xsl:with-param>
                <xsl:with-param name="path-root" select="$path-root" tunnel="yes"/>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template> -->

    <xsl:template match="subject" mode="init">
        <xsl:param name="term-name" />
        
        <xsl:variable name="path-root">
            <xsl:value-of select="''"/>
            <!-- ideally, this won't matter
           <xsl:if test="$multiple-terms"> -->
                <xsl:value-of select="concat(utils:make-url(ancestor::term/@semester), '/')"/>
            <!-- </xsl:if> -->
            <xsl:choose>
                <!-- special sections don't exist
                <xsl:when test="ancestor::special-section and not(ancestor::minimester)">
                    <xsl:value-of
                        select="concat(ancestor::special-section/utils:make-url(@name), '/')"/>
                        </xsl:when> -->
                
                <!-- DEV NOTE: minimesters are no longer seperate elements, so this will have to be modified -->
                <xsl:when test="ancestor::minimester">
                    <xsl:value-of select="concat(ancestor::minimester/utils:make-url(@name), '/')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:result-document
            href="{$output-directory}/{$path-root}{utils:make-url(@name)}{$output-extension}">
            <xsl:call-template name="page-template">
                <xsl:with-param name="page-title" select="@name"/>
                <xsl:with-param name="path-root" select="$path-root" tunnel="yes"/>
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>




    <!-- ==========================================================================
         Normal templates:

         These templates are responsible for building the subject page content. The
         index pages are built by the included indexer.xsl.
         =========================================================================== -->
    <xsl:template match="subject">
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
                <!-- I don't know of a topic sort order
                    <xsl:sort select="@sortkey" data-type="number"/> -->
                <xsl:sort select="@name"/>
            </xsl:apply-templates>
            
            <!-- special-sections no longer exist -->
            <!-- the type-specific special sections (like Distance
                 Learning) don't have <type> elements, so this will
                 apply to their courses.
            <xsl:apply-templates select="group | course">
                <xsl:sort select="@sortkey" data-type="number"/>
                <xsl:sort select="@default-sortkey"/>
                <xsl:sort select="min(descendant::class/@section)"/>
            </xsl:apply-templates> -->

            <xsl:if test="count(//term) &gt; 1">
                <!-- link to the other terms at the bottom of the page -->
                <xsl:call-template name="other-terms"/>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="topic | subtopic">
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
                <!-- I don't know of a subtopic sort order
                    <xsl:sort select="@sortkey" data-type="number"/> -->
                <xsl:sort select="@name"/>
            </xsl:apply-templates>

            <!-- special-sections no longer exist -->
            <!-- the type-specific special sections (like Distance Learning) don't have
                 <type> elements, so this will apply to their courses.
            <xsl:apply-templates select="group | course">
                <xsl:sort select="@sortkey" data-type="number"/>
                <xsl:sort select="@default-sortkey"/>
                <xsl:sort select="min(descendant::class/@section)"/>
            </xsl:apply-templates> -->
        </div>
        <hr/>
    </xsl:template>

    <xsl:template match="type">
        <a name="{utils:make-url(@name)}"/>
        <div class="schedule-type-section {utils:make-url(@name)}">
            <h2 class="schedule-type"><xsl:value-of select="@name"/> Courses</h2>

            <!-- no group elements
            <xsl:apply-templates select="group | course">-->
            <xsl:apply-templates select="course">
                <!-- I don't know of a course sort order
                    <xsl:sort select="@sortkey" data-type="number"/> -->
                <xsl:sort select="@rubric" />
                <xsl:sort select="@number" />
                <xsl:sort select="min(descendant::class/@section)"/>
            </xsl:apply-templates>
        </div>
        <hr/>
    </xsl:template>

    <!-- no group elements
    <xsl:template match="group">
        <div class="group">
            <xsl:apply-templates select="course">
                <xsl:sort select="@sortkey" data-type="number"/>
                <xsl:sort select="@default-sortkey"/>
                <xsl:sort select="min(descendant::class/@section)"/>
            </xsl:apply-templates>
        </div>
    </xsl:template> -->

    <xsl:template match="course[@core-name and @core-name != '']">
        <div class="core-course">
            <xsl:next-match/>
        </div>
    </xsl:template>

    <xsl:template match="course">
        <div class="course-section">
            <a name="{@rubric}-{@number}-{min(class/@section)}"/>
            <a name="{@rubric}-{@number}-{min(class/@section)}-{utils:make-url(@title-long)}"/>
            <h3>
                <xsl:value-of select="@title-long"/>
                <xsl:if test="@core-name and @core-name != ''">
                    <span class="core">&#160;&#8226;&#160;Core Curriculum</span>
                </xsl:if>
            </h3>
            <table border="0" cellpadding="10" cellspacing="0" class="class-list">
                <tr>
                    <th class="course-number">Course #</th>
                    <th class="reg-number">Reg. #</th>
                    <th class="credit-hours">Credit<br/>Hrs.</th>
                    <th class="dates">Dates</th>
                    <th class="days">Days</th>
                    <th class="times">Times</th>
                    <th class="format">Format</th>
                    <th class="room">Room</th>
                    <th class="instructor">Instructor</th>
                </tr>
                <xsl:apply-templates select="class">
                    <xsl:sort select="ancestor::course/@rubric" data-type="number" />
                    <xsl:sort select="ancestor::course/@number" data-type="number" />
                    <xsl:sort select="@sortkey-days"            data-type="number" />
                    <!-- I haven't ported these yet
                    <xsl:sort select="@sortkey-date" data-type="number"/>
                    <xsl:sort select="@sortkey-time" data-type="number" order="ascending"/> -->
                    <xsl:sort select="@section" />
                </xsl:apply-templates>
            </table>
            <xsl:apply-templates select="comments" />
            <p class="back-to-top">
                <a href="#top">Back to the top</a>
            </p>
        </div>
    </xsl:template>

    <xsl:template match="class">
        <tr>
            <td class="course-number">
                <xsl:call-template name="class-number"/>
            </td>
            <td class="reg-number">
                <xsl:value-of select="@synonym"/>
            </td>
            <td class="credit-hours">
                <xsl:value-of select="ancestor::course/@credit-hours"/>
            </td>
            <td class="dates">
                <xsl:value-of select="utils:format-dates(@date-start, @date-end)" />
                <xsl:apply-templates select="@weeks"/>
            </td>
            <td class="days">
                <xsl:apply-templates select="@days"/>
            </td>
            <!-- um... from here down, the data is stored in <meeting>s, not <course>s.
            <td class="times">
                <xsl:value-of select="@formatted-times"/>
            </td>
            <td class="format">
                <xsl:apply-templates select="@method"/>
            </td>
            <td class="room">
                <xsl:value-of select="@room"/>
            </td>
            <td class="faculty">
                <xsl:value-of select="@faculty-name"/>
            </td> -->
        </tr>
        <!-- no such thing as extra any more
        <xsl:apply-templates select="extra">
            <xsl:sort select="@sortkey"/>
        </xsl:apply-templates>-->
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

    <xsl:template match="class[@method = ('INET', 'TV', 'TVP', 'IDL')]/@method">
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


    <xsl:template match="extra">
        <tr class="extra">
            <td>
                <xsl:text>&#160;</xsl:text>
            </td>
            <td>
                <xsl:text>&#160;</xsl:text>
            </td>
            <td>
                <xsl:text>&#160;</xsl:text>
            </td>
            <td>
                <xsl:text>&#160;</xsl:text>
            </td>
            <td class="days">
                <xsl:value-of select="@days"/>
            </td>
            <td class="times">
                <xsl:value-of select="@formatted-times"/>
            </td>
            <td class="method">
                <xsl:value-of select="@method"/>
            </td>
            <td class="room">
                <xsl:value-of select="@room"/>
            </td>
            <td class="faculty">
                <xsl:value-of select="@faculty-name"/>
            </td>
        </tr>
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
        <xsl:if test="type or topic">
            <div class="summary">
                <xsl:choose>
                    <xsl:when test="topic">
                        <p>Course topics in this subject:</p>
                        <ul>
                            <xsl:for-each select="topic">
                                <xsl:sort select="@name"/>
                                <li>
                                    <a href="#{utils:make-url(@name)}">
                                        <xsl:value-of select="@name"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:when test="type">
                        <p>Course types offered in this subject:</p>
                        <ul>
                            <xsl:for-each select="type">
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

</xsl:stylesheet>
