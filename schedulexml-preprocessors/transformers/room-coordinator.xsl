<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="xs utils">
    
    <xsl:output
        method="html"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD HTML 4.01//EN"
        doctype-system="http://www.w3.org/TR/html4/strict.dtd" />


    <!-- =====================================================================
         Includes
    ====================================================================== -->
    <xsl:include href="utils.xsl" />


    <!-- =====================================================================
         Parameters
    ====================================================================== -->
    <xsl:param name="page-title">Room Coordinator Report</xsl:param>
    <xsl:param name="output-directory">room-coordinator</xsl:param>

    
    <!-- =====================================================================
         Filters
         
         The room coordinator report can be filtered to only include classes
         from a certain division or rubric by setting either or both of the
         parameters below, as a list of strings.  For example, to include only
         Accounting classes in the report, you would use a rubric filter like
         this:
            <xsl:variable name="rubric-filter" select="('ACCT', 'ACNT')" />
    ====================================================================== -->
    <xsl:variable name="division-filter" select="()" />
    <xsl:variable name="rubric-filter" select="()" />

    
    <!-- =====================================================================
         Class types
    
         The room coordinator wants "normal" classes to come out ahead
         of "special" classes.  Normal classes do not include their
         annotations, but special classes do.
         
         The two different types of classes are defined by either
         their course type (e.g. Day, Night, Distance Learning) or by
         their teaching method (e.g. Lecture, Lab, Internet, TV).
         
         The following variables define the normal and special course
         types and teaching methods.
    ====================================================================== -->
    <xsl:variable name="normal-types" select="('D','N','W', 'FD', 'FN')" />
    <xsl:variable name="special-types" select="('DL','SP', 'FTD', 'FTN')" />
    <xsl:variable name="normal-methods" select="('LEC', 'LAB', 'CLIN', 'PRVT', 'PRAC', 'COOP', 'INT')" />
    <xsl:variable name="special-methods" select="('INET', 'TVP', 'IDL', 'TV')" />


    <xsl:template match="term">
        <xsl:result-document href="{$output-directory}/room-coordinator-{utils:urlify(@name)}.html">
            <html>
                <head>
                    <title><xsl:value-of select="$page-title" /></title>
                    <!-- basic stylesheet -->
                    <link rel="stylesheet"
                          type="text/css"
                          href="http://www.brookhavencollege.edu/xml/css/room-coordinator.css"
                          media="all" />
                    <!-- print stylesheet -->
                    <link rel="stylesheet"
                          type="text/css"
                          href="http://www.brookhavencollege.edu/xml/css/room-coordinator-print.css"
                          media="print" />
                </head>
                
                <body>
                    <h1>
                        <xsl:value-of select="$page-title" /> &#8212;
                        <xsl:value-of select="@name" />
                    </h1>

                    <!-- Get a set of the classes to include in this report,
                         based on the rubric and division filters in effect. -->
                    <xsl:variable name="possible-classes"
                                  select="if (empty($division-filter) and empty($rubric-filter))
                                          then
                                              descendant::class
                                          else
                                              descendant::grouping[@type = 'division' and @name = $division-filter]/descendant::class |
                                              descendant::course[@rubric = $rubric-filter]/descendant::class" />

                    <!-- First, generate the listing for "normal" classes. -->
                    <xsl:call-template name="make-table">
                        <xsl:with-param name="title">Normal Courses</xsl:with-param>
                        <xsl:with-param name="classes" select="$possible-classes[meeting[1]/@method = $normal-methods and not(parent::course/@type-id = $special-types)]" />
                    </xsl:call-template>
                    
                    <!-- Then, generate the listing for "special" classes. -->
                    <xsl:call-template name="make-table">
                        <xsl:with-param name="title">Special Courses</xsl:with-param>
                        <xsl:with-param name="classes" select="$possible-classes[meeting[1]/@method = $special-methods or parent::course/@type-id = $special-types]" />
                    </xsl:call-template>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <xsl:template name="make-table">
        <xsl:param name="title">Classes</xsl:param>
        <xsl:param name="classes" />

        <h2><xsl:value-of select="$title" /></h2>
        <table border="0" cellpadding="0" cellspacing="0">
            <tr class="heading">
                <th class="first">Number</th>
                <th>Title</th>
                <th>Days</th>
                <th>Times</th>
                <th>Dates</th>
                <th>Faculty</th>
                <th>Room</th>
                <th>Method</th>
                <th>Type</th>
                <th>Capacity</th>
            </tr>
            <xsl:apply-templates select="$classes">
                <xsl:sort select="../@rubric" />
                <xsl:sort select="../@number" />
                <xsl:sort select="@section" />
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xsl:template match="class">
        <xsl:apply-templates select="meeting" />

        <!-- Descriptions should only appear for "special" classes. -->
        <xsl:if test="meeting[1]/@method = $special-methods or parent::course/@type-id = $special-types">
            <xsl:apply-templates select="parent::course/description" />
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="meeting[position() = 1]">
        <!-- This will match the "primary" meeting, which is assumed to appear
             first in the source. -->
        <tr class="{ancestor::course/@type-id}">
            <td><xsl:value-of select="ancestor::course/@rubric" />&#160;<xsl:value-of select="ancestor::course/@number" />-<xsl:value-of select="parent::class/@section" />&#160;</td>
            <th><xsl:value-of select="ancestor::course/@title" />&#160;</th>
            <td><xsl:value-of select="@days" />&#160;</td>
            <td><xsl:value-of select="utils:format-times(@start-time, @end-time)" />&#160;</td>
            <td><xsl:value-of select="utils:format-dates(parent::class/@start-date, parent::class/@end-date)" />&#160;</td>
            <td><xsl:value-of select="faculty/@last-name" />&#160;</td>
            <td><xsl:value-of select="@room" />&#160;</td>
            <td><xsl:value-of select="@method" />&#160;</td>
            <td><xsl:value-of select="ancestor::course/@type-id" />&#160;</td>
            <td><xsl:value-of select="round(faculty[1]/@class-load)" />&#160;</td>
        </tr>
    </xsl:template>
    
    <xsl:template match="meeting[position() &gt; 1]">
        <!-- This will match any "extra" meetings.  The class number, dates,
             type, etc. are not included in the listings for "extra" meetings,
             because they should all be the same as the "primary" meeting. -->
        <tr class="extra">
            <td>&#160;</td><!-- no class number -->
            <th><em><xsl:value-of select="@method" /></em></th>
            <td><xsl:value-of select="@days" />&#160;</td>
            <td><xsl:value-of select="utils:format-times(@start-time, @end-time)" />&#160;</td>
            <td>&#160;</td><!-- no dates -->
            <td><xsl:value-of select="faculty/@last-name" />&#160;</td>
            <td><xsl:value-of select="@room" />&#160;</td>
            <td><xsl:value-of select="@method" />&#160;</td>
            <td>&#160;</td><!-- no course type -->
            <td>&#160;</td><!-- no class load -->
        </tr>
    </xsl:template>


    <xsl:template match="description">
        <tr class="comments">
            <td colspan="8">
                <xsl:value-of select="current()" />
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
