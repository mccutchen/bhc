<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
	exclude-result-prefixes="xs utils fn">
	
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
	<xsl:variable name="output-type"  as="xs:string" select="if($schedule-type) then utils:make-url($schedule-type) else 'web'"  />
	<xsl:variable name="ext"          as="xs:string" select="'aspx'" />
	
	
	<!--=====================================================================
		Root
		
		breaks the schedule down into manageable pieces and shuttles those
		pieces off to be processed.
		======================================================================-->
	<xsl:template match="/schedule">
		<!-- processing vars -->
		<xsl:variable name="base-dir" select="utils:generate-outdir(@year, @semester)"                          as="xs:string" />
		<xsl:variable name="path"     select="concat($base-dir, '_', $output-type)"                             as="xs:string" />
		<xsl:variable name="prefix"   select="if($schedule-type) then concat($schedule-type, ' - ') else ''"    as="xs:string" />
		<xsl:variable name="header"   select="concat($prefix, @semester, ' ', @year, 'Credit Course Schedule')" as="xs:string" />
		<xsl:variable name="title"    select="concat($prefix, @semester, ' ', @year, ' Credit Course Index')"   as="xs:string" />
		<xsl:variable name="year"     select="@year"                                                            as="xs:string" />
		
		<!-- index: create schedule index -->
		<xsl:apply-templates select="." mode="init-index">
			<xsl:with-param name="path"   select="$path"   tunnel="yes" />
			<xsl:with-param name="prefix" select="$prefix" tunnel="yes" />
			<xsl:with-param name="header" select="$header" tunnel="yes" />
			<xsl:with-param name="title"  select="$title"  tunnel="yes" />
		</xsl:apply-templates>
		
		<!-- process the terms -->
		<xsl:apply-templates select="term" mode="setup">
			<xsl:with-param name="base-path" select="$path"                />
			<xsl:with-param name="prefix"    select="$prefix" tunnel="yes" />
			<xsl:with-param name="header"    select="$header" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="term" mode="setup">
		<xsl:param name="base-path" as="xs:string"              />
		<xsl:param name="prefix"    as="xs:string" tunnel="yes" />
		
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
	<xsl:template match="special-section[special-section]">
		<xsl:param name="base-path" as="xs:string" />
		<xsl:apply-templates select="special-section" mode="setup">
			<xsl:with-param name="base-path" select="$base-path" />
		</xsl:apply-templates>
	</xsl:template>
	<!-- once we get to the bottom -->
	<xsl:template match="special-section[not(special-section)]" mode="setup">
		<xsl:param name="base-path" as="xs:string"              />
		<xsl:param name="prefix"    as="xs:string" tunnel="yes" />
		
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
			<xsl:with-param name="path"    select="$path" />
			<xsl:with-param name="section" select="@name" tunnel="yes" />
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
		<xsl:variable name="path" select="concat($base-path, '/', utils:make-url(parent::division/@name))" as="xs:string" />
		<xsl:result-document href="{$path}/{utils:make-url(@name)}.{$ext}">
			<xsl:apply-templates select="." mode="page">
				<xsl:with-param name="path"  select="$path" tunnel="yes" />
				<xsl:with-param name="title" select="@name" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>


	<!--=====================================================================
		ASPX templates
		
		handles the asxp elements
		======================================================================-->
	<xsl:template name="aspx-preamble">
		<!-- normally, this would generate an error because it's a text node outside of the root node. 
			However, wrapping it in a comment works because xhtml comments can appear anywhere, and 
			ASPX evaluates code inside comments just fine. -->
		<xsl:comment>
			<xsl:text disable-output-escaping="yes">&lt;%@ register tagprefix="bhc" tagname="header" src="~/includes/header.ascx" %&gt;
				&lt;%@ register tagprefix="bhc" tagname="meta" src="~/includes/meta.ascx" %&gt;
				&lt;%@ register tagprefix="bhc" tagname="footer" src="~/includes/footer.ascx" %&gt;
				&lt;%@ register tagprefix="bhc" tagname="sidebar" src="~/course-schedules/credit/sidebar.ascx" %&gt;
			</xsl:text>
		</xsl:comment>
	</xsl:template>
	
	<xsl:template name="aspx-meta">
		<xsl:param name="title" />
		<xsl:text disable-output-escaping="yes">&lt;bhc:meta title="</xsl:text>
		<xsl:value-of select="$title" />
		<xsl:text disable-output-escaping="yes">" runat="server" /&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template name="aspx-header">
		<xsl:text disable-output-escaping="yes">&lt;bhc:header searchPath="~/course-schedules/credit/" runat="server" /&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template name="aspx-footer">
		<xsl:text disable-output-escaping="yes">&lt;bhc:footer runat="server" /&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template name="aspx-sidebar">
		<xsl:text disable-output-escaping="yes">&lt;bhc:sidebar runat="server" /&gt;</xsl:text>
	</xsl:template>

</xsl:stylesheet>