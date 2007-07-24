<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:utils="http://www.brookhavencollege.edu/xml/utils"> <!-- for functions -->

	<!-- utility functions -->
	<xsl:include
	  href="utils.xsl" />
	  
	<!-- DEV NOTE: change this to xml later, for now I kinda like it opening not in dreamweaver -->
	<xsl:output
	  method="xhtml"
	  encoding="iso-8859-1"
	  indent="yes"
	  omit-xml-declaration="yes"
	  doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
	  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
	  
	<!-- some global vars -->
	<xsl:variable name="doc-divisions" select="document('divisions.xml')/divisions" />
	<xsl:variable name="doc-subjects"  select="document('subjects.xml')/subjects"   />
	<xsl:variable name="doc-contacts"  select="document('base.xml')/mappings/mapping[@type = 'contact-info']" />
	<!-- other globals I'll need to create:
	<xsl:variable name="doc-sorting-crud" and possibly name="doc-minimester-specs" /> -->
	
	<xsl:template match="divisions">
		<xsl:call-template name="spec-func">
			<xsl:with-param name="div" select="division[@name='World Languages']" />
		</xsl:call-template>
		
		<xsl:call-template name="spec-func2">
			<xsl:with-param name="div-patterns" select="division/descendant::pattern" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="spec-func">
		<xsl:param name="div" />
		
		<xsl:variable name="name" select="$div/@name" />
		<xsl:message><xsl:value-of select="$name" />:</xsl:message>
		<xsl:for-each select="$div/descendant::pattern">
			<xsl:sort select="@match" />
			<xsl:variable name="rubric" select="@match" />
			<xsl:message><xsl:text>    </xsl:text><xsl:value-of select="@match" />
			
				<xsl:for-each select="$doc-subjects/descendant::pattern">
					<xsl:if test="matches($rubric, @match)"><xsl:text> - </xsl:text><xsl:value-of select="./ancestor::subject/@name" />
					</xsl:if>
				</xsl:for-each>
				
			</xsl:message>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="spec-func2">
		<xsl:param name="div-patterns" />
		
		<xsl:for-each select="$doc-subjects/descendant::pattern">
			<xsl:sort select="@match" />
			
			<xsl:variable name="pattern"      select="@match" />
			<xsl:variable name="divs-matched" select="$div-patterns[matches($pattern,@match)]" />
			
			<xsl:if test="count($divs-matched) &lt; 1">
				<xsl:message><xsl:value-of select="$pattern" /><xsl:text> - no matches</xsl:text></xsl:message>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
