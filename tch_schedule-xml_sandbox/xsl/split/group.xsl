<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- output -->
	<xsl:output 
		method="xml" 
		encoding="iso-8859-1" 
		indent="yes"
		exclude-result-prefixes="xs fn" 
		doctype-system="../dtds/meetings.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		Adjacent classes with mutual cross-listings are noted
		======================================================================-->
	<xsl:template match="schedule | term | division | subject | topic | subtopic | type | course">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact | comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:variable name="pre-cross"  select="fn:concat('', preceding-sibling::class/@cross-group)" as="xs:string" />
			<xsl:variable name="post-cross" select="fn:concat('', following-sibling::class/@cross-group)" as="xs:string" />
			<xsl:if test="contains($pre-cross, @synonym) or contains($post-cross, @synonym)">
				<xsl:attribute name="is-grouped" select="'true'" />
			</xsl:if>

			<xsl:copy-of select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="fn:concat" as="xs:string">
		<xsl:param name="string" as="xs:string" />
		<xsl:param name="list" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="count($list) = 0">
				<xsl:value-of select="$string" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:concat(concat($string, $list[1]), $list[position() != 1])" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
</xsl:stylesheet>