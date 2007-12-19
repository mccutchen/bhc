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
		exclude-result-prefixes="xs utils fn" doctype-system="../dtds/xml-formed.dtd"/>
	
	
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
				<xsl:sort select="fn:safe-min(meeting[@method = 'LEC']/@sortkey-days)"   data-type="number" />
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
			
			<xsl:copy-of select="comments" />
			
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
	
	
	
	
	<xsl:function name="fn:to-int" as="xs:integer">
		<xsl:param name="x" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="number($x)">
				<xsl:value-of select="xs:integer($x)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
	<xsl:function name="fn:safe-min" as="xs:integer">
		<xsl:param name="x" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="count($x) &lt; 1">
				<xsl:value-of select="0" />
			</xsl:when>
			<xsl:when test="count($x) = 1">
				<xsl:value-of select="fn:to-int($x[1])" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:safe-min($x[position() &gt; 1], fn:to-int($x[1]))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:safe-min" as="xs:integer">
		<xsl:param name="x" as="xs:string*" />
		<xsl:param name="max" as="xs:integer" />
		
		<xsl:variable name="y" select="fn:to-int($x[1])" as="xs:integer" />
		<xsl:choose>
			<xsl:when test="count($x) = 0">
				<xsl:value-of select="$max" />
			</xsl:when>
			<xsl:when test="$max &lt; $y">
				<xsl:value-of select="fn:safe-min($x[position() &gt; 1], $y)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:safe-min($x[position() &gt; 1], $max)" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
</xsl:stylesheet>