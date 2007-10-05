<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">	
	<!-- utility functions -->
	<xsl:include
		href="xml-utils.xsl" />
	
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes"
		exclude-result-prefixes="utils" />
	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'debug-templates'" />
	<!--
		<xsl:variable name="release-type" select="'final'" />
		<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- 
		This transformation consumes the sorting info insterted by tidy_xml.xsl, and outputs data
		that is ready to be used to generate output.
	-->
	
	<!-- main match -->
	<xsl:template match="schedule">
		<xsl:element name="schedule">
			<xsl:copy-of select="attribute()" />
			<xsl:apply-templates select="term" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="division">
				<xsl:sort select="@name" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="division">
		<xsl:element name="division">
			<xsl:copy-of select="@name|contact" />
			
			<xsl:apply-templates select="subject">
				<xsl:sort select="@name" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="subject">
		<xsl:element name="subject">
			<xsl:copy-of select="attribute()|contact|comments" />
			
			<!-- if there are topics, copy them -->
			<xsl:apply-templates select="topic">
				<xsl:sort select="@sortkey" data-type="number" />
				<xsl:sort select="@name" />
			</xsl:apply-templates>
			
			<!-- if there are types, copy them -->
			<xsl:apply-templates select="type">
				<xsl:sort select="@sortkey" data-type="number" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="topic">
		<xsl:element name="topic">
			<xsl:copy-of select="attribute()|comments" />
			
			<!-- if there are subtopics, copy them -->
			<xsl:apply-templates select="subtopic">
				<xsl:sort select="@sortkey" data-type="number" />
				<xsl:sort select="@name" />
			</xsl:apply-templates>
			
			<!-- if there are types, copy them -->
			<xsl:apply-templates select="type">
				<xsl:sort select="@sortkey" data-type="number" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="subtopic">
		<xsl:element name="subtopic">
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="type">
				<xsl:sort select="@sortkey" data-type="number" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>

	<xsl:template match="type">
		<xsl:element name="type">
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="course">
				<xsl:sort select="@sortkey-special" data-type="number" />
				<xsl:sort select="@rubric" data-type="text" />
				<xsl:sort select="@number" data-type="number" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="course">
		<xsl:element name="course">
			<xsl:copy-of select="attribute()|comments" />
			
			<xsl:apply-templates select="class">
				<xsl:sort select="@sortkey-special" data-type="number" />
				<xsl:sort select="@sortkey-days" data-type="number" />
				<xsl:sort select="@sortkey-times" data-type="number" />
				<xsl:sort select="@sortkey-date" data-type="number" />
				<xsl:sort select="@section" data-type="number" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:element name="class">
			<xsl:copy-of select="attribute()|comments" />
			
			<xsl:apply-templates select="meeting">
				<xsl:sort select="@sortkey-method" data-type="number" />
				<xsl:sort select="@sortkey-days"   data-type="number" />
				<xsl:sort select="@sortkey-times"  data-type="number" />
			</xsl:apply-templates>
			
			<xsl:copy-of select="faculty|xlisting|corequisite-section" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:copy-of select="." />
	</xsl:template>

</xsl:stylesheet>
