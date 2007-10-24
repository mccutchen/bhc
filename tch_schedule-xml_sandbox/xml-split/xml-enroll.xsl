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
		Parameters
		======================================================================-->
	<!-- output directory -->
	<xsl:param name="output-directory" as="xs:string" />
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="ext" select="'xml'" as="xs:string" />
	
	
	<!--=====================================================================
		Simple Transformation
		
		Creates the second of two custom derivations of the xml:
		1) trimmed: all is-suppressed classes (and empty ancestor nodes) are
		removed.
		2) enrolling: lists only classes that fit within the enrolling window
		======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|course">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*[descendant::class[@is-suppressed = 'false' and @is-enrolling = 'true']]" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="class|contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
</xsl:stylesheet>