<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- output -->
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils fn" doctype-system="../dtds/xml-special.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		So, this transformation is a little odd. The output no longer conforms
		  to xml-formed.dtd, because it inserts <special-section name="whatever">
		  tags into the <term> elements.
		Basically, this transformation grabs all of the special classes
		  (@is-whatever = "true") and puts them into a special-only xml. This
		  is to facilitate the web output and its derivatives. It's wasteful
		  of space, but makes the web transform faster and simpler. I think it
		  justifies the extra space and step.
		  ======================================================================-->
	<xsl:template match="/schedule">
		<!-- distance learning -->
		<xsl:apply-templates select="." mode="dl" />
		
		<!-- weekend -->
		<xsl:apply-templates select="." mode="w" />
		
		<!-- weekend core curriculum -->
		<xsl:apply-templates select="." mode="wcc" />
		
		<!-- flex term -->
		<xsl:apply-templates select="." mode="flex" />
	</xsl:template>
	
	
	<!-- distance learning -->
	<xsl:template match="schedule" mode="dl">
		<xsl:result-document 
			method="xml" 
			encoding="iso-8859-1" 
			indent="yes"
			doctype-system="../dtds/xml-formated.dtd" 
			exclude-result-prefixes="xs utils fn" 
			href="{@year}-{@semester}_dl.xml">
			<xsl:copy>
				<xsl:copy-of select="attribute()" />
				<xsl:apply-templates select="*[descendant::class[@is-dl = 'true']]" mode="dl" />
			</xsl:copy>
		</xsl:result-document>
	</xsl:template>
	<xsl:template match="term" mode="dl">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:element name="special-section">
				<xsl:attribute name="name" select="'Distance Learning'" />
				
				<xsl:apply-templates select="*[descendant::class[@is-dl = 'true']]">
					<xsl:with-param name="type"  select="'dl'" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:copy>
	</xsl:template>
	
	<!-- weekend -->
	<xsl:template match="schedule" mode="w">
		<xsl:result-document 
			method="xml" 
			encoding="iso-8859-1" 
			indent="yes"
			doctype-system="../dtds/xml-formated.dtd" 
			exclude-result-prefixes="xs utils fn" 
			href="{@year}-{@semester}_w.xml">
			<xsl:copy>
				<xsl:copy-of select="attribute()" />
				<xsl:apply-templates select="*[descendant::class[@is-w = 'true']]" mode="w" />
			</xsl:copy>
		</xsl:result-document>
	</xsl:template>
	<xsl:template match="term" mode="w">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:element name="special-section">
				<xsl:attribute name="name" select="'Weekend'"/>
				
				<xsl:apply-templates select="*[descendant::class[@is-w = 'true']]">
					<xsl:with-param name="type"  select="'w'" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:copy>
	</xsl:template>
	
	<!-- weekend core curriculum -->
	<xsl:template match="schedule" mode="wcc">
		<xsl:result-document 
			method="xml" 
			encoding="iso-8859-1" 
			indent="yes"
			doctype-system="../dtds/xml-formated.dtd" 
			exclude-result-prefixes="xs utils fn" 
			href="{@year}-{@semester}_wcc.xml">
			<xsl:copy>
				<xsl:copy-of select="attribute()" />
				<xsl:apply-templates select="*[descendant::class[@is-wcc = 'true']]" mode="wcc" />
			</xsl:copy>
		</xsl:result-document>
	</xsl:template>
	<xsl:template match="term" mode="wcc">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:element name="special-section">
				<xsl:attribute name="name" select="'Weekend Core Curriculum'" />
				
				<xsl:apply-templates select="*[descendant::class[@is-wcc = 'true']]">
					<xsl:with-param name="type"  select="'wcc'" tunnel="yes" />
				</xsl:apply-templates>
			</xsl:element>
		</xsl:copy>
	</xsl:template>
	
	<!-- flex term -->
	<xsl:template match="schedule" mode="flex">
		<xsl:result-document 
			method="xml" 
			encoding="iso-8859-1" 
			indent="yes"
			doctype-system="../dtds/xml-formated.dtd" 
			exclude-result-prefixes="xs utils fn" 
			href="{@year}-{@semester}_flex.xml">
			<xsl:copy>
				<xsl:copy-of select="attribute()" />
				<xsl:apply-templates select="term[descendant::class[@is-flex = 'true']]" mode="flex" />
			</xsl:copy>
		</xsl:result-document>
	</xsl:template>
	<xsl:template match="term" mode="flex">
		<xsl:variable name="term" select="." as="element()" />
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			<xsl:element name="special-section">
				<xsl:attribute name="name" select="'Flex Term'" />
				
				<xsl:variable name="debug" select="$term/descendant::class[@is-flex = 'true']/@flex-month" />
				<xsl:value-of select="count($debug)" />
				<xsl:for-each-group select="descendant::class[@is-flex = 'true']/@flex-month" group-by=".">
					<xsl:sort select="." />
					
					<xsl:variable name="flex-month" select="current-grouping-key()" as="xs:string" />
					
					<xsl:element name="special-section">
						<xsl:attribute name="name" select="$flex-month" />
						
						<xsl:apply-templates select="$term/*[descendant::class[@is-flex = 'true' and @flex-month = $flex-month]]">
							<xsl:with-param name="type"  select="'flex'"      tunnel="yes" />
							<xsl:with-param name="month" select="$flex-month" tunnel="yes" />
						</xsl:apply-templates>
						
					</xsl:element>
					
				</xsl:for-each-group>
			</xsl:element>
		</xsl:copy>
	</xsl:template>
	
	<!-- generic -->
	<xsl:template match="division|subject|topic|subtopic|course">
		<xsl:param name="type"  as="xs:string" tunnel="yes" />
		<xsl:param name="month" as="xs:string" tunnel="yes" select="'na'" />
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:choose>
				<xsl:when test="compare($type, 'dl') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[@is-dl = 'true']] | contact | comments" />
				</xsl:when>
				<xsl:when test="compare($type, 'w') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[@is-w = 'true']] | contact | comments" />
				</xsl:when>
				<xsl:when test="compare($type, 'wcc') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[@is-wcc = 'true']] | contact | comments" />
				</xsl:when>
				<xsl:when test="compare($type, 'flex') = 0">
					<xsl:apply-templates select="*[descendant-or-self::class[@is-flex = 'true' and compare(@flex-month, $month) = 0]] | contact | comments" />
				</xsl:when>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="class|contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>

</xsl:stylesheet>