<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
	exclude-result-prefixes="xs utils fn">

	<!--=====================================================================
		Description
		
		This stylesheet handles all of the indexing tasks associated with
		creating a web schedule (web, enrolling now, enrolling soon).
		======================================================================-->
	

	<!--=====================================================================
		Setup
		
		Creates the index page shell.
		======================================================================-->
	<xsl:template match="schedule|term|special-section" mode="init-index">
		<xsl:param name="title"  as="xs:string" tunnel="yes" />
		<xsl:param name="header" as="xs:string" tunnel="yes" />
		
		
		<xsl:call-template name="aspx-preamble" />
		
		<html>
			<head>
				<xsl:call-template name="bhc-meta">
					<xsl:with-param name="title" select="$title" />
				</xsl:call-template>
				
				<link rel="stylesheet" type="text/css" href="/course-schedules/credit/schedule.css" />
			</head>
			
			<body class="with-sidebar">
				<xsl:call-template name="bhc-header" />
				
				<div id="channel-header" class="course-schedules">
					<h1><xsl:value-of select="$header" /></h1>
				</div>
				
				<div id="page-container">
					
					<div id="page-header">
						
						<div id="breadcrumbs">
							<xsl:apply-templates select="." mode="make-breadcrumbs" />
						</div>
						
						<h1><xsl:value-of select="$title" /></h1>
					
					</div>
					
					<div class="page-content">
						
						<xsl:call-template name="make-econnect-notice" />
						
						<xsl:apply-templates select="." mode="make-jump-to" />
						
						<xsl:apply-templates select="." mode="index" />
						
					</div> <!-- end page-content -->
				</div> <!-- end page-container -->
				
				<xsl:call-template name="bhc-sidebar" />
				
				<xsl:call-template name="bhc-footer" />
				
			</body>
		</html>
		
	</xsl:template>


	<!--=====================================================================
		Content
		
		Creates the index page content w/links, etc.
		======================================================================-->
	<xsl:template match="schedule" mode="index">
		<xsl:apply-templates select="term" />
	</xsl:template>
	
	<xsl:template match="term[@display = 'false']">
		<xsl:message><xsl:text>!Warning! Skipping suppressed term </xsl:text><xsl:value-of select="@name" /><xsl:text>.</xsl:text></xsl:message>
	</xsl:template>
	<xsl:template match="term" mode="index">
		<!-- NOTE TO SELF:
			DIVIDE INTO COLUMNS HERE! -->
		
		<!-- list regular sections -->
		<h1><a name="{utils:make-url(@name)}"></a><xsl:value-of select="@name" /></h1>
		<xsl:call-template name="make-core-legend" />
		<xsl:apply-templates select="division/subject" mode="index" />
		
		<!-- list special sections -->
		<!-- DEV NOTE: POSSIBLE PROBLEM WITH FLEX TERMS HERE! -->
		<h1><a name="{utils:make-url(@name)}"></a><xsl:value-of select="@name" /></h1>
		<xsl:call-template name="make-core-legend" />
		<xsl:apply-templates select="special-section" mode="index" />
	</xsl:template>
	
	<xsl:template match="special-section" mode="index">
		<xsl:apply-templates select="descendant::subject" mode="index" />
	</xsl:template>
						
	
	<!--=====================================================================
		Make Templates
		
		Creates specific portions of the page
		======================================================================-->
	
	
	
	
	
	<xsl:template name="create-index-schedule">
		<xsl:param name="title" as="xs:string" />
		
		<div class="complete-index">
			<xsl:call-template name="create-jumpto" />
			
			<xsl:apply-templates select="term" mode="index">
				<xsl:sort select="@sortkey" />
				<xsl:sort select="@name" />
			</xsl:apply-templates>
		</div>
	</xsl:template>
	
	<xsl:template match="term" mode="index">
		
	</xsl:template>
	
	
	
	
	
	<!--=====================================================================
		Utility templates
		
		cleans up the above code by shoving the messy bits into mini-templates
		======================================================================-->
	<!-- Jump To -->
	<xsl:template name="create-jumpto">
		<!-- processing variables -->
		<xsl:variable name="multiple-terms" select="count(//term) &gt; 1" />
		
		<xsl:variable name="items" as="xs:string*">
			<xsl:choose>
				<xsl:when test="count(//term) &gt; 1">
					<xsl:value-of select="//term/@semester" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="//type[@id = 'DL' and utils:has-classes(.)]">
						<xsl:value-of select="'Distance Learning'"></xsl:value-of></xsl:if>
					<xsl:if test="//class[@topic-code = ('FD','FN') and utils:has-classes(.)]">
						<xsl:value-of select="'Flex Term'" /></xsl:if>
					<xsl:if test="//type[@id = 'W' and utils:has-classes(.)]">
						<xsl:value-of select="'Weekend'" /></xsl:if>
					<xsl:if test="//type[@id = 'W']/descendant::course[@core-code and @core-code != '' and utils:has-classes(.)]">
						<xsl:value-of select="'Weekend Core Curriculum'" /></xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<p>Jump to:
			<xsl:for-each select="$items">
				<a href="#{utils:make-url(.)}"><xsl:value-of select="concat(., ' Courses')" /></a>
				<xsl:if test="position() != last()"><xsl:text>&#160;&#160;|&#160;&#160;</xsl:text></xsl:if>
			</xsl:for-each>
		</p>
	</xsl:template>
</xsl:stylesheet>