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

		exclude-result-prefixes="xs utils fn" />
		<!-- can't add: doctype-system="../dtds/xml-combined.dtd" 'cause it's not ready yet, if I even decide to make it -->
	
	<!-- command line parameters -->
	<xsl:param name="s2" as="xs:string" />
	<xsl:variable name="doc-s2" select="document(replace($s2, '\\', '/'))/schedule" as="element()*" />
	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'final'" />
	<!--
		<xsl:variable name="release-type" select="'debug-templates'" as="xs:string" />
		<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- 
		This is an extremely simple transformation. It just combines two DSC xml documents into one xml document.
		This step is essential for summer schedules, because there are multiple terms in summer.
	-->
	
	
	<!-- start  -->
	<xsl:template match="/schedule">
		<!-- we would hope that these are produced on the same day, but they may not be -->
		<xsl:choose>
			<!-- if they are, we're golden. Just proceed. -->
			<xsl:when test="compare(@date-created, $doc-s2/@date-created) = 0">
				<xsl:apply-templates select="." mode="create">
					<xsl:with-param name="date-created" select="@date-created" />
					<xsl:with-param name="time-created" select="fn:oldest-time(@time-created, $doc-s2/@time-created)" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="oldest-date" select="fn:oldest-date(@date-created, $doc-s2/@date-created)" as="xs:string" />
				<xsl:variable name="oldest-time" select="if (compare($oldest-date, @date-created) = 0) then @time-created else $doc-s2/@time-created" />

				<!-- display warning to user, but continue transformation -->
				<xsl:message>
					<xsl:text>!Warning! documents not produced on the same day: S1 (</xsl:text>
					<xsl:value-of select="@date-created" /><xsl:text> @ </xsl:text><xsl:value-of select="@time-created" />
					<xsl:text>) and S2 (</xsl:text>
					<xsl:value-of select="$doc-s2/@date-created" /><xsl:text> @ </xsl:text><xsl:value-of select="$doc-s2/@time-created" />
					<xsl:text>)</xsl:text>
				</xsl:message>
				
				<xsl:apply-templates select="." mode="create">
					<xsl:with-param name="date-created" select="$oldest-date" />
					<xsl:with-param name="time-created" select="$oldest-time" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- create the new schedule -->
	<xsl:template match="schedule" mode="create">
		<xsl:param name="date-created" as="xs:string" />
		<xsl:param name="time-created" as="xs:string" />
		
		<xsl:element name="schedule">
			<xsl:attribute name="date-created" select="$date-created" />
			<xsl:attribute name="time-created" select="$time-created" />
			
			<xsl:copy-of select="term" />
			<xsl:copy-of select="$doc-s2/term" />
		</xsl:element>
	</xsl:template>
	
	
	
	<xsl:function name="fn:oldest-date" as="xs:string">
		<xsl:param name="date1" as="xs:string" />
		<xsl:param name="date2" as="xs:string" />
		
		<!-- standardize the dates and break into convenient pieces -->
		<xsl:variable name="d1" select="tokenize(utils:convert-date-std($date1), '/')" as="xs:string*" />
		<xsl:variable name="d2" select="tokenize(utils:convert-date-std($date2), '/')" as="xs:string*" />
		
		<!-- this takes advantage of the fact that the dates will be standardized (same number of digits in
			 comperable comparisons) to simplify the logic -->
		<xsl:choose>
			<xsl:when test="compare($d1[3], $d2[3]) != 0"> <!-- year -->
				<xsl:value-of select="if (compare($d1[3], $d2[3]) > 0) then $date1 else $date2" />
			</xsl:when>
			<xsl:when test="compare($d1[1], $d2[1]) != 0"> <!-- month -->
				<xsl:value-of select="if (compare($d1[1], $d2[1]) > 0) then $date1 else $date2" />
			</xsl:when>
			<xsl:when test="compare($d1[2], $d2[2]) != 0"> <!-- day -->
				<xsl:value-of select="if (compare($d1[2], $d2[2]) > 0) then $date1 else $date2" />
			</xsl:when>
			<!-- if we've gotten this far, just pick one -->
			<xsl:otherwise>
				<xsl:value-of select="$date1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:oldest-time" as="xs:string">
		<xsl:param name="time1" as="xs:string" />
		<xsl:param name="time2" as="xs:string" />
		
		<!-- standardize the format -->
		<xsl:variable name="t1" select="utils:convert-time-24h($time1)" as="xs:string" />
		<xsl:variable name="t2" select="utils:convert-time-24h($time2)" as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="compare($t1, $t2) &lt; 0">
				<xsl:value-of select="$time2" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$time1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>