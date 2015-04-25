<!-- $Id: proof.xsl 2264 2006-10-03 16:08:06Z wrm2110 $ -->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="xs utils">

    <!-- include some handy utility functions -->
    <xsl:include href="utils.xsl" />

    <xsl:output
        method="html"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD HTML 4.01//EN"
        doctype-system="http://www.w3.org/TR/html4/strict.dtd" />

    <!-- parameters -->
    <xsl:param name="output-directory">proof-output</xsl:param>
    <xsl:param name="output-extension">.html</xsl:param>

    <xsl:param name="with-highlighted-groups">false</xsl:param>

    <xsl:param name="for-secretaries" select="'true'">
        <!-- A switch which controls how many proof documents are generated:

             * If true, only the documents for each individual subject are
               created, for simplicity's sake.

             * If false, all of the possible documents are created, which
               includes one for each term, each division, each special-section
               and each subject, all stowed in appropriate directories.
        -->
    </xsl:param>



    <!-- =====================================================================
         Output document initialization

         Each template whose @mode="init" has only one purpose:  create an
         appropriately-located <xsl:result-document /> into which it will
         insert itself.
    ====================================================================== -->
    <xsl:template match="/schedule">
        <!-- either way, we need to apply this template -->
        <xsl:apply-templates select="//grouping[@type='subject']" mode="init" />
    </xsl:template>

    <xsl:template match="grouping[@type='subject']" mode="init">
        <xsl:variable name="output-path" select="concat(utils:urlify($output-directory), '/', utils:urlify(ancestor::grouping[@type='division']/@name), '/', utils:urlify(@name), $output-extension)" />
        <xsl:result-document href="{$output-path}">
            <xsl:call-template name="page-template">
                <xsl:with-param name="page-title" select="@name" />
            </xsl:call-template>
        </xsl:result-document>
    </xsl:template>


    <!-- =====================================================================
         Document-building templates

         This is where the "real" work gets done, after the result-documents
         are created by the @mode="init" templates.
    ====================================================================== -->
    <xsl:template match="term">
        <!-- only output the term header if there is more than one term -->
        <xsl:if test="count(/schedule/term) &gt; 1">
            <h1 class="term-header">
                <xsl:value-of select="@name" />
                <span class="term-dates"><xsl:value-of select="@dates" /></span>
            </h1>
        </xsl:if>

        <xsl:apply-templates select="grouping[@type='subject']">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template match="grouping[@type='subject']">
        <div class="subject-section">
            <xsl:variable name="classname">
                <xsl:choose>
                    <xsl:when test="ancestor::special-section">special-subject-header</xsl:when>
                    <xsl:otherwise>subject-header</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <h1 class="{$classname}"><xsl:value-of select="upper-case(@name)" /></h1>

            <!-- print the division info -->
            <xsl:call-template name="division-info" />

            <xsl:apply-templates select="description" />

            <!-- insert a list of the Core courses -->
            <xsl:call-template name="make-core-list" />

            <!-- Output any stand-alone types before topics or subtopics.  This allows some
                 special regroupings to have courses that aren't in a subgroup (topic, etc.)
                 and courses that are in a subgroup.  See, e.g. EMS courses. -->
            <xsl:apply-templates select="grouping[@type='type']">
                <xsl:sort select="@sortkey" data-type="number" />
            </xsl:apply-templates>

            <xsl:apply-templates select="grouping[@type='topic']">
                <xsl:sort select="@sortkey" data-type="number" />
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </div>
    </xsl:template>


    <xsl:template match="grouping[@type='topic']">
        <div class="topic-section">
            <xsl:apply-templates select="@sortkey" />
            <xsl:apply-templates select="@name" />
            <xsl:apply-templates select="comments" />

            <!-- output any stand-alone types before topics or subtopics -->
            <xsl:apply-templates select="grouping[@type='type']">
                <xsl:sort select="@sortkey" data-type="number" />
            </xsl:apply-templates>

            <xsl:apply-templates select="grouping[@type='subtopic']">
                <xsl:sort select="@sortkey" data-type="number" />
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="grouping[@type='topic']/@name">
        <xsl:variable name="classname">
            <xsl:choose>
                <xsl:when test="ancestor::special-section">special-topic-header</xsl:when>
                <xsl:otherwise>topic-header</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <h2 class="{$classname}"><xsl:value-of select="upper-case(.)" /></h2>
    </xsl:template>


    <xsl:template match="grouping[@type='subtopic']">
        <div class="subtopic-section">
            <xsl:apply-templates select="@sortkey" />
            <xsl:variable name="classname">
                <xsl:choose>
                    <xsl:when test="ancestor::special-section">special-subtopic-header</xsl:when>
                    <xsl:otherwise>subtopic-header</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <h3 class="{$classname}"><xsl:value-of select="upper-case(@name)" /></h3>
            <xsl:apply-templates select="comments" />

            <xsl:apply-templates select="type">
                <xsl:sort select="@sortkey" data-type="number" />
            </xsl:apply-templates>
        </div>
    </xsl:template>


    <xsl:template match="grouping[@type='type']">
        <div class="type-section {@id}">
            <xsl:apply-templates select="@sortkey" />
            <xsl:apply-templates select="@name" />

            <xsl:apply-templates select="course">
                <xsl:sort select="@sortkey" data-type="number" />
                <xsl:sort select="@default-sortkey" />
                <xsl:sort select="min(descendant::class/@section)" />
            </xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="grouping[@type='type']/@name">
        <!-- only output the type header if we're not in a special-section with the same name -->
        <xsl:if test="normalize-space(.) != normalize-space(ancestor::special-section[1]/@name)">
            <h4 class="type-header"><xsl:value-of select="." /> Courses</h4>
        </xsl:if>
    </xsl:template>


    <xsl:template match="course">
        <xsl:variable name="extra-class" select="if (@core-code and @core-code != '') then ' core' else ''" />
        <div class="course-section{$extra-class}">
            <xsl:apply-templates select="@sortkey | @default-sortkey" />
            <table>
                <xsl:apply-templates select="class">
                    <xsl:sort select="@sortkey" data-type="number" />
                    <xsl:sort select="@sortkey-days" data-type="number" />
                    <xsl:sort select="@sortkey-date" data-type="number" />
                    <xsl:sort select="@section" />
                </xsl:apply-templates>
            </table>
            <xsl:apply-templates select="description" />
        </div>
    </xsl:template>


    <xsl:template match="class">
        <tr>
            <xsl:apply-templates select="@sortkey | @default-sortkey" />
            <td class="number">
                <!-- the class number is a composite of the course's @rubrik and @number and the class's @section -->
                <xsl:value-of select="../@rubric" /><xsl:text> </xsl:text>
                <xsl:value-of select="../@number" /><xsl:text>-</xsl:text>
                <xsl:value-of select="@section" />
            </td>
            <td class="title"><xsl:value-of select="../@title" /></td>
            <td class="synonym"><xsl:value-of select="@synonym" /></td>
            <td class="credit_hours"><xsl:value-of select="../@credit-hours" /></td>
            <td class="dates"><xsl:value-of select="utils:format-dates(@start-date, @end-date)" />&#160;<xsl:apply-templates select="@weeks" /></td>
        </tr>
        <xsl:apply-templates select="meeting">
            <xsl:sort select="@sortkey" />
        </xsl:apply-templates>

        <tr>
            <td class="class-comments" colspan="10">
                <xsl:apply-templates select="description" />
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="class/@weeks">
        (<xsl:value-of select="." />&#160;Wks)
    </xsl:template>

    <xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@weeks" priority="1">
        <!-- don't output the number of weeks for Senior Adult courses -->
    </xsl:template>

    <xsl:template match="class[starts-with(ancestor::subject/@name, 'Senior Adult')]/@days">
        <!-- spell out the days of the week for Senior Adult courses -->
        <xsl:value-of select="utils:senior-adult-days(.)" />
    </xsl:template>


    <xsl:template match="meeting[@method = ('LEC','')]">
        <tr>
            <xsl:apply-templates select="@sortkey | @default-sortkey" />
            <td class="days"><xsl:value-of select="@days" /></td>
            <td class="times"><xsl:value-of select="utils:format-times(@start-time, @end-time)" />&#160;/&#160;<xsl:value-of select="@method" /></td>
            <td class="room"><xsl:value-of select="@room" /></td>
            <td class="faculty" colspan="2"><xsl:apply-templates select="faculty" /></td>
        </tr>
    </xsl:template>

    <xsl:template match="meeting">
        <tr class="extra-meeting">
            <td class="method"><xsl:value-of select="@method" /></td>
            <td class="times"><xsl:value-of select="utils:format-times(@start-time, @end-time)" /></td>
            <td class="days"><xsl:value-of select="@days" /></td>
            <td class="room"><xsl:value-of select="@room" /></td>
            <td class="faculty" colspan="2"><xsl:apply-templates select="faculty" /></td>
        </tr>
    </xsl:template>

    <xsl:template match="faculty">
        <xsl:value-of select="@last-name" />
        <xsl:if test="position() != last()"><xsl:value-of select="', '" /></xsl:if>
    </xsl:template>


    <!-- =====================================================================
         Comments

         Comments can have a small subset of HTML elements embedded
         within them, as well as the special elements <url> and
         <email>.  The set of legal HTML for comments is:

         h1, p, b, i, table, tr, td
    ====================================================================== -->
    <xsl:template match="description">
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

    <!-- skip any comments inside of <special-section>s -->
    <xsl:template match="description[ancestor::special-section]" />

    <xsl:template match="description//h1 | description//p | description//b | description//i | description//table | description//tr | description//td | description//@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="description//h1" priority="1">
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


    <xsl:template match="@sortkey | @default-sortkey">
        <!-- create an HTML comment for the sortkeys, for debugging purposes -->
        <xsl:comment><xsl:value-of select="local-name()" />: <xsl:value-of select="." /></xsl:comment>
    </xsl:template>



    <!-- =====================================================================
         Named templates

         Specialty templates to create the division-info and the HTML template
         for each page.
    ====================================================================== -->
    <xsl:template name="division-info">
        <p class="division-info">
            <xsl:choose>
                <!-- if we're inside a division, print the full division contact info -->
                <xsl:when test="ancestor::division">
                    <!-- Get the division info.  Any info on this element overrides the info provided
                         by the ancestor division. -->
                    <xsl:variable name="division-name" select="upper-case(ancestor::division/@name)" />
                    <xsl:variable name="ext" select="if (@ext) then @ext else ancestor::division/@ext" />
                    <xsl:variable name="room" select="if (@room) then @room else ancestor::division/@room" />
                    <xsl:variable name="extra-room" select="if (@extra-room) then @extra-room else ancestor::division/@extra-room" />
                    <xsl:variable name="email" select="if (@email) then @email else ancestor::division/@email" />

                    <!-- division name -->
                    <xsl:value-of select="$division-name" /><xsl:text>&#160;&#160;|&#160;&#160;</xsl:text>

                    <!-- phone number plus extension -->
                    <xsl:text>972-860-</xsl:text><xsl:value-of select="$ext" /><xsl:text>&#160;&#160;|&#160;&#160;</xsl:text>

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
                    <br />

                    <!-- email address -->
                    <xsl:text>E-MAIL:  </xsl:text><xsl:value-of select="$email" />
                </xsl:when>

                <!-- otherwise (we're probably in a special-section), just try to print the division name -->
                <xsl:otherwise><xsl:value-of select="if (@division-name) then upper-case(@division-name) else 'UNKNOWN DIVISION'" /></xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>


    <!-- the next two templates create the list of Core Curriculum courses
         at the top of each subject -->
    <xsl:template name="make-core-list">
        <xsl:variable name="core-courses" select="descendant::course[@core-code and @core-code != '']" />
        <xsl:if test="$core-courses and not(ancestor::special-section)">
            <xsl:variable name="core-code" select="lower-case((descendant::course/@core-code)[1])" />
            <div class="core-list">
                <h2>
                    The following courses are part of the 
                    <xsl:value-of select="$core-code" /> component of the
                    Core Curriculum:
                </h2>
                <p>
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
                </p>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="page-template">
        <xsl:param name="page-title" />
        <html>
            <head>
                <title>Proof of <xsl:value-of select="$page-title" /></title>
                <style type="text/css">
                    <![CDATA[
                             body {
                             margin: .25in;
                             padding: 0;
                             }
                             body, td, th {
                             font-family: "Times New Roman", Times, serif;
                             font-size: 8pt;
                             }
                             p {
                             margin: 0;
                             }
                             .comments {
                             text-indent: 1em;
                             }



h1, h2, h3, h4, h5, p.division-info {
font-family: Arial, Verdana, sans-serif;
font-weight: bold;
margin: 0;
}
h1 { font-size: 18pt; }
h2 { font-size: 12pt; }
h3 { font-size: 10pt; }
h4 { font-size: 10pt; }

h1 span, h2 span, h3 span, h4 span, h5 span {
display: block;
font-size: 9pt;
font-weight: normal;
}

h1, h2, h3 {
border-bottom: 1px solid #999;
}
h2, h3 {
font-style: italic;
}


div.subject-section {
margin-bottom: 4em;
}
p.division-info {
margin-bottom: .5em;
font-weight: normal;
font-size: 10pt;
}

div.core-list {
margin-bottom: 1em;
}
div.core-list h2 {
font-size: 10pt;
font-weight: bold;
font-style: normal;
border: none;
}


.special-subject-header {
font-size: 14pt;
color: #030;
}
.minimester-header {
font-size: 16pt;
font-style: italic;
}

.topic-header {
color: #360;
}


div.type-section {
margin-bottom: 2em;
}
.type-header {
text-decoration: underline;
}



div.group-section {
margin-bottom: 1em;
}
div.group-section div.course-section {
margin-bottom: 0;
}


div.course-section {
margin-bottom: 1em;
}
td {
padding: 0;
padding-right: 1em;
}
td.dates, td.faculty {
padding-right: 0;
text-align: right;
}
td.method {
padding-left: 1em;
}
tr.extra-meeting td {
color: #693;
}
div.course-section p.comments {
margin-top: -.4em;
}

div.course-section div.comments {
background-color: #ffbfbf;
}

td.class-comments {
background-color: #dff4ff;
}
td.class-comments div.comments {
background-color: transparent;
}

div.N td {
font-weight: bold;
}
div.DL td {
text-decoration: underline;
}
                    ]]>
                    <xsl:if test="$with-highlighted-groups = 'true'">
                        <![CDATA[
                                 div.group-section {
                                 background-color: #eee;
                                 }
                        ]]>
                    </xsl:if>
                </style>
            </head>

            <body>
                <!-- apply-templates to whatever element has called this template -->
                <xsl:apply-templates select="." />
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
