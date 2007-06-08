<!-- $Id$ -->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output
        method="xhtml"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />


    <xsl:param name="page-title">Room Coordinator Report</xsl:param>
    <xsl:param name="output-directory">room-coordinator</xsl:param>

    <!-- The room coordinator report can be filtered to only include
         classes from a certain division or rubric by setting either
         or both of the parameters below, as strings. -->
    <xsl:variable name="division-filter" select="()" />
    <xsl:variable name="rubrik-filter" select="()" />

    
    <!-- The room coordinator wants "normal" classes to come out ahead
         of "special" classes.  Normal classes do not include their
         annotations, but special classes do.
         
         The two different types of classes are defined by either
         their course type (e.g. Day, Night, Distance Learning) or by
         their teaching method (e.g. Lecture, Lab, Internet, TV).
         
         The following variables define the normal and special course
         types and teaching methods.  -->
    <xsl:variable name="normal-class-types" select="('D','N','W', 'FD', 'FN')" />
    <xsl:variable name="special-class-types" select="('DL','SP', 'FTD', 'FTN')" />
    <xsl:variable name="normal-class-methods" select="('LEC', 'LAB', 'CLIN', 'PRVT', 'PRAC', 'COOP', 'INT')" />
    <xsl:variable name="special-class-methods" select="('INET', 'TVP', 'IDL', 'TV')" />
    

    <xsl:template match="/">
        <xsl:apply-templates select="//term" />
    </xsl:template>

    <xsl:template match="term">
        <xsl:result-document href="{$output-directory}/room-coordinator-{@machine_name}.html">
            <html>
                <head>
                    <title><xsl:value-of select="$page-title" /></title>
                    <link rel="stylesheet" type="text/css" href="http://www.brookhavencollege.edu/xml/css/room-coordinator.css" media="all" />
                    <link rel="stylesheet" type="text/css" href="http://www.brookhavencollege.edu/xml/css/room-coordinator-print.css" media="print" />
                </head>
                <body>
                    <h1>
                        <xsl:value-of select="$page-title" /> &#8212;
                        <xsl:value-of select="@name" />
                    </h1>

                    <xsl:variable name="possible-classes"
                                  select="if (empty($division-filter) and empty($rubrik-filter))
                                          then
                                          descendant::class
                                          else
                                          descendant::division[@name = $division-filter]/descendant::class |
                                          descendant::course[@rubrik = $rubrik-filter]/descendant::class" />

                    <xsl:call-template name="make-table">
                        <xsl:with-param name="title">Normal Courses</xsl:with-param>
                        <xsl:with-param name="classes" select="$possible-classes[@method = $normal-class-methods and not(parent::course/@type = $special-class-types)]" />
                    </xsl:call-template>

                    <xsl:call-template name="make-table">
                        <xsl:with-param name="title">Special Courses</xsl:with-param>
                        <xsl:with-param name="classes" select="$possible-classes[@method = $special-class-methods or parent::course/@type = $special-class-types]" />
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
                <xsl:sort select="../@rubrik" />
                <xsl:sort select="../@number" />
                <xsl:sort select="@section" />
            </xsl:apply-templates>
        </table>
    </xsl:template>


    <xsl:template match="class">
        <tr class="{../@type}">
            <td><xsl:value-of select="../@rubrik" />&#160;<xsl:value-of select="../@number" />-<xsl:value-of select="@section" />&#160;</td>
            <th><xsl:value-of select="../@title" />&#160;</th>
            <td><xsl:value-of select="@days" />&#160;</td>
            <td><xsl:value-of select="@formatted-times" />&#160;</td>
            <td><xsl:value-of select="@formatted-dates" />&#160;</td>
            <td><xsl:value-of select="@faculty-name" />&#160;</td>
            <td><xsl:value-of select="@room" />&#160;</td>
            <td><xsl:value-of select="@method" />&#160;</td>
            <td><xsl:value-of select="../@type" />&#160;</td>
            <td><xsl:value-of select="@section-capacity" />&#160;</td>
        </tr>

        <!-- if there are any extra meetings, include those -->
        <xsl:apply-templates select="extra" />

        <!-- comments will only appear if it's a distance learning class -->
        <xsl:if test="@method = $special-class-methods or parent::course/@type = $special-class-types">
            <xsl:apply-templates select="../comments" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="extra">
        <tr class="extra">
            <td>&#160;</td>
            <th><em><xsl:value-of select="@method" /></em></th>
            <td><xsl:value-of select="@days" />&#160;</td>
            <td><xsl:value-of select="@formatted-times" />&#160;</td>
            <td><xsl:value-of select="@formatted-dates" />&#160;</td>
            <td><xsl:value-of select="@faculty-name" />&#160;</td>
            <td><xsl:value-of select="@room" />&#160;</td>
            <td><xsl:value-of select="@method" />&#160;</td>
            <td><xsl:value-of select="@section-capacity" />&#160;</td>
        </tr>
    </xsl:template>

    <xsl:template match="comments">
        <tr class="comments">
            <td colspan="8">
                <xsl:value-of select="current()" />
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
