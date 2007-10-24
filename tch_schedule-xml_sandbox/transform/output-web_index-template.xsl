<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
	exclude-result-prefixes="xs utils fn">
	
	<xsl:include href="output-utils.xsl" />
	
	<!--=====================================================================
		Schedule
		
		indexes the entire schedule.
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