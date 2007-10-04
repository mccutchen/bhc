<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="xs utils">
    
    <!-- utility functions -->
    <xsl:include href="utils.xsl" />
    
    <xsl:output
        method="xhtml"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
    
    <!-- parameters -->
    <xsl:param name="page-title">Room Coordinator Report</xsl:param>
    <xsl:param name="output-directory">output/room-coordinator</xsl:param>
    <xsl:param name="output-extension">.html</xsl:param>
    
    <!-- options -->
    <!-- filters
        The room coordinator report can be filtered to only include
        classes from a certain division or rubric by setting either
        or both of the parameters below, as strings.
    -->
    <xsl:variable name="division-filter" select="()" />
    <xsl:variable name="rubric-filter" select="()" />
    
    <!-- processing variables
        The room coordinator wants "normal" classes to come out ahead
        of "special" classes.  Normal classes do not include their
        annotations, but special classes do.
        
        The two different types of classes are defined by either
        their course type (e.g. Day, Night, Distance Learning) or by
        their teaching method (e.g. Lecture, Lab, Internet, TV).
        
        The following variables define the normal and special course
        types and teaching methods. 
    -->
    <xsl:variable name="normal-types" select="('D','N','W', 'FD', 'FN')" />
    <xsl:variable name="special-types" select="('DL','SP', 'FTD', 'FTN')" />
    <xsl:variable name="normal-methods" select="('LEC', 'LAB', 'CLIN', 'PRVT', 'PRAC', 'COOP', 'INT')" />
    <xsl:variable name="special-methods" select="('INET', 'TVP', 'IDL', 'TV')" />
    
    
    <xsl:template match="/">
        <xsl:apply-templates select="//term" />
    </xsl:template>
    
    <xsl:template match="term">
        <xsl:result-document href="{$output-directory}/{utils:urlify(@year)}-{utils:urlify(@semester)}_room-coordinator.html">
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
                    
                    <xsl:variable name="possible-meetings"
                        select="if (empty($division-filter) and empty($rubric-filter))
                        then
                        descendant::meeting
                        else
                        descendant::grouping[@type = 'division' and @name = $division-filter]/descendant::meeting |
                        descendant::course[@rubric = $rubric-filter]/descendant::meeting" />
                    
                    <xsl:call-template name="make-table">
                        <xsl:with-param name="title">Normal Courses</xsl:with-param>
                        <xsl:with-param name="meetings" select="$possible-meetings[@method = $normal-methods and not(ancestor::course/@type-id = $special-types)]" />
                    </xsl:call-template>
                    
                    <xsl:call-template name="make-table">
                        <xsl:with-param name="title">Special Courses</xsl:with-param>
                        <xsl:with-param name="meetings" select="$possible-meetings[@method = $special-methods or ancestor::course/@type-id = $special-types]" />
                    </xsl:call-template>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template name="make-table">
        <xsl:param name="title">Classes</xsl:param>
        <xsl:param name="meetings" />
        
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
            <xsl:call-template name="pre-format">
                <xsl:with-param name="meetings" select="$meetings" />
            </xsl:call-template>
        </table>
    </xsl:template>
    
    <!-- ok, so the sorting is all messed up and there is no longer an easy 'extra' element for
         lec/lab pairing, coop's, ect. So, we're going to filter this a bit more than in the
         previous version. I'm going to make a guess and say that 'extra' courses were always
         non-LEC meetings with identical 'rubric number-section' identifiers as a LEC meeting. -->
    <!-- Ah, INET meetings can also have 'extra' LAB meetings -->
    
    <xsl:template name="pre-format">
        <xsl:param name="meetings" />
        
        <!-- just call them by the unique 'rubric number section' sets -->
        <xsl:for-each-group select="$meetings" group-by="ancestor::course/@rubric"> <!-- and ancestor::course/@number and ancestor::class/@section"> -->
            <xsl:sort select="ancestor::course/@rubric" />
            <xsl:sort select="ancestor::course/@number" />
            <xsl:sort select="ancestor::class/@section" />
            
            <xsl:variable name="rubric" select="ancestor::course/@rubric" />
            <xsl:variable name="rubric-set" select="$meetings[ancestor::course/@rubric = $rubric]" />
            <xsl:for-each-group select="$rubric-set" group-by="ancestor::course/@number">
                <xsl:sort select="ancestor::course/@number" />
                
                <xsl:variable name="number" select="ancestor::course/@number" />
                <xsl:variable name="number-set" select="$rubric-set[ancestor::course/@number = $number]" />
                <xsl:for-each-group select="$number-set" group-by="ancestor::class/@section">
                    <xsl:sort select="ancestor::class/@section" />
                    
                    <xsl:variable name="section" select="ancestor::class/@section" />
                    <xsl:variable name="meeting-set" select="$number-set[ancestor::class/@section = $section]" />
                    
                    <!-- if there's more than one, try to find a main/extra relationship -->
                    <xsl:choose>
                        <xsl:when test="count($meeting-set) &gt; 1 and count($meeting-set[@method = 'LEC' or @method = 'INET']) = 1">
                            <xsl:apply-templates select="$meeting-set[@method = 'LEC' or @method = 'INET']" mode="main" />
                            <xsl:apply-templates select="$meeting-set[@method != 'LEC' and @method != 'INET']" mode="extra" />
                        </xsl:when>
                        <xsl:when test="count($meeting-set) &lt; 1">
                            <xsl:variable name="class-id"><xsl:value-of select="$rubric" /> <xsl:value-of select="$number" />-<xsl:value-of select="$section" /></xsl:variable>
                            <xsl:message>!Warning! no meetings listed for course <xsl:value-of select="$class-id" />: <xsl:value-of select="$meeting-set/@synonym" /></xsl:message>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="$meeting-set" mode="main" />
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    <!-- comments will only appear if it's a distance learning class -->
                    <xsl:if test="$meeting-set/@method = $special-methods or $meeting-set/ancestor::course/@type-id = $special-types">
                        <xsl:apply-templates select="$meeting-set/ancestor::course/description" />
                    </xsl:if>
                </xsl:for-each-group>
            </xsl:for-each-group>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="meeting" mode="main">
        <xsl:variable name="type-id" select="ancestor::type/@id" />
        <xsl:variable name="course" select="ancestor::course" />
        <xsl:variable name="class" select="parent::class" />
        <xsl:variable name="faculty-name" select="descendant::faculty/@name-last" />
        
        <tr class="{$course/@type-id}">
            <td><xsl:value-of select="$course/@rubric" />&#160;<xsl:value-of select="$course/@number" />-<xsl:value-of select="$class/@section" />&#160;</td>
            <th><xsl:value-of select="$course/@title-long" />&#160;</th>
            <xsl:choose>
                <xsl:when test="@method = 'INET' or @room = 'INET'">
                    <td>NA&#160;</td>
                    <td>NA&#160;</td>
                </xsl:when>
                <xsl:otherwise>
                    <td><xsl:value-of select="@days" />&#160;</td>
                    <td><xsl:value-of select="utils:format-times(@time-start, @time-end)" />&#160;</td>
                </xsl:otherwise>
            </xsl:choose>
            <td><xsl:value-of select="utils:format-dates($class/@date-start, $class/@date-end)" />&#160;</td>
            <td><xsl:value-of select="if (not($faculty-name)) then 'Staff' else $faculty-name" />&#160;</td>
            <td><xsl:value-of select="@room" />&#160;</td>
            <td><xsl:value-of select="@method" />&#160;</td>
            <td><xsl:value-of select="$type-id" />&#160;</td>
            <td><xsl:value-of select="$class/@capacity" />&#160;</td>
        </tr>
        
        <!-- comments will only appear if it's a distance learning class
        <xsl:if test="@method = $special-methods or $course/@type-id = $special-types">
            <xsl:apply-templates select="$course/description" />
        </xsl:if> -->
    </xsl:template>
    
    <xsl:template match="meeting" mode="extra">
        <xsl:variable name="type" select="ancestor::grouping[@type = 'type']" />
        <xsl:variable name="course" select="ancestor::course" />
        <xsl:variable name="class" select="parent::class" />
        <xsl:variable name="faculty-name" select="descendant::faculty/@last-name" />
        
        <tr class="extra">
            <td>&#160;</td>
            <th><em><xsl:value-of select="@method" /></em></th>
            <td><xsl:value-of select="@days" />&#160;</td>
            <td><xsl:value-of select="utils:format-times(@time-start, @time-end)" />&#160;</td>
            <td>&#160;</td><!-- no dates
            <td><xsl:value-of select="utils:format-dates($class/@date-start, $class/@date-end)" />&#160;</td> -->
            <td><xsl:value-of select="if (not($faculty-name)) then 'Staff' else $faculty-name" />&#160;</td>
            <td><xsl:value-of select="@room" />&#160;</td>
            <td><xsl:value-of select="@method" />&#160;</td>
            <td>&#160;</td><!-- no course type
            <td><xsl:text> </xsl:text>&#160;</td> -->
            <td><xsl:value-of select="@section-capacity" />&#160;</td>
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
