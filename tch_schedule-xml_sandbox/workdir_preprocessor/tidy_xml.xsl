<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils">
	
	<!-- utility functions -->
	<xsl:include
		href="libs/utils.xsl" />
	
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes"
		exclude-result-prefixes="utils" />
	
	<!-- some global vars -->
	<xsl:variable name="doc-special"   select="document('mappings/special-sorting.xml')/mappings" />
	<xsl:variable name="doc-divisions" select="document('mappings/divisions.xml')/divisions"      />
	<xsl:variable name="doc-types"     select="document('mappings/types.xml')/types"              />
	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'debug-templates'" />
	<!--
		<xsl:variable name="release-type" select="'final'" />
		<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- 
		This transformation gives order to the puddle of data-goo output by flatten_xml.xsl.
		I'm going to keep the division and term elements (altho, it seems like terms could be used to 
		hold minimesters? not sure), and add in division, subject, topic, subtopic, and type elements.
		I can strip most of the data out of the class element once this is complete.
		In addition, data will be pulled in from other sources (see variables above named 'doc-*') 
		such as: contact information for divisions/subjects, core-curriculum courses, etc.
	-->
	
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
				<xsl:with-param name="classes" select="*" as="element()*" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<!-- this is where divisions are inserted (as you may have guessed) -->
	<xsl:template name="create-divisions">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each-group select="$classes" group-by="@name-of-division">
			<xsl:element name="division">
				<xsl:variable name="name"     select="@name-of-division"                      as="xs:string" />
				<xsl:variable name="division" select="$doc-divisions/division[@name = $name]" as="element()" />
				
				<!-- write division info -->
				<xsl:attribute name="name" select="$name" />
				<xsl:copy-of select="$division/contact" />
				
				<!-- proceed to subjects -->
				<xsl:call-template name="create-subjects">
					<xsl:with-param name="classes" select="$classes[@name-of-division = $name]" as="element()*" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- now create subject groupings -->
	<xsl:template name="create-subjects">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each-group select="$classes" group-by="@name-of-subject">
			<xsl:element name="subject">
				<xsl:variable name="name"    select="@name-of-subject"                                  as="xs:string" />
				<xsl:variable name="subject" select="$doc-divisions/descendant::subject[@name = $name]" as="element()" />
				
				<!-- write subject info -->
				<xsl:attribute name="name" select="$name" />
				<xsl:copy-of select="$subject/contact"  />
				<xsl:copy-of select="$subject/comments" />
				
				<!-- proceed to types -->
				<xsl:call-template name="create-types">
					<xsl:with-param name="classes" select="$classes[@name-of-subject = $name]" as="element()*" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- create type groupings -->
	<xsl:template name="create-types">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each-group select="$classes" group-by="@type-schedule">
			<xsl:element name="type">
				<xsl:variable name="id" select="@type-schedule" as="xs:string" />
				
				<!-- write type info -->
				<xsl:attribute name="name" select="$doc-types/type[@id = $id]/@name" />
				
				<!-- proceed to courses -->
				<xsl:call-template name="create-courses">
					<xsl:with-param name="classes" select="$classes[@type-schedule = $id]" as="element()*" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- re-create courses -->
	<xsl:template name="create-courses">
		<xsl:param name="classes" as="element()*" />
		
		<!-- since the xml is pre-sorted by flatten_xml.xsl, we can just group-adjacent -->
		<xsl:for-each-group select="$classes" group-adjacent="@rubric and @number">
			<xsl:element name="course">
				<!-- write class info -->
				<xsl:attribute name="rubric" select="@rubric"             />
				<xsl:attribute name="number" select="@number"             />
				<xsl:attribute name="title-short" select="@title-short"   />
				<xsl:attribute name="title-long" select="@title-long"     />
				<xsl:attribute name="credit-hours" select="@credit-hours" />
				
				<!-- copy description -->
				<xsl:apply-templates select="desc-course" />
				
				<!-- proceed to classes -->
				<xsl:apply-templates select="current-group()" />
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="desc-course">
		<xsl:element name="desc">
			<xsl:copy-of select="*" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:element name="class">
			<xsl:attribute name="section"       select="@section"       />
			<xsl:attribute name="synonym"       select="@synonym"       />
			<xsl:attribute name="type-credit"   select="@type-credit"   />  <!-- I don't know if this is useful for anything, so I'll keep it -->
			<xsl:attribute name="type-schedule" select="@type-schedule" />
			<xsl:attribute name="topic-code"    select="@topic-code"    />
			<xsl:attribute name="weeks"         select="@weeks"         />
			<xsl:attribute name="date-start"    select="@date-start"    />
			<xsl:attribute name="date-end"      select="@date-end"      />
			
			<!-- copy sub-elements -->
			<xsl:copy-of select="desc|meeting|xlisting|corequisite-section"/>
			
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
