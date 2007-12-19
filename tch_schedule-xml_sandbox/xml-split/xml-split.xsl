<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- output -->
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils fn" doctype-system="../dtds/xml-formed.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		Courses are split apart by their classes' sortkeys
		======================================================================-->
	<xsl:template match="schedule | term | division | subject | topic | subtopic | type">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact | comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="course">
		<xsl:variable name="course" select="." as="element()" />
		
		<!-- copy un-sorted classes -->
		<xsl:variable name="unsorted" select="class[not(@sortkey)]" as="element()*" />
		<xsl:call-template name="copy-classes">
			<xsl:with-param name="course"  select="$course" />
			<xsl:with-param name="classes" select="$unsorted" />
		</xsl:call-template>
		
		<!-- copy sorted classes -->
		<xsl:for-each-group select="class" group-by="@sortkey">
			<xsl:call-template name="copy-classes">
				<xsl:with-param name="course"  select="$course" />
				<xsl:with-param name="classes" select="current-group()" />
			</xsl:call-template>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template name="copy-classes">
		<xsl:param name="course"  as="element()" />
		<xsl:param name="classes" as="element()*" />
		
		<xsl:if test="count($classes) &gt; 0">
			<xsl:element name="course">
				<xsl:copy-of select="$course/attribute()" />
				<xsl:attribute name="sortkey" select="$classes[1]/@sortkey" />
				<xsl:copy-of select="$course/comments" />
				
				<xsl:copy-of select="$classes" />
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>