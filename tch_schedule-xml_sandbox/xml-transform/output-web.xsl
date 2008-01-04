<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	exclude-result-prefixes="xs utils">
	
	<!--=====================================================================
		Description
		
		The meat of these operations are held in output-web_page.xsl and
		output-web_index.xsl. output-web.xsl is more of a controller. It
		passes the data to each of the other two transformations and does
		some high-level manipulation of inputs and default values
		======================================================================-->
	

	<!--=====================================================================
		Includes & Output
		======================================================================-->
	<xsl:include href="output-utils.xsl"        />
	<xsl:include href="output-web_template.xsl" />
	<xsl:include href="output-web_index.xsl"    />
	<xsl:include href="output-web_page.xsl"     />
	
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
	<xsl:variable name="prefix"       as="xs:string" select="if($schedule-type) then concat($schedule-type, ' - ') else ''" />
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="output-type"  as="xs:string" select="if($schedule-type) then utils:make-url($schedule-type) else 'web'" />
	<xsl:variable name="ext"          as="xs:string" select="'aspx'" />
	
	
	<!--=====================================================================
		Root
		
		breaks the schedule down into manageable pieces and shuttles those
		pieces off to be processed.
		======================================================================-->
	<xsl:template match="/schedule">
		<!-- processing vars -->
		<xsl:variable name="base-dir" select="utils:generate-outdir(@year, @semester)"           as="xs:string" />
		<xsl:variable name="path"     select="concat($base-dir, '_', $output-type)"              as="xs:string" />
		<xsl:variable name="channel"  select="concat($prefix, @semester, ' ', @year, ' Credit')" as="xs:string" />
		<xsl:variable name="title"    select="concat($channel, ' Course Index')"                  as="xs:string" />
		<xsl:variable name="year"     select="@year"                                             as="xs:string" />
		
		<!-- index: create schedule index -->
		<xsl:apply-templates select="." mode="init-index">
			<xsl:with-param name="path"    select="$path"    tunnel="yes" />
			<xsl:with-param name="channel" select="$channel" tunnel="yes" />
			<xsl:with-param name="title"   select="$title"   tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- process the terms -->
		<xsl:apply-templates select="term" mode="setup">
			<xsl:with-param name="base-path" select="$path"                 />
			<xsl:with-param name="channel"   select="$channel" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="term" mode="setup">
		<xsl:param name="base-path" as="xs:string"              />
		
		<!-- processing vars -->
		<xsl:variable name="path"  select="concat($base-path, '/', utils:make-url(@name))" as="xs:string" />
		<xsl:variable name="title" select="concat($prefix, @name, ' Course Index')"        as="xs:string" />
		
		<!-- index: create term index -->
		<xsl:apply-templates select="." mode="init-index">
			<xsl:with-param name="path"  select="$path"  tunnel="yes" />
			<xsl:with-param name="title" select="$title" tunnel="yes" />
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
	<xsl:template match="special-section[special-section]" mode="setup">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:apply-templates select="special-section" mode="setup">
			<xsl:with-param name="base-path" select="$base-path" />
		</xsl:apply-templates>
	</xsl:template>
	<!-- once we get to the bottom -->
	<xsl:template match="special-section[not(special-section)]" mode="setup">
		<xsl:param name="base-path" as="xs:string"              />
		
		<!-- processing vars -->
		<xsl:variable name="path"  select="concat($base-path, '/', utils:make-url(@name))" as="xs:string" />
		<xsl:variable name="title" select="concat($prefix, @name, ' Course Index')"        as="xs:string" />

		<!-- index: create special-section indices -->
		<xsl:apply-templates select="." mode="init-index">
			<xsl:with-param name="path"  select="$path"  tunnel="yes" />
			<xsl:with-param name="title" select="$title" tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- page: create special-section pages -->
		<xsl:apply-templates select="division/subject" mode="init-page">
			<xsl:with-param name="base-path" select="$path" />
			<xsl:with-param name="section"   select="@name" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>
	
	
	<!--=====================================================================
		Init
		
		initializes result documents.
		======================================================================-->
	<xsl:template match="schedule|term|special-section" mode="init-index">
		<xsl:param name="path" as="xs:string" tunnel="yes" />
		<xsl:result-document href="{$path}/index.{$ext}">
			<xsl:apply-templates select="." mode="create-page">
				<xsl:with-param name="mode"   select="'index'" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="subject" mode="init-page">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:result-document href="{$base-path}/{utils:make-url(@name)}.{$ext}">
			<xsl:apply-templates select="." mode="create-page">
				<xsl:with-param name="path"  select="$base-path"  tunnel="yes" />
				<xsl:with-param name="title" select="@name"  tunnel="yes" />
				<xsl:with-param name="mode"  select="'page'" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>
	
	
	<!--=====================================================================
		Generic templates
		
		Shortcuts for common tasks
		======================================================================-->
	<xsl:template name="br">
		<xsl:text disable-output-escaping="yes">&lt;br /&gt;</xsl:text>
	</xsl:template>
	<xsl:template name="newline">
		<xsl:text disable-output-escaping="yes">&#10;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>