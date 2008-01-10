<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	exclude-result-prefixes="xs utils">
	
	
	<!-- to-int
		converts a string to an int, returns 0 if not possible -->
	<xsl:function name="utils:to-int" as="xs:integer">
		<xsl:param name="x" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="number($x)">
				<xsl:value-of select="xs:integer($x)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
	<!-- safe-min
		returns the minimum integer of the passed strings (converted safely) -->
	<xsl:function name="utils:safe-min" as="xs:integer">
		<xsl:param name="x" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="count($x) &lt; 1">
				<xsl:value-of select="0" />
			</xsl:when>
			<xsl:when test="count($x) = 1">
				<xsl:value-of select="utils:to-int($x[1])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="utils:safe-min($x[position() &gt; 1], utils:to-int($x[1]))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="utils:safe-min" as="xs:integer">
		<xsl:param name="x" as="xs:string*" />
		<xsl:param name="max" as="xs:integer" />
		
		<xsl:variable name="y" select="utils:to-int($x[1])" as="xs:integer" />
		<xsl:choose>
			<xsl:when test="count($x) = 0">
				<xsl:value-of select="$max" />
			</xsl:when>
			<xsl:when test="$max &lt; $y">
				<xsl:value-of select="utils:safe-min($x[position() &gt; 1], $y)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="utils:safe-min($x[position() &gt; 1], $max)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>