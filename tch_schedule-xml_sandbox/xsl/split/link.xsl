<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Includes & Output
		======================================================================-->
	<xsl:include
		href="../prep/xml-utils.xsl" />
	<xsl:output 
		method="xml" 
		encoding="iso-8859-1" 
		indent="yes"
		exclude-result-prefixes="xs fn" 
		doctype-system="../dtds/meetings.dtd"/>
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="email-flag" select="'@dcccd.edu'"           as="xs:string"  />
	<xsl:variable name="link-flag"  select="('http://','https://')" as="xs:string*" />
	<xsl:variable name="dom-flag"   select="('.com','.net','.edu')" as="xs:string"  />
	
	<!--=====================================================================
		Simple Transformation
		
		lists only classes that fit within the enrolling window (ie, after the
		supplied date)
		======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|type|course|class">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="comments">
		<xsl:copy>
			<xsl:call-template name="link-text">
				<xsl:with-param name="text"  select="." />
				<xsl:with-param name="index" select="fn:find-next-link(.)" />
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template name="link-text">
		<xsl:param name="text"  as="xs:string" />
		<xsl:param name="index" as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="$index &lt; 0">
				<xsl:value-of select="$text" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring($text, 1,$index)" />
				<xsl:call-template name="find-link">
					<xsl:with-param name="text" select="substring($text, $index)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="find-link">
		<xsl:param name="text" as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="string-length($text) &lt; 1"></xsl:when>
			
			<xsl:otherwise>
				<xsl:variable name="text-array" select="fn:extract-link($text)" as="xs:string*" />
				<xsl:choose></xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
		
	</xsl:template>
	<xsl:variable name="linked" select="fn:link(.)" />
		<xsl:value-of select="fn:email($linked)" />
	</xsl:template>
	
	
	<!--=====================================================================
		Functions
		======================================================================-->
	<xsl:function name="fn:link">
		<xsl:param name="text" as="xs:string" />
		
		
	</xsl:function>
	<xsl:function name="fn:email">
		<xsl:param name="text" as="xs:string" />
		
		<!-- shell -->
		<xsl:value-of select="$text" />
	</xsl:function>
	
</xsl:stylesheet>