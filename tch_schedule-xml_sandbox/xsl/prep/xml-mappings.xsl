<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- utility functions -->
	<xsl:include
		href="xml-utils.xsl" />
	<!-- output -->
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes"
		exclude-result-prefixes="xs utils fn" />
	
	
	<!--=====================================================================
		Parameters
		======================================================================-->
	<!-- a second input file (for Summer semesters) -->
	<xsl:param name="path-mappings" />
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<!-- load the semester info file -->
	<xsl:variable name="file-info" select="replace(concat($path-mappings, '_info.xml'), '\\', '/')" as="xs:string" />
	<xsl:variable name="doc-info"  select="if (utils:check-file($file-info)) then doc($file-info)/info else ''" />
	
	<!--=====================================================================
		Begin Transformation
		
		Note: if there is more than one input file, the creation datetime
		will reflect the creation of the oldest input file.
		======================================================================-->
	<!-- start -->
	<xsl:template match="/mappings">
		<xsl:choose>
			<!-- if there's errors loading the semester info, bail out -->
			<xsl:when test="$doc-info = ''">
				<xsl:message>
					<xsl:text>Unable to load semester info from </xsl:text>
					<xsl:value-of select="$file-info" />
					<xsl:text>!</xsl:text>
				</xsl:message>
			</xsl:when>
			
			<!-- otherwise, proceed -->
			<xsl:otherwise>
				<xsl:copy>
					<xsl:copy-of select="$doc-info" />
					<xsl:apply-templates select="*" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- these elements may be ordered, so perform check -->
	<xsl:template match="term|division|subject|topic|subtopic">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:if test="parent::node()/@ordered = 'true'"><xsl:attribute name="sortkey" select="position()" /></xsl:if>
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	<!-- these elements cannot be ordered -->
	<xsl:template match="contact">
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
		<xsl:variable name="name"     select="parent::subject/@name"                                 as="xs:string" />
		<xsl:variable name="file-ext" select="replace(concat($path-mappings, '/', @src), '\\', '/')" as="xs:string" />
		<xsl:variable name="doc-ext"  select="if (utils:check-file($file-ext)) then doc($file-ext) else ''" />
		
		<xsl:choose>
			<xsl:when test="$doc-ext = ''">
				<xsl:message>
					<xsl:text>Unable to find </xsl:text>
					<xsl:value-of select="file/@src" />
					<xsl:text>.</xsl:text>
				</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="sub-elements" select="$doc-ext/descendant::subject[@name = $name]/*" as="element()*" />
				<xsl:if test="count($sub-elements) = 0">
					<xsl:message>
						<xsl:text>File </xsl:text>
						<xsl:value-of select="file/@src" />
						<xsl:text> does not contain information for </xsl:text>
						<xsl:value-of select="@name" />
						<xsl:text>.</xsl:text>
					</xsl:message>
				</xsl:if>
				<!-- insert data from external file -->
				<xsl:apply-templates select="$sub-elements" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- patterns need to be prioritized -->
	<xsl:template match="pattern">
		<xsl:copy>
			<xsl:copy-of select="@match" />
			<xsl:variable name="priority" select="if(@priority) then @priority else '1'" />
			<xsl:attribute name="priority" select="$priority" />
			<xsl:if test="parent::node()/@ordered = 'true'"><xsl:attribute name="sortkey" select="position()" /></xsl:if>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>