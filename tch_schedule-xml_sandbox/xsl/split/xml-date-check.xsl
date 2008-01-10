<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Includes & Output
		======================================================================-->
	<xsl:include
		href="../prep/xml-utils.xsl" />
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils" doctype-system="../dtds/xml-formed.dtd"/>
	
	
	<xsl:template match="/" priority="2">
		<xsl:variable name="date" select="current-date()" as="xs:date" />
		<xsl:variable name="date-str" select="format-date($date, '[D]/[M]/[Y]')" as="xs:string" />
		<xsl:message>Today's date is <xsl:value-of select="$date" /></xsl:message>
		<xsl:message>That converts to: <xsl:value-of select="utils:convert-date-std($date-str)" /></xsl:message>
	</xsl:template>
	
</xsl:stylesheet>