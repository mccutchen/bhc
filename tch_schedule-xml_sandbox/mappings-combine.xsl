<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">
	
	<!-- utility functions -->
	<xsl:include
		href="xml-utils.xsl" />
	
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes"
		exclude-result-prefixes="xs utils fn" />
	
	<!-- command line parameters -->
	<xsl:param name="semester" as="xs:string" />
	<xsl:param name="year"     as="xs:string" />
	
	<!-- save some typing on edit -->
	<xsl:variable name="dir"   select="concat('mappings/',$year,'-',$semester,'/')" as="xs:string"  />

	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'final'" />
	<!--
		<xsl:variable name="release-type" select="'debug-templates'" as="xs:string" />
		<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- 
		This transformation combines the mappings files into a single file for easier use in subsequent transformations.
	-->
	
	
	<!-- start (copy everything except subject and comment()s -->
	<xsl:template match="mappings|division|subject|topic|subtopic|pattern|contact">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	<!-- comments may have sub-elements, so copy 'em whole -->
	<xsl:template match="comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<!-- strip comments - this is a processing copy, not a user-side copy --> 
	<xsl:template match="comment()" />
	
	<!-- file elements need to be treated a little differently -->
	<xsl:template match="file">
		<!-- snag the replacement elements from the file specified -->
		<xsl:variable name="name"         select="parent::subject/@name" as="xs:string" />
		<xsl:variable name="sub-elements" select="doc(concat($dir, @src))/descendant::subject[@name = $name]/*" as="element()*" />
		
		<!-- if not found, or empty, present user with error message -->
		<xsl:if test="count($sub-elements) eq 0">
			<xsl:message>
				<xsl:text>Unable to find </xsl:text>
				<xsl:value-of select="file/@src" />
				<xsl:text>, or file does not contain information for.</xsl:text>
				<xsl:value-of select="@name" />
				<xsl:text>.</xsl:text>
			</xsl:message>
		</xsl:if>
		
		<!-- in place of the file element, add the elements it pointed to -->
		<xsl:apply-templates select="$sub-elements" />
		
	</xsl:template>
	
</xsl:stylesheet>