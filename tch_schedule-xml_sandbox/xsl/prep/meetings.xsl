<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://wwww.brookavencollege.edu/xml/fn">
	
	
	<!--=====================================================================
		Includes & Output
		======================================================================-->
	<xsl:include
		href="prep-utils.xsl" />
	<xsl:output 
		method="xml" 
		encoding="iso-8859-1" 
		indent="yes"
		exclude-result-prefixes="xs fn" 
		doctype-system="../dtds/meetings.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		Fixes two problems with colleague meetings:
		 1) for display purposes, some meetings are primary and others are not.
		    Colleage has no concept of display properties, so we have to add these
		    in ourselves.
		 2) There is a maze of additional rules that meetings need to be filtered
		    through for things like @days='MTWRFSU' isn't a valid set of days, but
		    it gets entered anyway. Also, there's a messed-up hack right now for
		    distance learning courses. Basically:
		      * If a class has a teaching method of INET:
		        a) If its topic code is one of OL, OLC or OLP:
		           replace the teaching method with the topic code
		        b) Else:
		           replace the teaching method with a default of OL
		    
		      * If a class has a teaching method of TV, TVP or IDL:
		        replace its teaching method with VB
		======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|type|course|faculty|visibility">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact|comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<!-- determine which meeting is the primary -->
	<xsl:template match="class">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:variable name="first-meeting" select="fn:find-first-meeting(meeting)" as="xs:integer" />
			<xsl:if test="$first-meeting &lt; 1">
				<xsl:variable name="cid" select="concat(parent::course/@rubric,' ',parent::course/@number,'-',@section)" as="xs:string" />
				<xsl:message>!Warning! No primary meeting found for class <xsl:value-of select="$cid" /></xsl:message>
			</xsl:if>
			
			<xsl:apply-templates select="comments|visibility" />
			<xsl:apply-templates select="meeting[position() = $first-meeting]">
				<xsl:with-param name="primary" select="'true'" />
			</xsl:apply-templates>
			<xsl:apply-templates select="meeting[position() != $first-meeting]">
				<xsl:with-param name="primary" select="'false'" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="meeting" priority="2">
		<xsl:param name="primary" as="xs:string" />
		
		<xsl:copy>
			<xsl:attribute name="primary" select="$primary" />
			<xsl:apply-templates select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<!-- HACK!
		Colleague is... yeah. 'Nuff said. Here's where we fix it so it doesn't pollute our system -->
	<xsl:template match="meeting[@method = 'INET']/@method" priority="1">
		<xsl:variable name="topic-code" select="ancestor::class/@topic-code" />
		<xsl:variable name="method"     select="if($topic-code = ('OL','OLC','OLP')) then $topic-code else 'OL'" as="xs:string" />
		
		<xsl:attribute name="method" select="$method" />
	</xsl:template>
	
	<!-- the rest of these are just cosmetic. I don't know why we do it. -->
	<!-- INET -->
	<xsl:template match="meeting[@method = 'INET']/@days" priority="1">
		<xsl:attribute name="days" select="'NA'" />
	</xsl:template>
	<xsl:template match="meeting[@method = 'INET' and @room != 'CET']/@room" priority="1">
		<xsl:attribute name="room" select="'OL'" />
	</xsl:template>
	
	<!-- VB -->
	<xsl:template match="meeting[@method = ('TV','TVP','IDL')]/@method" priority="1">
		<xsl:attribute name="method" select="'VB'" />
	</xsl:template>
	<xsl:template match="meeting[@method = ('TV','TVP','IDL')]/@days" priority="1">
		<xsl:attribute name="days" select="'NA'" />
	</xsl:template>
	<xsl:template match="meeting[@method = ('TV','TVP','IDL') and @room != 'CET']/@room" priority="1">
		<xsl:attribute name="room" select="'NA'" />
	</xsl:template>
	
	<!-- LAB, COOP w/@room = INET -->
	<xsl:template match="meeting[@method = 'LAB' and @room = 'INET']/@days" priority="1">
		<xsl:attribute name="days" select="'TBA'" />
	</xsl:template>
	<xsl:template match="meeting[@method = 'COOP' and @room = 'INET']/@days" priority="1">
		<xsl:attribute name="days" select="'NA'" />
	</xsl:template>
	<xsl:template match="meeting[@method = ('LAB','COOP') and @room = 'INET']/@room" priority="1">
		<xsl:attribute name="room" select="'OL'" />
	</xsl:template>
	
	<!-- if it's not a weird one, just plug it in -->
	<xsl:template match="meeting/attribute()" priority="0">
		<xsl:copy />
	</xsl:template>
	
	
	<!--=====================================================================
		Functions
		======================================================================-->
	<!-- ==========================================================================
		Find primary meeting
		=========================================================================== -->
	<xsl:function name="fn:find-first-meeting" as="xs:integer">
		<xsl:param name="meetings" as="element()*" />
		
		<xsl:choose>
			<xsl:when test="count($meetings) &lt; 1">
				<xsl:value-of select="-1" />
			</xsl:when>
			<xsl:when test="count($meetings) = 1">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:find-first-meeting($meetings, 1)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:find-first-meeting" as="xs:integer">
		<xsl:param name="meetings" as="element()*" />
		<xsl:param name="index"    as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="$index &lt; 1">
				<xsl:value-of select="-1" />
			</xsl:when>
			<xsl:when test="$index &gt; count($meetings)">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test="$meetings[$index]/@method = ('LEC','')">
				<xsl:value-of select="$index" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:find-first-meeting($meetings, $index + 1)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
</xsl:stylesheet>