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
		
		all classes with (@is-suppressed = "true") are removed. Also removes 
		any ancestor nodes which would be empty as a result.
		 ======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|type|course">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*[descendant-or-self::class[@is-suppressed = 'false']]|contact|comments" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="class|contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>

</xsl:stylesheet>