<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs fn">

    <!-- Output parameters -->
    <xsl:output
        method="text"
        encoding="utf-8"
        byte-order-mark="no"
        use-character-maps="macroman-xtags" />

    <!-- import the various character maps we can use to generate accented
         letters in Xtags format -->
    <xsl:include href="character-maps.xsl" />

    <!-- OUTPUT PARAMETERS
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -format:
        Determines whether output is formatted for QuarkXpress or InDesign.
        - QuarkXpress: 'quark'
        - InDesign:    'indesign'
        Defaults to QuarkXpress.
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <xsl:param name="format" as="xs:string" select="'quark'" />
    <!-- other params -->
    <xsl:param name="output-directory">print-output</xsl:param>
    <xsl:param name="output-extension">.txt</xsl:param>


    <xsl:template match="/">
        <!-- output each <schedule-type> to its own file -->
        <xsl:result-document href="{$output-directory}/full-schedule{$output-extension}">
            <!-- preamble -->
            <xsl:value-of select="fn:preamble()" />
            
            <xsl:apply-templates select="schedule" />
        </xsl:result-document>

        <xsl:result-document href="{$output-directory}/index{$output-extension}">
            <!-- preamble -->
            <xsl:value-of select="fn:preamble()" />
            
            <xsl:call-template name="make-index" />
        </xsl:result-document>

        <!-- output each division to its respective <schedule-type> folder -->
        <xsl:for-each select="schedule/division">
            <xsl:result-document href="{$output-directory}/divisions/{@machine_name}{$output-extension}">
                <!-- preamble -->
                <xsl:value-of select="fn:preamble()" />
                
                <xsl:apply-templates select="." />
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>


    <!-- check params -->
    <xsl:template match="/schedule">
        <xsl:choose>
            <xsl:when test="lower-case($format) = 'quark' or lower-case($format) = 'indesign'">
                <xsl:next-match />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>You must choose either 'quark' or 'indesign' as the output format.</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- start processing -->
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

            <xsl:value-of select="fn:p-tag('Index Letter')" /><xsl:value-of select="$current-letter" /><xsl:value-of select="fn:newline()" />

            <xsl:apply-templates select="$divisions" mode="index">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="division" mode="index">
        <xsl:value-of select="fn:p-tag('Index Division')" />
        <xsl:value-of select="@name" />
        <xsl:value-of select="fn:sep()" />
        <xsl:value-of select="fn:newline()" />
        
        <xsl:if test="cluster">
            <xsl:apply-templates select="cluster" mode="index">
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

    <xsl:template match="cluster" mode="index">
        <xsl:value-of select="fn:p-tag('Index Cluster')" />
        <xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@name" />
        <xsl:value-of select="fn:sep()" />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>



    <!-- division template -->
    <xsl:template match="division">
        <xsl:value-of select="fn:p-tag('Subject')" /><xsl:value-of select="upper-case(@name)" /><xsl:value-of select="fn:newline()" />

        <!-- First, show courses without clusters (sorted by cluster sort order) -->
        <xsl:apply-templates select="course">
            <xsl:sort data-type="number" select="@cluster_sort_order" order="ascending" />
        </xsl:apply-templates>

        <xsl:if test="course and cluster">
            <xsl:value-of select="fn:br()" />
        </xsl:if>

        <!-- Second, show clusters inside this division -->
        <xsl:apply-templates select="cluster">
            <xsl:sort select="@name" order="ascending" />
        </xsl:apply-templates>

        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:p-tag('End Division')" />
            <xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>



    <!-- cluster template -->
    <xsl:template match="cluster">
        <xsl:value-of select="fn:p-tag('Subhead')" /><xsl:value-of select="upper-case(@name)" /><xsl:value-of select="fn:newline()" />

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
            <xsl:value-of select="fn:p-tag('End Cluster')" />
            <xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>


    <!-- course template -->
    <xsl:template match="course">
        <xsl:variable name="tagname">
            <xsl:if test="ancestor::schedule-type/@name = 'LIFELONG LEARNING'">
                Lifelong Learning
            </xsl:if>
            Course Title
        </xsl:variable>
        <xsl:value-of select="fn:p-tag($tagname)" />
        <xsl:value-of select="upper-case(@title)" />
        <xsl:value-of select="fn:newline()" />

        <xsl:apply-templates select="prerequisites" />

        <xsl:apply-templates select="course_description" />
        <xsl:apply-templates select="textbooks" />
        <xsl:apply-templates select="supplies" />

        <xsl:value-of select="fn:p-tag('Start Classes')" />
        <xsl:value-of select="fn:newline()" />
    	<xsl:apply-templates select="class">
            <xsl:sort select="@date_sortkey" data-type="number" order="ascending" />
            <xsl:sort select="@time_sortkey" data-type="number" order="ascending" />
        </xsl:apply-templates>

    	<xsl:if test="notes">
    	    <xsl:value-of select="fn:p-tag('End Classes')" />
    	    <xsl:value-of select="fn:newline()" />
    	</xsl:if>
    	<xsl:apply-templates select="notes" />

        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:p-tag('End Course')" />
            <xsl:value-of select="fn:newline()" />
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
        <xsl:value-of select="fn:p-tag($tagname)" />
    	
        <!-- if the class number is missing, print a bold placeholder -->
        <xsl:choose>
            <xsl:when test="not(@class_number)">
                <xsl:text>&lt;B&gt;XXXX-XXXX-XXXXX&lt;$&gt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@class_number"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="fn:sep()" />

    	<!-- reg number -->
    	<xsl:value-of select="@reg_num" />
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- dates -->
    	<xsl:value-of select="@start_date"/>-<xsl:value-of select="@end_date"/>
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- hours / session -->
        <xsl:value-of select="@hours"/>hrs/<xsl:value-of select="@session"/>
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- needs an extra seperator here -->
        <xsl:value-of select="fn:sep()" />
        
    	<!-- days -->
    	<xsl:value-of select="@days"/>
        <xsl:value-of select="fn:sep()" />
    	
    	
    	<!-- newline -->
        <xsl:value-of select="fn:newline()" />
    	
    	<!-- tag -->
        <xsl:value-of select="fn:p-tag($tagname)" />
    	
    	<!-- sep -->
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- times -->
        <xsl:value-of select="@time_formatted"/>
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- extra sep -->
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- location-room -->
    	<xsl:value-of select="@location"/>-<xsl:value-of select="@room"/>
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- faculty -->
    	<xsl:value-of select="@faculty"/>
        <xsl:value-of select="fn:sep()" />
    	
    	<!-- tuition -->
    	<xsl:value-of select="@tuition"/>
        <xsl:value-of select="fn:sep()" />
        
        <!-- term -->
        <xsl:value-of select="@term" />
        
    	
    	<!-- newline -->
        <xsl:value-of select="fn:newline()" />
    </xsl:template>


    <xsl:template match="course_description">
        <xsl:if test="not(p)">
            <xsl:value-of select="fn:p-tag('Annotation')" />
            <xsl:value-of select="." />
            <xsl:value-of select="fn:newline()" />
            
            <xsl:if test="position() != last() or (not(ancestor::course/textbooks) and not(ancestor::course/supplies))">
                <xsl:value-of select="fn:br()" />
            </xsl:if>
        </xsl:if>

        <xsl:apply-templates select="p" />
    </xsl:template>

    <xsl:template match="notes">
        <xsl:value-of select="fn:p-tag('Notes')" />
        <xsl:value-of select="fn:c-tag('Bold', 'Notes: ')" />
        <xsl:value-of select="." />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>


    <xsl:template match="catalog_page_header | catalog_prefix | suffix_description">

        <xsl:if test="not(p)">
            <xsl:value-of select="fn:p-tag('Notes')" />
            <xsl:value-of select="." />
            <xsl:value-of select="fn:newline()" />
        </xsl:if>

        <xsl:apply-templates select="p" />

        <xsl:if test="self::catalog_page_header or self::catalog_prefix">
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>


    <xsl:template match="p">
        <xsl:value-of select="fn:p-tag('Annotation')" />
        
        <xsl:apply-templates />

        <xsl:if test="position() != last() or (not(ancestor::course/textbooks) and not(ancestor::course/supplies))">
            <xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>


    <xsl:template match="url|email">
        <xsl:value-of select="fn:c-tag('WWW', .)"></xsl:value-of>
    </xsl:template>


    <xsl:template match="prerequisites">
        <xsl:variable name="tagname">
            <xsl:if test="ancestor::schedule-type/@name = 'LIFELONG LEARNING'">
                Lifelong Learning
            </xsl:if>
            Prerequisites
        </xsl:variable>
        <xsl:value-of select="fn:p-tag($tagname)" />
        <xsl:value-of select="concat('Prerequisites: ', .)" />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>

    <xsl:template match="textbooks">
        <xsl:text>  Text:  </xsl:text>
        <xsl:value-of select="." />
        <xsl:if test="not(ancestor::course/supplies)">
            <xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="supplies">
        <xsl:text>  </xsl:text>
        <xsl:value-of select="." />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>





    <!--PICK-FORMAT NAMED TEMPLATES
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        insert special characters into the output
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <!-- insert preamble -->
    <xsl:function name="fn:preamble" as="xs:string">
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <!-- quark preamble is <v7.31><e0>\r -->
                <xsl:value-of select="concat('&lt;v7.31&gt;&lt;e0&gt;', fn:newline())" />
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
                <xsl:text>&#10;</xsl:text>
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
                        <xsl:value-of select="concat(fn:newline(), fn:newline($count - 1))" />
                    </xsl:when>
                    <xsl:when test="$format = 'indesign'">
                        <xsl:value-of select="concat(fn:newline(), fn:newline($count - 1))" />
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
                <xsl:value-of select="concat(fn:p-tag('Spacer'), fn:newline())" />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <xsl:value-of select="concat(fn:p-tag('Empty Line'), fn:newline())" />
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
                        <xsl:value-of select="concat(fn:br(), fn:br($count - 1))" />
                    </xsl:when>
                    <xsl:when test="$format = 'indesign'">
                        <xsl:value-of select="concat(fn:br(), fn:br($count - 1))" />
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
        table tags (look like '<TableStyle:StyleName><TableStart><RowStart><CellStart><CellEnd><RowEnd><TableEnd>')
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <xsl:function name="fn:TableStyle" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:value-of select="concat('&lt;TableStyle:', normalize-space($style-name), '&gt;')" />
    </xsl:function>
    
    <xsl:function name="fn:CellStyle" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:value-of select="concat('&lt;CellStyle:', normalize-space($style-name), '&gt;')" />
    </xsl:function>
    
    <xsl:function name="fn:TableStart" as="xs:string">
        <xsl:param name="rows" as="xs:integer" />
        <xsl:param name="cols" as="xs:integer" />
        
        <xsl:value-of select="concat('&lt;TableStart:', $rows, ',', $cols, ':0:0&gt;')" />
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
