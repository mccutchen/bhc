<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- output -->
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs" doctype-system="../dtds/xml-formed.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		Courses are split apart by their classes' sortkeys
		======================================================================-->
	<xsl:template match="schedule | term | division | subject | topic | subtopic">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact | comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="type">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />

			<xsl:variable name="classes" select="descendant::class" as="element()*" />
			<xsl:apply-templates select="descendant::class">
				<xsl:sort select="@sortkey" data-type="number" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:variable name="prev" select="preceding-sibling::class[position() = last()]" as="element()*" />
		<xsl:if test="not($prev) or not($prev/parent::course = parent::course)">
			<xsl:element name="course">
				<xsl:copy-of select="parent::course/attribute()" />
				<xsl:attribute name="sortkey" select="@sortkey" />
				<xsl:copy-of select="parent::course/comments" />
				
				<xsl:copy-of select="." />
				<xsl:variable name="next" select="following-sibling::class[1]" as="element()*" />
				<xsl:apply-templates select="$next" mode="fill" />
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="class" mode="fill">
		<xsl:variable name="prev" select="preceding-sibling::class[position() = last()]" as="element()*" />
		<xsl:if test="$prev/parent::course = parent::course">
			<xsl:copy-of select="." />
			<xsl:variable name="next" select="following-sibling::class[1]" as="element()*" />
			<xsl:apply-templates select="$next" mode="fill" />
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>