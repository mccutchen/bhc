<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	exclude-result-prefixes="xs utils">
	
	<xsl:template match="schedule|term|special-section|subject" mode="create-page" priority="1">
		<xsl:param name="title"   as="xs:string" tunnel="yes" />
		<xsl:param name="channel" as="xs:string" tunnel="yes" />
		
		<xsl:call-template name="aspx-preamble" />
		<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html; charset=us-ascii" />
				<xsl:call-template name="aspx-meta" />
				<link rel="stylesheet" type="text/css" href="/course-schedules/credit/schedule.css" />
			</head>
			<xsl:call-template name="newline" />
			
			<body class="with-sidebar">
				<xsl:call-template name="aspx-header" />
				
				<div id="channel-header" class="course-schedules">
					<h1><xsl:value-of select="concat($channel, ' Course Schedule')" /></h1>
				</div>
				<xsl:call-template name="newline" />
				
				<div id="page-container">
					<div id="page-header">
						<xsl:call-template name="make-breadcrumbs" />
						<h1 class="division"><xsl:value-of select="$title" /></h1>
					</div>
					<xsl:call-template name="newline" />
					
					<div id="page-content">
						<p class="special-notice">
							<xsl:text>For a live version of the Credit Course Schedule, use </xsl:text> 
							<a href="http://econnect.dcccd.edu" target="_blank">eConnect</a>.
						</p>
						<xsl:call-template name="newline" />
						
						<xsl:next-match />
						
					</div> <xsl:comment> end of page-content </xsl:comment>
				</div> <xsl:comment> end of page-container </xsl:comment>
				<xsl:call-template name="newline" />
				
				<xsl:call-template name="aspx-sidebar" />
				<xsl:call-template name="aspx-footer"  />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="schedule" mode="create-page" priority="0">
		<div class="complete-index">
			<xsl:call-template name="make-jumpto">
				<xsl:with-param name="list" select="term[@display = 'true']/@name" />
			</xsl:call-template>
			
			<xsl:for-each select="term[@display = 'true']">
				<div class="term-section">
					<a name="{utils:make-url(@name)}"></a>
					<h2><a href="{utils:make-url(@name)}/"><xsl:value-of select="@name" /></a></h2>
					
					<xsl:apply-templates select="." mode="index">
						<xsl:with-param name="add-path" select="concat(utils:make-url(@name),'/')" tunnel="yes" />
					</xsl:apply-templates>
				</div>
				<xsl:call-template name="newline" />
			</xsl:for-each>
		</div>
		<xsl:call-template name="newline" />
	</xsl:template>
	
	<xsl:template match="term[@display = 'false']" mode="create-page">
		<xsl:message>Skipping non-display term: <xsl:value-of select="@name" /></xsl:message>
	</xsl:template>
	<xsl:template match="term" mode="create-page" priority="0">
		<div class="complete-index">
			<xsl:if test="count(special-section) &gt; 0">
				<xsl:call-template name="make-jumpto">
					<xsl:with-param name="list" select="special-section/@name" />
				</xsl:call-template>
			</xsl:if>
			
			<div class="term-section">
				<a name="{utils:make-url(@name)}"></a>
				<h2>Regular Credit Courses</h2>
				
				<xsl:apply-templates select="." mode="index">
					<xsl:with-param name="add-path"   select="''" tunnel="yes"/>
				</xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="special-section" mode="create-page">
		<xsl:apply-templates select="." mode="index">
			<xsl:with-param name="add-path"   select="''"      tunnel="yes" />
			<xsl:with-param name="index-type" select="'index'" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="subject" mode="create-page">
		<xsl:apply-templates select="." mode="page" />
	</xsl:template>
	

	<!--=====================================================================
		Make Templates
		
		Creates specific portions of the page
		======================================================================-->
	<xsl:template name="make-jumpto">
		<xsl:param name="list" as="xs:string*" />
		
		<p>Jump to:
			<xsl:for-each select="$list">
				<a href="#{utils:make-url(.)}"><xsl:value-of select="." /></a>
				<xsl:if test="position() != last()">
					<xsl:text>&#160;&#160;|&#160;&#160;</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</p>
		<xsl:call-template name="newline" />
	</xsl:template>
	
	<xsl:template name="make-breadcrumbs">
		<div id="breadcrumbs">
			<a href="/">Home</a>&#160;&#160;&#187;&#160;
			<a href="/course-schedules/">Course Schedules</a>&#160;&#160;&#187;&#160;
			
			<xsl:apply-templates select="." mode="make-crumb">
				<xsl:with-param name="level" select="0" />
			</xsl:apply-templates>
		</div>
	</xsl:template>
	<xsl:template name="make-crumb">
		<xsl:param name="name"  as="xs:string" />
		<xsl:param name="level" as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="$level = 0">
				<a class="selected"><xsl:value-of select="$name" /></a>
			</xsl:when>
			<xsl:otherwise>
				<a href="{utils:repeat-string('../',$level)}"><xsl:value-of select="$name" /></a>&#160;&#160;&#187;&#160;
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- schedule or single term-->
	<xsl:template match="schedule | term[count(parent::schedule/term) = 1]" mode="make-crumb" priority="2">
		<xsl:param name="level"   as="xs:integer" />
		<xsl:param name="channel" as="xs:string" tunnel="yes" />
		
		<xsl:call-template name="make-crumb">
			<xsl:with-param name="name"  select="$channel" />
			<xsl:with-param name="level" select="$level"   />
		</xsl:call-template>
	</xsl:template>
	<!-- multi-term -->
	<xsl:template match="term" mode="make-crumb">
		<xsl:param name="level"  as="xs:integer" />
		
		<xsl:apply-templates select="parent::schedule" mode="make-crumb">
			<xsl:with-param name="level" select="$level + 1" />
		</xsl:apply-templates>
		
		<xsl:call-template name="make-crumb">
			<xsl:with-param name="name"  select="@name" />
			<xsl:with-param name="level" select="$level" />
		</xsl:call-template>
	</xsl:template>
	<!-- special section -->
	<xsl:template match="special-section" mode="make-crumb">
		<xsl:param name="level"  as="xs:integer" />
		
		<xsl:apply-templates select="ancestor::term" mode="make-crumb">
			<xsl:with-param name="level" select="$level + 1" />
		</xsl:apply-templates>
		
		<xsl:call-template name="make-crumb">
			<xsl:with-param name="name"  select="@name" />
			<xsl:with-param name="level" select="$level" />
		</xsl:call-template>
	</xsl:template>
	<!-- subject -->
	<xsl:template match="subject" mode="make-crumb">
		<xsl:param name="level"  as="xs:integer" />
		
		<xsl:apply-templates select="parent::division/parent::node()" mode="make-crumb">
			<xsl:with-param name="level" select="$level + 1" />
		</xsl:apply-templates>
		
		<xsl:call-template name="make-crumb">
			<xsl:with-param name="name"  select="@name" />
			<xsl:with-param name="level" select="$level" />
		</xsl:call-template>
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
			<xsl:text disable-output-escaping="yes">&#10;&lt;%@ register tagprefix="bhc" tagname="header"  src="~/includes/header.ascx"                 %&gt;</xsl:text>
			<xsl:text disable-output-escaping="yes">&#10;&lt;%@ register tagprefix="bhc" tagname="meta"    src="~/includes/meta.ascx"                   %&gt;</xsl:text>
			<xsl:text disable-output-escaping="yes">&#10;&lt;%@ register tagprefix="bhc" tagname="footer"  src="~/includes/footer.ascx"                 %&gt;</xsl:text>
			<xsl:text disable-output-escaping="yes">&#10;&lt;%@ register tagprefix="bhc" tagname="sidebar" src="~/course-schedules/credit/sidebar.ascx" %&gt;&#10;</xsl:text>
		</xsl:comment>
		<xsl:call-template name="newline" /><xsl:call-template name="newline" />
	</xsl:template>
	
	<xsl:template name="aspx-meta">
		<xsl:param name="title" as="xs:string" tunnel="yes" />
		<xsl:text disable-output-escaping="yes">&#10;&lt;bhc:meta title="</xsl:text>
		<xsl:value-of select="$title" />
		<xsl:text disable-output-escaping="yes">" runat="server" /&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template name="aspx-header">
		<xsl:text disable-output-escaping="yes">&#10;&lt;bhc:header searchPath="~/course-schedules/credit/" runat="server" /&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template name="aspx-footer">
		<xsl:text disable-output-escaping="yes">&#10;&lt;bhc:footer runat="server" /&gt;</xsl:text>
	</xsl:template>
	
	<xsl:template name="aspx-sidebar">
		<xsl:text disable-output-escaping="yes">&#10;&lt;bhc:sidebar runat="server" /&gt;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>