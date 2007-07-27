<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils">
	
	<!-- utility functions -->
	<xsl:include
		href="utils.xsl" />
	
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes" />
	
	<!-- some global vars -->
	<xsl:variable name="doc-special"   select="document('special-sorting.xml')/mappings" />
	<xsl:variable name="doc-divisions" select="document('divisions.xml')/divisions"      />
	<xsl:variable name="doc-types"     select="document('types.xml')/types"              />
	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'debug-templates'" />
	<!--
		<xsl:variable name="release-type" select="'final'" />
		<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- This is the step where I try to fix the puddle of data-goo left behind by the DSC XML and elephant
		 pairing in xml_flatten. I'm going to keep the division and term elements (altho, it seems like terms
	     could be used to hold minimesters? not sure), and add in division, subject, topic, subtopic, and type
	     elements. I can strip most of the data out of the class element once this is complete. -->
	
	<!-- main match -->
	<xsl:template match="/">
		
		<!-- we're just going to copy the schedule and term tags, so do that -->
		<xsl:if test="$release-type = 'final' or $release-type = 'debug-templates'">
			<xsl:apply-templates select="*" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="schedule">
		<xsl:element name="schedule">
			<xsl:copy-of select="attribute()" />
			<xsl:apply-templates select="*" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:copy-of select="attribute()" />
			<xsl:call-template name="create-divisions">
				<xsl:with-param name="classes" select="*" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<!-- this is where divisions are inserted (as you may have guessed) -->
	<xsl:template name="create-divisions">
		<xsl:param name="classes" />
		
		<xsl:for-each-group select="$classes" group-by="@name-of-division">
			<xsl:element name="division">
				<xsl:variable name="name" select="@name-of-division" />
				<xsl:variable name="division" select="$doc-divisions/division[@name = $name]" />
				
				<!-- write division info -->
				<xsl:attribute name="name" select="$name" />
				<xsl:copy-of select="$division/contact" />
				
				<!-- proceed to subjects -->
				<xsl:call-template name="create-subjects">
					<xsl:with-param name="classes" select="$classes[@name-of-division = $name]" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- now create subject groupings -->
	<xsl:template name="create-subjects">
		<xsl:param name="classes" />
		
		<xsl:for-each-group select="$classes" group-by="@name-of-subject">
			<xsl:element name="subject">
				<xsl:variable name="name" select="@name-of-subject" />
				<xsl:variable name="subject" select="$doc-divisions/descendant::subject[@name = $name]" />
				
				<!-- write subject info -->
				<xsl:attribute name="name" select="$name" />
				<xsl:copy-of select="$subject/contact" />
				<xsl:copy-of select="$subject/comments" />
				
				<!-- proceed to types -->
				<xsl:call-template name="create-types">
					<xsl:with-param name="classes" select="$classes[@name-of-subject = $name]" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template name="create-types">
		<xsl:param name="classes" />
		
		<xsl:for-each-group select="$classes" group-by="@type-schedule">
			<xsl:element name="type">
				<xsl:variable name="id" select="@type-schedule"></xsl:variable>
				<xsl:variable name="name" select="$doc-types/type[@id = $id]/@name" />
				
				<!-- write type info -->
				<xsl:attribute name="name" select="$name" />
				
				<!-- proceed to courses -->
				<xsl:call-template name="create-courses">
					<xsl:with-param name="classes" select="$classes[@type-sched = $id]" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template name="create-courses">
		<xsl:param name="classes" />
		
		<xsl:for-each-group select="$classes" group-by="@rubric and @number">
			
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="class">
		
	</xsl:template>
	
</xsl:stylesheet>
