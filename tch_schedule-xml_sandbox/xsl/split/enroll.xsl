<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Includes & Output
		======================================================================-->
	<xsl:include
		href="../prep/prep-utils.xsl" />
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils" doctype-system="../dtds/xml-formed.dtd"/>
	
	
	<!--=====================================================================
		Global
		======================================================================-->
	<xsl:variable name="current-date" select="utils:convert-date-std(format-date(current-date(), '[M]/[D]/[Y]'))" as="xs:string" />
	
	<!--=====================================================================
		Simple Transformation
		
		lists only classes that fit within the enrolling window (ie, after the
		supplied date)
		======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|type|course">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*[descendant-or-self::class[utils:compare-dates(@date-start, $current-date) != -1]]" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="class|contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
</xsl:stylesheet>