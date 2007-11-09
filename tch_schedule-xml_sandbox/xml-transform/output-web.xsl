<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
	exclude-result-prefixes="xs utils fn">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<xsl:include href="output-utils.xsl" />
	<xsl:include href="output-web_page.xsl"  />
	<xsl:include href="output-web_index.xsl" />
	<xsl:output
		method="xhtml"
		encoding="us-ascii"
		indent="yes"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
	
	
	<!--=====================================================================
		Parameters
		======================================================================-->
	<!-- is this an "enrolling now" schedule? -->
	<xsl:param name="schedule-type" />	
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="output-type"  as="xs:string" select="if($schedule-type) then utils:make-url($schedule-type) else 'web')"  />
	<xsl:variable name="ext"          as="xs:string" select="'aspx'" />
	
	
	<!--=====================================================================
		Root
		
		sets some transformation-wide variables
		======================================================================-->
	<xsl:template match="/">
		<xsl:apply-templates select="schedule">
			<xsl:with-param name="title-prefix" select="if($schedule-type) then concat($schedule-type, ' - ') else ''" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!--=====================================================================
		Setup
		
		breaks the schedule down into manageable pieces and shuttles those
		pieces off to be processed.
		======================================================================-->
	<xsl:template match="/schedule">
		<!-- processing vars -->
		<xsl:variable name="base-dir" select="utils:generate-outdir(@year, @semester)" as="xs:string" />
		<xsl:variable name="path"     select="concat($base-dir, '_', $output-type)"    as="xs:string" />
		
		<!-- index: create schedule index -->
		<xsl:apply-templates select="." mode="init-index">
			<xsl:with-param name="path"  select="$path" tunnel="yes" />
			<xsl:with-param name="title" select="concat(@semester, ' ', @year, ' Credit Course Index')" tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- process the terms -->
		<xsl:apply-templates select="term" mode="setup">
			<xsl:with-param name="base-path" select="$path" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="term" mode="setup">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:variable name="path" select="concat($base-path, '/', utils:make-url(@name))" as="xs:string" />
		
		<!-- index: create term index -->
		<xsl:apply-templates select="." mode="init-index">
			<xsl:with-param name="path" select="$path" tunnel="yes" />
			<xsl:with-param name="title" select="concat(@name, ' Course Index')" tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- page: create subject pages -->
		<xsl:apply-templates select="division/subject" mode="init-page">
			<xsl:with-param name="base-path" select="$path" />
		</xsl:apply-templates>
		
		<!-- process special sections -->
		<xsl:apply-templates select="special-section" mode="setup">
			<xsl:with-param name="base-path" select="$path" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- if there are multiple levels of special sections, just pass through to the bottom -->
	<xsl:template match="special-section[special-section]">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:apply-templates select="special-section" mode="setup">
			<xsl:with-param name="base-path" select="$base-path" />
		</xsl:apply-templates>
	</xsl:template>
	<!-- once we get tot he bottom -->
	<xsl:template match="special-section[not(special-section)]" mode="setup">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:variable name="path" select="concat($base-path, '/', utils:make-url(@name))" as="xs:string" />

		<!-- index: create special-section indices -->
		<xsl:apply-templates select="special-section" mode="init-index">
			<xsl:with-param name="path"  select="$path" tunnel="yes" />
			<xsl:with-param name="title" select="concat(@name, ' Index')" tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- page: create special-section pages -->
		<xsl:apply-templates select="division/subject" mode="init-page">
			<xsl:with-param name="path" select="$path" />
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!--=====================================================================
		Init
		
		initializes result documents.
		======================================================================-->
	<xsl:template match="schedule|term|special-section" mode="init-index">
		<xsl:param name="path" as="xs:string" />
		<xsl:result-document href="{$path}/index.{$ext}">
			<xsl:apply-templates select="." mode="index" />
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="subject" mode="init-page">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:variable name="path" select="concat($path, '/', utils:make-url(parent::division/@name))" as="xs:string" />
		<xsl:result-document href="{$path}/{utils:make-url(@name)}.{$ext}">
			<xsl:apply-templates select="." mode="page">
				<xsl:with-param name="path"  select="$path" tunnel="yes" />
				<xsl:with-param name="title" select="@name" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>

</xsl:stylesheet>