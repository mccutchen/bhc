<?xml version="1.0" encoding="UTF-8"?>

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
    
    <xsl:strip-space elements="*" />

    
    <!-- =====================================================================
         Parameters
    ====================================================================== -->
    <xsl:param name="output-directory">web-output</xsl:param>
    <xsl:param name="output-extension">.aspx</xsl:param>

    <!-- the title to put in the div#channel-header in each output file -->
    <xsl:param name="channel-title">Workforce and Continuing Education Course Schedule</xsl:param>
    
    
    <!-- =====================================================================
         Includes
    ====================================================================== -->
    <xsl:include href="web-page-template.xsl" />
    <xsl:include href="utils.xsl" />
    

    <!-- =====================================================================
         Stage 1:  Set up the result documents
         
         The first template below creates result documents for each page in
         the schedule.  Then, each template with a mode of "init" inserts the
         web page template into its result document.  After that, the normal
         templates are applied, which inserts the actual content into the
         placeholder in the web page template.
    ====================================================================== -->
    <xsl:template match="/">
        <!-- Create the result document for the index -->
        <xsl:result-document href="{$output-directory}/index{$output-extension}">
            <xsl:apply-templates select="schedule" mode="init" />
        </xsl:result-document>

        <!-- Create a result document for each division -->
        <xsl:for-each select="schedule/division">
            <xsl:result-document href="{$output-directory}/{@machine_name}{$output-extension}">
                <xsl:apply-templates select="." mode="init" />
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- Insert the web page template into the result document created above,
         by calling the named "page-template" which was imported from the file
         "web-page-template.xsl". -->
    <xsl:template match="schedule | division" mode="init">
        <xsl:call-template name="page-template">
            <xsl:with-param name="page-title">
                <xsl:choose>
                    <xsl:when test="self::schedule">Schedule Index</xsl:when>
                    <xsl:otherwise><xsl:value-of select="@name" /></xsl:otherwise>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>


    <!-- =====================================================================
         Stage 2:  Create the index
         
         This stage creates the alphabetical index for the schedule.  See the
         "make-index" named template below for more information.
    ====================================================================== -->
    <xsl:template match="schedule">
        <div id="index">

            <!-- the A to Z index at the top of the page -->
            <div class="index">
                <div>
                    <xsl:text>Alphabetical Index:&#160;&#160;</xsl:text>
                    <xsl:for-each-group select="/schedule/division" group-by="substring(@name, 1,1)">
                        <xsl:sort select="current-grouping-key()" />
                        <xsl:variable name="current-letter" select="current-grouping-key()" />
                        <a href="#{$current-letter}"><xsl:value-of select="upper-case($current-letter)" /></a>
                        <xsl:if test="position() != last()">
                            <span> - </span>
                        </xsl:if>
                    </xsl:for-each-group>
                </div>
            </div>

            <!-- generate the actual index -->
            <xsl:call-template name="make-index" />
        </div>
    </xsl:template>

    <xsl:template name="make-index">
        <!-- This template is pretty complicated in its operation.  It was 
             constructed with the help of David Carlisle in this xsl-list
             thread:
             - http://biglist.com/lists/xsl-list/archives/200506/msg01159.html
             
             Basically, what it does is:
             - Build the entire index structure into one long <ul> inside the 
               $entire-index variable.  (My problem was that I could build the
               list but not split it evenly, David Carlisle suggested that I 
               build the entire list into a variable and then select into that 
               to split it, which never would have occurred to me.)
               
            - Count how many items are in $entire-index (plus a manual offset 
              to ensure even columns) and divide that by two, to get a 
              $midpoint-index.

            - Select the top-level $entire-index element which contains the 
              element at $midpoint-index into the variable $midpoint-element.

            - Put $midpoint-element and all of its preceding siblings into one 
              column, and put all of its following sibling into the next 
              column.

            See?  Complicated. -->

        <!-- store the entire index in sorted form in $entire-index -->
        <xsl:variable name="entire-index">
            <ul>
                <xsl:for-each-group select="/schedule/division" group-by="substring(@name,1,1)">
                    <xsl:sort select="current-grouping-key()" />
                    <xsl:variable name="current-letter" select="current-grouping-key()" />
                    <xsl:variable name="divisions" select="/schedule/division[substring(@name,1,1) = $current-letter]" />

                    <li class="letter">
                        <a name="{$current-letter}" id="{$current-letter}" />
                        <h2><xsl:value-of select="$current-letter" /></h2>
                        <ul>
                            <xsl:apply-templates select="$divisions" mode="index">
                                <xsl:sort select="@name" />
                            </xsl:apply-templates>
                        </ul>
                    </li>
                </xsl:for-each-group>
            </ul>
        </xsl:variable>

        <!-- $midpoint-offset is used to hand-tweak the columns a little bit -->
        <xsl:variable name="midpoint-offset" select="8" />

        <!-- figure out how many total items are in the index, to help 
             determine which one is the midpoint -->
        <xsl:variable name="midpoint-index" select="round(count($entire-index//li) div 2) + $midpoint-offset" />

        <!-- the midpoint element should be whichever "top-level" (the ones 
             representing each letter of the alphabet) contains the <li> at 
             $midpoint-index.  The top-level <li> elements are easily 
             identified by the presence of a named anchor -->
        <xsl:variable name="midpoint-element" select="$entire-index/descendant::li[$midpoint-index]/ancestor-or-self::li[@class='letter']" />

        <!-- set up the column structure -->
        <div class="fifty-fifty columns">
            <div class="left column">
                <ul>
                    <!-- put the $midpoint-element and everything before it 
                         into the first column -->
                    <xsl:copy-of select="$midpoint-element | $midpoint-element/preceding-sibling::li" />
                </ul>
            </div>

            <div class="right column">
                <ul>
                    <!-- put everything after $midpoint-element into the 
                         second column -->
                    <xsl:copy-of select="$midpoint-element/following-sibling::li" />
                </ul>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="division" mode="index">
        <li>
            <a name="{@machine_name}" id="{@machine_name}" />
            <a href="{@machine_name}{$output-extension}">
                <xsl:value-of select="@name" />
            </a>
            <xsl:if test="cluster">
                <ul>
                    <xsl:apply-templates select="cluster" mode="index">
                        <xsl:sort select="@name" />
                    </xsl:apply-templates>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="cluster" mode="index">
        <li>
            <a href="{parent::division/@machine_name}{$output-extension}#{@machine_name}">
                <xsl:value-of select="@name" />
            </a>
        </li>
    </xsl:template>


    <!-- =====================================================================
         Stage 3:  Create each division page
         
         These are the "normal" templates that insert the actual content into
         each division page in the schedule output.
    ====================================================================== -->
    <xsl:template match="division">
        <xsl:apply-templates select="catalog_page_header" />
        <xsl:apply-templates select="catalog_prefix" />

        <xsl:apply-templates select="course">
            <xsl:sort data-type="number" select="@cluster_sort_order" order="ascending" />
            <xsl:sort select="@course_number" />
        </xsl:apply-templates>

        <xsl:apply-templates select="cluster">
            <xsl:sort data-type="number" select="@catalog_sort_order" order="ascending" />
            <xsl:sort select="@name" order="ascending" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="cluster">
        <div class="cluster">
            <a name="{@machine_name}" />
            <h2><xsl:value-of select="@name" /></h2>

            <xsl:apply-templates select="catalog_page_header" />
            <xsl:apply-templates select="catalog_prefix" />

            <xsl:apply-templates select="course">
                <xsl:sort data-type="number" select="@cluster_sort_order" order="ascending" />
                <xsl:sort select="@course_number" />
            </xsl:apply-templates>

            <xsl:apply-templates select="suffix_description" />
        </div>
    </xsl:template>

    <xsl:template match="course">
        <div class="course">
            <a name="{@machine_name}" />
            <h3>
                <xsl:apply-templates select="@title" />
            </h3>

            <xsl:apply-templates select="prerequisites" />
            <xsl:apply-templates select="course_description" />
            <xsl:apply-templates select="supplies" />
            <xsl:apply-templates select="textbooks" />
            
            <!-- Do we need to include the class number column in the table?
                 We skip the class number for Arts Academy classes and for 
                 classes which don't have a number. -->
            <xsl:variable name="with-number">
                <xsl:choose>
                    <xsl:when test="not(class/@class_number) or ancestor::minor_division/@name = 'Arts Academy'">false</xsl:when>
                    <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- If there are classes to print, build the table structure to hold them -->
            <xsl:if test="class">
                <table border="1" cellpadding="10" cellspacing="0">
                    <tr>
                        <xsl:choose>
                            <!-- Conditional Spanish translation of the table
                                 headings for class listings.  TODO: Find a
                                 better way to do this. -->
                            <xsl:when test="not(@spanish)">
                                <xsl:if test="$with-number = 'true'">
                                    <th>Course Number</th>
                                </xsl:if>
								<th>Reg #</th>
                                <th>Dates</th>
                                <th>Hours / # Meetings</th>
                                <th>Class Times</th>
                                <th>Location</th>
                                <th>Days</th>
                                <th>Instructor</th>
                                <th>Tuition</th>
                                <th>Term</th>
                            </xsl:when>
                            <xsl:when test="@spanish">
                                <xsl:if test="$with-number = 'true'">
                                    <th>Numero del Curso</th>
                                </xsl:if>
								<th># de Reg</th>
                                <th>Fechas</th>
                                <th># de creditos / # de reuniones</th>
                                <th>Tiempo de clase</th>
                                <th>Lugar</th>
                                <th>Dias de clase</th>
                                <th>Instructor</th>
                                <th>Costo</th>
                                <th> </th>
                            </xsl:when>
                        </xsl:choose>
                    </tr>
                    <xsl:apply-templates select="class">
                        <xsl:with-param name="with-number" select="$with-number" />
                        <xsl:sort select="@date_sortkey" data-type="number" order="ascending" />
                        <xsl:sort select="@time_sortkey" data-type="number" order="ascending" />
                    </xsl:apply-templates>
                    <xsl:apply-templates select="notes" />
                </table>
                <p class="back-to-top">
                    <a href="#top">
                        <xsl:choose>
                            <xsl:when test="not(@spanish)">Back to the top</xsl:when>
                            <xsl:when test="@spanish">Volver al principio</xsl:when>
                        </xsl:choose>
                    </a>
                </p>
            </xsl:if>
        </div>
    </xsl:template>
    
    <xsl:template match="course/@title">
        <xsl:value-of select="." />
    </xsl:template>
    
    <xsl:template match="course[@concurrent]/@title" priority="9">
        <!-- Append a bullet point to the end of the course title of
             concurrent courses. -->
        <xsl:next-match />
        <span class="concurrent"> &#8226; <a href="/course-schedules/non-credit/concurrent/">Concurrent course</a></span>
    </xsl:template>
    
    <xsl:template match="course[@financial_aid]/@title" priority="10">
        <!-- Append a bullet point to the end of the course title of courses
             eligible for financial aid. -->
        <xsl:next-match />
        <span class="financial-aid"> &#8226; Eligible for <a href="/instruction/cce/financial-aid/">Financial Aid</a></span>
    </xsl:template>
    

    <xsl:template match="class">
        <xsl:param name="with-number">true</xsl:param>

        <xsl:variable name="evening" select="if (@evening) then 'evening' else ''" />
        <xsl:variable name="financial-aid" select="if (../@financial_aid) then 'financial-aid' else ''" />

        <tr class="{$evening} {$financial-aid}">
            <xsl:if test="$with-number = 'true'">
                <td><xsl:apply-templates select="@class_number" /></td>
            </xsl:if>

			<td><xsl:apply-templates select="@reg_num"/></td>
            <td><xsl:apply-templates select="@start_date"/> - <xsl:apply-templates select="@end_date"/></td>
            <td><xsl:apply-templates select="@hours"/> hrs / <xsl:apply-templates select="@session"/></td>
            <td><xsl:apply-templates select="@time_formatted"/></td>
            <td><xsl:apply-templates select="@location"/>-<xsl:apply-templates select="@room"/></td>
            <td><xsl:apply-templates select="@days" /></td>
            <td><xsl:apply-templates select="@faculty"/></td>
            <td><xsl:apply-templates select="@tuition"/></td>
            <td class="last"><xsl:apply-templates select="@term" /></td>
        </tr>
    </xsl:template>
    
    <xsl:template match="class/@days">
        <xsl:value-of select="." />
    </xsl:template>
    
    <xsl:template match="class[ancestor::division/@machine_name='senior_adult_courses']/@days" priority="2">
        <xsl:value-of select="utils:senior-adult-days(.)" />
    </xsl:template>


    <!-- =====================================================================
		Spanish translations
		
        The prerequisites, supplies and textbooks elements need to be output
		with a label which may or may not need to be in Spanish.  The
		following templates output the label in English by default, with
		specialized templates to provide the label in Spanish where needed.
    ====================================================================== -->
	<xsl:template match="prerequisites | supplies | textbooks">
		<!-- by default, the label is the same as the element name, with the
		     first letter uppercased -->
		<xsl:param name="label" select="concat(upper-case(substring(local-name(), 1, 1)), substring(local-name(), 2))" />
		<p class="{local-name()}"><xsl:value-of select="$label" />: <xsl:apply-templates /></p>
	</xsl:template>
	
	<!-- the following templates only match for courses that are in Spanish
		 and override the label with a Spanish translation -->
	<xsl:template match="prerequisites[ancestor::course/@spanish]">
		<xsl:next-match><xsl:with-param name="label">Requisitos</xsl:with-param></xsl:next-match>
	</xsl:template>
	
	<xsl:template match="supplies[ancestor::course/@spanish]">
		<xsl:next-match><xsl:with-param name="label">&#218;tiles escolares</xsl:with-param></xsl:next-match>
	</xsl:template>

	<xsl:template match="textbooks[ancestor::course/@spanish]">
		<xsl:next-match><xsl:with-param name="label">Libros de texto</xsl:with-param></xsl:next-match>
	</xsl:template>


    <xsl:template match="catalog_page_header | catalog_prefix | course_description | suffix_description">
        <!-- Automatically get the CSS class name from the name of the given
             element by replacing underscores with dashes. -->
        <xsl:variable name="class-name" select="translate(local-name(), '_', '-')" />
        <div class="{$class-name}">
            <xsl:apply-templates select="p" />
        </div>
    </xsl:template>

    <xsl:template match="notes">
        <tr class="notes">
            <td colspan="8">
                <b>Notes: &#160;</b><xsl:apply-templates />
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="p">
        <p><xsl:apply-templates /></p>
    </xsl:template>

    <xsl:template match="url">
		<xsl:variable name="address">
     		<xsl:if test="not(starts-with(current(), 'http://')) and not(starts-with(current(), 'https://'))">http://</xsl:if>
	       <xsl:value-of select="current()" />
		</xsl:variable>
        <xsl:variable name="display">
            <xsl:choose>
                <xsl:when test="exists(@display)">
                    <xsl:value-of select="@display" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <a href="{$address}" target="_blank"><xsl:value-of select="$display" /></a>
    </xsl:template>

    <xsl:template match="email">
        <a href="mailto:{current()}"><xsl:value-of select="." /></a>
    </xsl:template>
</xsl:stylesheet>
