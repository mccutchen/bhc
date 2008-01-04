<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Includes & Output
		======================================================================-->
	<xsl:include
		href="split-utils.xsl" />
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils" doctype-system="../dtds/xml-formed.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		all elements are copied in sorted order.
		======================================================================-->
	<xsl:template match="schedule">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="term">
				<xsl:sort select="@sortkey" data-type="number" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="term | division">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:copy-of select="contact" />
			
			<xsl:apply-templates select="division | subject">
				<xsl:sort select="@name" data-type="text" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="subject | topic | subtopic">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:copy-of select="contact" />
			<xsl:copy-of select="comments" />
			
			<xsl:apply-templates select="type">
				<xsl:sort select="@sortkey" data-type="number" />
			</xsl:apply-templates>
			
			<xsl:apply-templates select="topic | subtopic">
				<xsl:sort select="@sortkey" data-type="number" />
				<xsl:sort select="@name"    data-type="text" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="type">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="course">
				<xsl:sort select="@sortkey" data-type="number" />
				<xsl:sort select="@rubric"  data-type="text"   />
				<xsl:sort select="@number"  data-type="number" />
				<xsl:sort select="min(descendant::class/@section)" data-type="number" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="course">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:copy-of select="comments" />
			
			<xsl:apply-templates select="class">
				<xsl:sort select="min(class/@sortkey)"                           data-type="number" />
				<xsl:sort select="utils:safe-min(meeting[@method = 'LEC']/@sortkey-days)"   data-type="number" />
				<xsl:sort select="min(meeting[@method = 'LEC']/@sortkey-times)"  data-type="number" />
				<xsl:sort select="min(meeting[@method = 'LEC']/@sortkey-method)" data-type="number" />
				<xsl:sort select="@sortkey-dates"                                data-type="number" />
				<xsl:sort select="@section"                                      data-type="number" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:copy-of select="visibility" />
			<xsl:copy-of select="comments"   />
			
			<xsl:apply-templates select="meeting">
				<xsl:sort select="@sortkey"        data-type="number" />
				<xsl:sort select="@sortkey-method" data-type="number" />
				<xsl:sort select="@sortkey-days"   data-type="number" />
				<xsl:sort select="@sortkey-times"  data-type="number" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:copy-of select="." />
	</xsl:template>
	
</xsl:stylesheet>