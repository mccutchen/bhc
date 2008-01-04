<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	exclude-result-prefixes="xs utils">
	
	<!--=====================================================================
		Description
		
		This stylesheet handles all of the indexing tasks associated with
		creating a web schedule (web, enrolling now, enrolling soon).
		======================================================================-->
	
	<!--=====================================================================
		Content
		
		Creates the index page content w/links, etc.
		======================================================================-->
	<xsl:template match="term[@display = 'false']" mode="index" priority="2">
		<xsl:message><xsl:text>!Warning! Skipping suppressed term </xsl:text><xsl:value-of select="@name" /><xsl:text>.</xsl:text></xsl:message>
	</xsl:template>
	<xsl:template match="term" mode="index">
		
		<div class="term-section">
			<!-- term name heading -->
			<!--<xsl:if test="$display-header">
				<h2><a name="{utils:make-url(@name)}"></a><xsl:text>Regular Credit Courses</xsl:text></h2>
			</xsl:if>-->
			
			<!-- core-legend -->
			<xsl:call-template name="make-core-legend" />
			
			<!-- columns -->
			<xsl:call-template name="make-columms">
				<xsl:with-param name="with-divs" select="true()" tunnel="yes" />
			</xsl:call-template>
			
			<!-- list special sections -->
			<xsl:apply-templates select="special-section" mode="index" />
		</div>
	</xsl:template>
	
	<xsl:template match="special-section[child::special-section]" mode="index">
		<a name="{utils:make-url(@name)}"></a>
		<xsl:apply-templates select="special-section" mode="index" />
	</xsl:template>
	<xsl:template match="special-section" mode="index">
		<xsl:param name="add-path"   as="xs:string" tunnel="yes" />
		<xsl:param name="index-type" as="xs:string" tunnel="yes" select="''" />
		
		<xsl:variable name="path" select="if ($index-type != 'index') then concat(utils:make-url(@name),'/') else ''" />
		<div class="special-section">
			<!-- term name heading -->
			<a name="{utils:make-url(@name)}"></a>
			<h3><a href="{$add-path}{$path}"><xsl:value-of select="@name" /><xsl:text> Courses</xsl:text></a></h3>
			
			<!-- columns -->
			<xsl:call-template name="make-columms">
				<xsl:with-param name="with-divs" select="false()"                  tunnel="yes" />
				<xsl:with-param name="add-path"  select="concat($add-path, $path)" tunnel="yes" />
			</xsl:call-template>
		</div>
	</xsl:template>

	
	
	<xsl:template match="subject" mode="index">
		<xsl:param name="with-divs"  as="xs:boolean" tunnel="yes" />
		<xsl:param name="add-path"   as="xs:string"  tunnel="yes" />
		
		<xsl:variable name="div"  select="parent::division/@name" as="xs:string" />
		<xsl:variable name="path" select="utils:make-url(@name)"  as="xs:string" />
		
		<li><a href="{$add-path}{$path}.{$ext}"><xsl:value-of select="@name"></xsl:value-of></a>
			<xsl:if test="$with-divs">
				<xsl:text disable-output-escaping="yes">&lt;br /&gt;</xsl:text>
				<span class="in-division"><xsl:value-of select="$div" /></span>
			</xsl:if>
		</li>
	</xsl:template>
						
	
	<!--=====================================================================
		Make Templates
		
		Creates specific portions of the page
		======================================================================-->
	<xsl:template name="make-columms">
		<div class="fifty-fifty columns">
			<xsl:variable name="subject-list" select="division/subject[@display != 'false']" as="element()*" />
			<xsl:variable name="subject-half" select="ceiling(count($subject-list) div 2)"   as="xs:decimal" />
			<!-- left column -->
			<div class="left column">
				<ul class="index-list">
					<xsl:for-each select="$subject-list">
						<xsl:sort select="@name" />
						<xsl:if test="position() &lt;= $subject-half">
							<xsl:apply-templates select="." mode="index" />
						</xsl:if>
					</xsl:for-each>
				</ul>
			</div>
			<!-- right column -->
			<div class="right column">
				<ul class="index-list">
					<xsl:for-each select="$subject-list">
						<xsl:sort select="@name" />
						<xsl:if test="position() &gt; $subject-half">
							<xsl:apply-templates select="." mode="index" />
						</xsl:if>
					</xsl:for-each>
				</ul>
			</div>
		</div>
		<a href="#top" class="back-to-top">Back to the top</a>
	</xsl:template>
	
	<xsl:template name="make-core-legend">
		<p class="core-notice">
			Look for <a href="/course-schedules/credit/core/">Core Curriculum</a> courses highlighted in gold.
		</p>
	</xsl:template>
	
</xsl:stylesheet>