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
	
	<!-- match and fix schedule elements -->
	<xsl:template match="schedule">
			<xsl:element name="schedule">
				<xsl:attribute name="date-created"><xsl:value-of select="utils:convert-date-std(@date-created)" /></xsl:attribute>
				<xsl:attribute name="time-created"><xsl:value-of select="utils:convert-time-std(@time-created)" /></xsl:attribute>
				
				<xsl:apply-templates select="*" />
			</xsl:element>
		</xsl:result-document>
	</xsl:template>
	
	<!-- match and fix term elements -->
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:attribute name="year"><xsl:value-of select="@year" /></xsl:attribute>
			<xsl:attribute name="semester"><xsl:value-of select="utils:strip-semester(@name)" /></xsl:attribute>
			<xsl:attribute name="date-start"><xsl:value-of select="utils:convert-date-std(@start-date)" /></xsl:attribute>
			<xsl:attribute name="date-end"><xsl:value-of select="utils:convert-date-std(@end-date)" /></xsl:attribute>
			
			<xsl:apply-templates select="$doc-divisions/division">
				<xsl:with-param name="courses" select="location[@name='200']/descendant::course" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<!-- fill divisions from groupings and divisions.xml -->
	<xsl:template match="division">
		<xsl:param name="courses" />
		
		<!-- get some vars to work with -->
		<xsl:variable name="pattern"     select="pattern/@match"                         />
		<xsl:variable name="title"       select="@name"                                  />
		<xsl:variable name="contact"     select="$doc-contacts/division[@name = $title]" />
		<xsl:variable name="div-courses" select="$courses[match(rubric, $pattern)]"      />
		
		<!-- build element -->
		<xsl:element name="division">
			<xsl:attribute name="title" select="$title"          />
			<xsl:attribute name="ext"   select="$contact/@ext"   />
			<xsl:attribute name="room"  select="$contact/@room"  />
			<xsl:attribute name="email" select="$contact/@email" />
			
			<!-- now for the courses -->
			<xsl:apply-templates select="$div-courses">
				<xsl:with-param name="division" select="$title" />
			</xsl:apply-templates>
			
		</xsl:element>
	</xsl:template>
	
	<!-- build subjects and courses from div-courses and subjects.xml (and possibly [semester].xml etc) -->
	<xsl:template match="course">
		<xsl:param name="division" />
		
		<!-- get some variables to work with -->
		<xsl:variable name="
	
	</xsl:template>
	
	<!-- copy courses -->
	<xsl:template match="course">
		<xsl:element name="course">
			<xsl:attribute name="title-short"  select="@title"        />
			<xsl:attribute name="title-long"   select="@long-title"   />
			<xsl:attribute name="rubric"       select="@rubric"       />
			<xsl:attribute name="number"       select="@number"       />
			<xsl:attribute name="credit-hours" select="@credit-hours" />
			
			<xsl:apply-templates select="*" />
		</xsl:element>
	</xsl:template>
	
	<!-- match and fix class elements -->
	<xsl:template match="class">
		<xsl:element name="class">
			<xsl:attribute name="title"         select="@title"         />
			<xsl:attribute name="synonym"       select="@synonym"       />
			<xsl:attribute name="section"       select="@section"       />
			<xsl:attribute name="date-start"    select="utils:convert-date-std(@start-date)"    />
			<xsl:attribute name="date-end"      select="utils:convert-date-std(@end-date)"      />
			<xsl:attribute name="weeks"         select="@weeks"         />
			<xsl:attribute name="capacity"      select="@capacity"      />
			<xsl:attribute name="status"        select="@status"        />
			<xsl:attribute name="credit-type"   select="@credit-type"   />
			<xsl:attribute name="schedule-type" select="@schedule-type" />
			
			<xsl:apply-templates select="*" />
		</xsl:element>
	</xsl:template>
	
	<!-- match and fix meeting elements -->
	<xsl:template match="meeting">
		<xsl:element name="meeting">
			<xsl:attribute name="days" select="@days" />
			<xsl:attribute name="method" select="@method" />
			<xsl:attribute name="building" select="@building" />
			<xsl:attribute name="room" select="@room" />
			<xsl:attribute name="time-start" select="utils:convert-time-std(@start-time)" />
			<xsl:attribute name="time-end" select="utils:convert-time-std(@end-time)" />
			
			<xsl:apply-templates select="*" />
		</xsl:element>
	</xsl:template>
	
	<!-- match and fix description elements -->
	<xsl:template match="description">
			
		<xsl:copy-of select="." />
	</xsl:template>
	<xsl:template match="alt-description">
			
		<xsl:copy-of select="." />
	</xsl:template>
	<!-- match and fix meeting elements -->
	<xsl:template match="xlisting">
			
		<xsl:copy-of select="." />
	</xsl:template>
	
</xsl:stylesheet>
