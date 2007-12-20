<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- utility functions -->
	<xsl:include
		href="../xml-prep/xml-utils.xsl" />
	<!-- output -->
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils" doctype-system="../dtds/xml-formed.dtd"/>
	
	
	<!--=====================================================================
		Parameters
		
		date-min is required because xsl is retarded. I mean, really. Who would
		ever want to use the current date/time in xsl? Um. Everyone? Too bad.
		No way to access that, even in xslt 2.0. Of course, you could use 
		extensions, because that way your code relies on a third party whose 
		code is not part of the official xslt standard and could disappear or
		change without notice.
		======================================================================-->
	<!-- output directory -->
	<xsl:param name="date-min" as="xs:string" />
	
	
	<!--=====================================================================
		Simple Transformation
		
		lists only classes that fit within the enrolling window (ie, after the
		supplied date)
		======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|course">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*[descendant-or-self::class[utils:compare-dates(@date-start, $date-min) != -1]]" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="class|contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
</xsl:stylesheet>