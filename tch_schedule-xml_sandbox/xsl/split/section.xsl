<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- output -->
	<xsl:output
		method="xml" 
		encoding="iso-8859-1" 
		indent="yes"
		exclude-result-prefixes="xs" 
		doctype-system="../dtds/special.dtd" />
	
	
	<!--=====================================================================
		Simple Transformation
		
		So, this transformation is a little odd. First, it includes a copy of
		  whatever is fed into it. Second, it includes a special listing of
		  the special-section classes. The output no longer conforms
		  to xml-formed.dtd, because it inserts <special-section name="whatever">
		  tags into the <term> elements.
		Basically, this transformation grabs all of the special classes
		  (@is-whatever = "true") and puts them into a specialized xml. This
		  is to facilitate the web output and its derivatives. It's wasteful
		  of space, but makes the web transform faster and simpler. I think it
		  justifies the extra space and steps.
		  ======================================================================-->
	<xsl:template match="/schedule">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="term" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="term">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<!-- copy input term -->
			<xsl:copy-of select="*" />
			
			<!-- tack on special sections -->
			
			<!-- distance learning -->
			<xsl:if test="descendant::visibility[@is-dl = 'true']">
				<xsl:element name="special-section">
					<xsl:attribute name="name" select="'Distance Learning'" />
					
					<xsl:apply-templates select="*[descendant::class[visibility/@is-dl = 'true']]">
						<xsl:with-param name="type" select="'dl'" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>
			
			<!-- weekend -->
			<xsl:if test="descendant::class[visibility/@is-w = 'true']">
				<xsl:element name="special-section">
					<xsl:attribute name="name" select="'Weekend'" />
					
					<xsl:apply-templates select="*[descendant::class[visibility/@is-w = 'true']]">
						<xsl:with-param name="type" select="'w'" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>
			
			<!-- weekend core curriculum -->
			<xsl:if test="descendant::class[visibility/@is-wcc = 'true']">
				<xsl:element name="special-section">
					<xsl:attribute name="name" select="'Weekend Core Curriculum'" />
					
					<xsl:apply-templates select="*[descendant::class[visibility/@is-wcc = 'true']]">
						<xsl:with-param name="type" select="'wcc'" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
			</xsl:if>
			
			<!-- flex term -->
			<xsl:if test="descendant::class[visibility/@is-flex = 'true']">
				<xsl:element name="special-section">
					<xsl:attribute name="name" select="'Flex Term'" />
					
					<xsl:variable name="term" select="." />
					<xsl:for-each-group select="descendant::class/visibility[@is-flex = 'true']/@flex-month" group-by=".">
						<xsl:sort select="." />
						
						<xsl:variable name="flex-month" select="current-grouping-key()" as="xs:string" />
						<xsl:element name="special-section">
							<xsl:attribute name="name" select="concat($flex-month, ' Flex Term')" />
							
							<xsl:apply-templates select="$term/*[descendant::class[visibility/@is-flex = 'true' and visibility/@flex-month = $flex-month]]">
								<xsl:with-param name="type"  select="'flex'"      tunnel="yes" />
								<xsl:with-param name="month" select="$flex-month" tunnel="yes" />
							</xsl:apply-templates>
							
						</xsl:element>
					</xsl:for-each-group>
				</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	
	<!-- generic ('cause I hate stringy code) -->
	<xsl:template match="division|subject|topic|subtopic|type|course">
		<xsl:param name="type"  as="xs:string" tunnel="yes" />
		<xsl:param name="month" as="xs:string" tunnel="yes" select="'na'" />
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:choose>
				<xsl:when test="compare($type, 'dl') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[visibility/@is-dl = 'true']] | contact | comments" />
				</xsl:when>
				<xsl:when test="compare($type, 'w') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[visibility/@is-w = 'true']] | contact | comments" />
				</xsl:when>
				<xsl:when test="compare($type, 'wcc') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[visibility/@is-wcc = 'true']] | contact | comments" />
				</xsl:when>
				<xsl:when test="compare($type, 'flex') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[visibility/@is-flex = 'true' and compare(visibility/@flex-month, $month) = 0]] | contact | comments" />
				</xsl:when>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="class|contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>

</xsl:stylesheet>