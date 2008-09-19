<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Output parameters -->
    <xsl:output
        method="text"
        encoding="utf-8"
        byte-order-mark="no"
        use-character-maps="macroman-xtags" />

    <!-- import the various character maps we can use to generate accented
         letters in Xtags format -->
    <xsl:include href="character-maps.xsl" />

    <xsl:param name="output-target-platform">mac</xsl:param>
    <xsl:param name="output-directory">print-output</xsl:param>
    <xsl:param name="output-extension">.txt</xsl:param>


    <xsl:template match="/">
        <!-- output each <schedule-type> to its own file -->
        <xsl:result-document href="{$output-directory}/full-schedule{$output-extension}">
            <xsl:call-template name="quark-preamble" />
            <xsl:apply-templates select="schedule" />
        </xsl:result-document>

        <xsl:result-document href="{$output-directory}/index{$output-extension}">
            <xsl:call-template name="quark-preamble" />
            <xsl:call-template name="make-index" />
        </xsl:result-document>

        <!-- output each division to its respective <schedule-type> folder -->
        <xsl:for-each select="schedule/division">
            <xsl:result-document href="{$output-directory}/divisions/{@machine_name}{$output-extension}">
                <xsl:call-template name="quark-preamble" />
                <xsl:apply-templates select="." />
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>


    <xsl:template match="schedule">
        <xsl:apply-templates select="division">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
    </xsl:template>


    <xsl:template name="make-index">
        <!--
            This template is pretty complicated in its operation.  It was constructed with
            the help of David Carlisle in this xsl-list thread:
            - http://biglist.com/lists/xsl-list/archives/200506/msg01159.html

            Basically, what it does is:
            - Build the entire index structure into one long <ul> inside the $entire-index
              variable.  (My problem was that I could build the list but not split it evenly,
              David Carlisle suggested that I build the entire list into a variable and then
              select into that to split it, which never would have occurred to me.)

            - Count how many items are in $entire-index (plus a manual offset to ensure even
              columns) and divide that by two, to get a $midpoint-index.

            - Select the top-level $entire-index element which contains the element at
              $midpoint-index into the variable $midpoint-element.

            - Put $midpoint-element and all of its preceding siblings into one column, and put
              all of its following sibling into the next column.

            See?  Complicated.
        -->

        <!-- store the entire index in sorted form in $entire-index -->
        <xsl:for-each-group select="/schedule/division" group-by="substring(@name,1,1)">
            <xsl:sort select="current-grouping-key()" />
            <xsl:variable name="current-letter" select="current-grouping-key()" />
            <xsl:variable name="divisions" select="/schedule/division[substring(@name,1,1) = $current-letter]" />

            <xsl:call-template name="xtag">
                <xsl:with-param name="tagname" select="'Index Letter'" />
                <xsl:with-param name="content" select="$current-letter" />
            </xsl:call-template>
            <xsl:apply-templates select="$divisions" mode="index">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="division" mode="index">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname" select="'Index Division'" />
        </xsl:call-template>
        <xsl:value-of select="@name" /><xsl:text>&#9;</xsl:text>
        <xsl:call-template name="br" />

        <xsl:if test="cluster">
            <xsl:apply-templates select="cluster" mode="index">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="cluster" mode="index">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname" select="'Index Cluster'" />
        </xsl:call-template>
        <xsl:text>&#9;</xsl:text><xsl:value-of select="@name" /><xsl:text>&#9;</xsl:text>
        <xsl:call-template name="br" />
    </xsl:template>



    <!-- division template -->
    <xsl:template match="division">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname">Subject</xsl:with-param>
            <xsl:with-param name="content" select="upper-case(@name)" />
        </xsl:call-template>

        <!-- First, show courses without clusters (sorted by cluster sort order) -->
        <xsl:apply-templates select="course">
            <xsl:sort data-type="number" select="@cluster_sort_order" order="ascending" />
        </xsl:apply-templates>

        <xsl:if test="course and cluster">
            <xsl:call-template name="blank-line" />
        </xsl:if>

        <!-- Second, show clusters inside this division -->
        <xsl:apply-templates select="cluster">
            <xsl:sort select="@name" order="ascending" />
        </xsl:apply-templates>

        <xsl:if test="position() != last()">
            <xsl:call-template name="end-division" />
        </xsl:if>
    </xsl:template>



    <!-- cluster template -->
    <xsl:template match="cluster">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname">Subhead</xsl:with-param>
            <xsl:with-param name="content" select="upper-case(@name)" />
        </xsl:call-template>

        <!-- if there's a catalog header, print it -->
        <xsl:apply-templates select="catalog_page_header" />

        <!-- if there's a catalog prefix, print it -->
        <xsl:apply-templates select="catalog_prefix" />

        <!-- print the courses in this cluster -->
        <xsl:apply-templates select="course">
            <xsl:sort data-type="number" select="@cluster_sort_order" order="ascending" />
        </xsl:apply-templates>

        <!-- if there's a suffix description, print it -->
        <xsl:apply-templates select="suffix_description" />

        <xsl:if test="position() != last()">
            <xsl:call-template name="end-cluster" />
        </xsl:if>
    </xsl:template>


    <!-- course template -->
    <xsl:template match="course">

        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname">
                <xsl:if test="ancestor::schedule-type/@name = 'LIFELONG LEARNING'">
                    Lifelong Learning
                </xsl:if>
                Course Title
            </xsl:with-param>
            <xsl:with-param name="content" select="upper-case(@title)" />
        </xsl:call-template>

        <xsl:apply-templates select="prerequisites" />

        <xsl:apply-templates select="course_description" />
        <xsl:apply-templates select="textbooks" />
        <xsl:apply-templates select="supplies" />

    	<xsl:call-template name="start-classes" />
    	<xsl:apply-templates select="class">
            <xsl:sort select="@date_sortkey" data-type="number" order="ascending" />
            <xsl:sort select="@time_sortkey" data-type="number" order="ascending" />
        </xsl:apply-templates>

    	<xsl:if test="notes"><xsl:call-template name="end-classes" /></xsl:if>
    	<xsl:apply-templates select="notes" />

        <xsl:if test="position() != last()">
            <xsl:call-template name="end-course" />
        </xsl:if>
    </xsl:template>


    <!-- class template -->
    <xsl:template match="class">

        <!-- determine what xtag to use to display this class's information -->
        <xsl:variable name="tagname">
            <xsl:choose>
                <xsl:when test="@evening">Night Course</xsl:when>
                <xsl:otherwise>Day Course</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    	
    	<!-- ok, old format was:
    		@Tagname: course # \t dates \t hours/sessions \t times
    		@Tagname: \t location-room \t days \t faculty \t tuition
    		
    		new format is:
    		@Tagname: course # \t reg # \t dates \t hours/sessions \t days
    		@Tagname: \t times \t \t location-room \t faculty \t tuition
    	-->

		<!-- tag -->
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname" select="$tagname" />
        </xsl:call-template>
    	
        <!-- if the class number is missing, print a bold placeholder -->
        <xsl:choose>
            <xsl:when test="not(@class_number)">
                <xsl:text>&lt;B&gt;XXXX-XXXX-XXXXX&lt;$&gt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@class_number"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="sep" />

    	<!-- reg number -->
    	<xsl:value-of select="@reg_num" />
    	<xsl:call-template name="sep" />
    	
    	<!-- dates -->
    	<xsl:value-of select="@start_date"/>-<xsl:value-of select="@end_date"/>
    	<xsl:call-template name="sep" />
    	
    	<!-- hours / session -->
        <xsl:value-of select="@hours"/>hrs/<xsl:value-of select="@session"/>
    	<xsl:call-template name="sep" />
    	
    	<!-- needs an extra seperator here -->
        <xsl:call-template name="sep" />
        
    	<!-- days -->
    	<xsl:value-of select="@days"/>
    	<xsl:call-template name="sep" />
    	
    	
    	<!-- newline -->
    	<xsl:call-template name="br" />
    	
    	<!-- tag -->
    	<xsl:call-template name="xtag">
    		<xsl:with-param name="tagname" select="$tagname" />
    	</xsl:call-template>
    	
    	<!-- sep -->
    	<xsl:call-template name="sep" />
    	
    	<!-- times -->
        <xsl:value-of select="@time_formatted"/>
    	<xsl:call-template name="sep" />
    	
    	<!-- extra sep -->
    	<xsl:call-template name="sep" />
    	
    	<!-- location-room -->
    	<xsl:value-of select="@location"/>-<xsl:value-of select="@room"/>
    	<xsl:call-template name="sep" />
    	
    	<!-- faculty -->
    	<xsl:value-of select="@faculty"/>
    	<xsl:call-template name="sep" />
    	
    	<!-- tuition -->
    	<xsl:value-of select="@tuition"/>
        <xsl:call-template name="sep" />
        
        <!-- term -->
        <xsl:value-of select="@term" />
        
    	
    	<!-- newline -->
    	<xsl:call-template name="br" />
    </xsl:template>


    <xsl:template match="course_description">
        <xsl:if test="not(p)">
            <xsl:call-template name="xtag">
                <xsl:with-param name="tagname">Annotation</xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="." />
            <xsl:if test="position() != last() or (not(ancestor::course/textbooks) and not(ancestor::course/supplies))">
                <xsl:call-template name="br" />
            </xsl:if>
        </xsl:if>

        <xsl:apply-templates select="p" />
    </xsl:template>

    <xsl:template match="notes">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname">Notes</xsl:with-param>
        </xsl:call-template>
        <xsl:text>&lt;B&gt;Notes:&lt;$&gt;  </xsl:text>
        <xsl:value-of select="." />
        <xsl:call-template name="br" />
    </xsl:template>


    <xsl:template match="catalog_page_header | catalog_prefix | suffix_description">

        <xsl:if test="not(p)">
            <xsl:call-template name="xtag">
                <xsl:with-param name="tagname">Annotation</xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="." />
            <xsl:call-template name="br" />
        </xsl:if>

        <xsl:apply-templates select="p" />

        <xsl:if test="self::catalog_page_header or self::catalog_prefix">
            <xsl:call-template name="blank-line" />
        </xsl:if>
    </xsl:template>


    <xsl:template match="p">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname">Annotation</xsl:with-param>
        </xsl:call-template>

        <xsl:apply-templates />

        <xsl:if test="position() != last() or (not(ancestor::course/textbooks) and not(ancestor::course/supplies))">
            <xsl:call-template name="br" />
        </xsl:if>
    </xsl:template>


    <xsl:template match="url|email">
        <xsl:text>&lt;@WWW&gt;</xsl:text><xsl:value-of select="." /><xsl:text>&lt;@$p&gt;</xsl:text>
    </xsl:template>


    <xsl:template match="prerequisites">
        <xsl:call-template name="xtag">
            <xsl:with-param name="tagname">
                <xsl:if test="ancestor::schedule-type/@name = 'LIFELONG LEARNING'">
                    Lifelong Learning
                </xsl:if>
                Prerequisites
            </xsl:with-param>
            <xsl:with-param name="content" select="concat('Prerequisites: ', .)" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="textbooks">
        <xsl:text>  Text:  </xsl:text>
        <xsl:value-of select="." />
        <xsl:if test="not(ancestor::course/supplies)">
            <xsl:call-template name="br" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="supplies">
        <xsl:text>  </xsl:text>
        <xsl:value-of select="." />
        <xsl:call-template name="br" />
    </xsl:template>


    <xsl:template name="xtag">
        <xsl:param name="tagname">Default</xsl:param>
        <xsl:param name="content" />

        <xsl:text>@</xsl:text><xsl:value-of select="normalize-space($tagname)" /><xsl:text>:</xsl:text>
        <xsl:if test="$content">
            <xsl:value-of select="$content" />
            <xsl:call-template name="br" />
        </xsl:if>
    </xsl:template>


    <xsl:template name="encoding-tag">
        <xsl:text>&lt;e1&gt;</xsl:text><xsl:call-template name="br" />
    </xsl:template>


    <xsl:template name="blank-line">
        <xsl:text>@Spacer:</xsl:text><xsl:call-template name="br" />
    </xsl:template>

	<xsl:template name="start-classes">
		<xsl:text>@Start Classes:</xsl:text><xsl:call-template name="br" />
	</xsl:template>
	
	<xsl:template name="end-classes">
		<xsl:text>@End Classes:</xsl:text><xsl:call-template name="br" />
	</xsl:template>
	
	<xsl:template name="end-course">
		<xsl:text>@End Course:</xsl:text><xsl:call-template name="br" />
	</xsl:template>
	
	<xsl:template name="end-cluster">
		<xsl:text>@End Cluster:</xsl:text><xsl:call-template name="br" />
	</xsl:template>
	
	<xsl:template name="end-division">
		<xsl:text>@End Division:</xsl:text><xsl:call-template name="br" />
	</xsl:template>
	
    <xsl:template name="br">
        <xsl:choose>
            <xsl:when test="$output-target-platform = 'mac'">
                <xsl:text>&#13;</xsl:text>
            </xsl:when>
            <xsl:when test="$output-target-platform = 'unix'">
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#13;&#10;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="quark-preamble">
        <xsl:text>&lt;v6.50&gt;&lt;e0&gt;</xsl:text><xsl:call-template name="br" />
    </xsl:template>

    <xsl:template name="sep">
        <xsl:text>&#9;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
