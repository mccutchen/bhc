<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Output
		======================================================================-->
	<xsl:output 
		method="xml" 
		encoding="iso-8859-1" 
		indent="yes"
		exclude-result-prefixes="xs fn" 
		doctype-system="../dtds/meetings.dtd"/>
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="email-flag" select="'@dcccd.edu'" as="xs:string" />
	<xsl:variable name="http-flag"  select="'http://'"    as="xs:string" />
	<xsl:variable name="https-flag" select="'https://'"   as="xs:string" />
	
	<!--=====================================================================
		Simple Transformation
		
		lists only classes that fit within the enrolling window (ie, after the
		supplied date)
		======================================================================-->
	<xsl:template match="schedule|term|division|subject|topic|subtopic|type|course|class">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact | meeting|visibility | cross-listing | corequisite">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="comments | comments//h1 | comments//p | comments//b | comments//i | comments//table | comments//tr | comments//td | comments//@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="comments/text()">
			<xsl:call-template name="link-text">
				<xsl:with-param name="text" select="." />
				<xsl:with-param name="link" select="fn:find-next-link(.)" />
			</xsl:call-template>
	</xsl:template>	
	
	<xsl:template name="link-text">
		<xsl:param name="text" as="xs:string"   />
		<xsl:param name="link" as="xs:integer*" />
		
		<xsl:choose>
			<!-- if there are no more links, just spit it out -->
			<xsl:when test="$link[1] &lt; 0">
				<xsl:value-of select="$text" />
			</xsl:when>
			
			<!-- otherwise, there is at least one link -->
			<xsl:otherwise>
				<!-- spit out the non-link text -->
				<xsl:value-of select="substring($text, 1, $link[1] - 1)" />
				
				<!-- make the link -->
				<xsl:call-template name="make-link">
					<xsl:with-param name="text" select="substring($text, $link[1], $link[2])" />
				</xsl:call-template>
				
				<!-- process remainder of the text -->
				<xsl:variable name="new-text" select="substring($text, $link[1]+$link[2])" as="xs:string" />
				<xsl:call-template name="link-text">
					<xsl:with-param name="text" select="$new-text" />
					<xsl:with-param name="link" select="fn:find-next-link($new-text)" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="make-link">
		<xsl:param name="text" as="xs:string" />
		
		<xsl:choose>
			<!-- if the text string is empty, just stop -->
			<xsl:when test="string-length($text) &lt; 1" />
			
			<!-- if it's an email -->
			<xsl:when test="fn:is-email($text)">
				<xsl:element name="email">
					<xsl:value-of select="$text" />
				</xsl:element>
			</xsl:when>
			
			<!-- if it's a url -->
			<xsl:when test="fn:is-url($text)">
				<xsl:element name="url">
					<xsl:value-of select="$text" />
				</xsl:element>
			</xsl:when>
			
			<!-- otherwise, something went wrong -->
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>Unknown link type for: </xsl:text>
					<xsl:value-of select="$text" />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	
	<!--=====================================================================
		Functions
		I hate xsl.
		======================================================================-->
	<xsl:function name="fn:find-next-link" as="xs:integer*">
		<xsl:param name="text" as="xs:string" />
		
		<xsl:variable name="email" select="fn:isolate-post-flag($text, $email-flag)" as="xs:integer*" />
		<xsl:variable name="http"  select="fn:isolate-pre-flag($text, $http-flag)"   as="xs:integer*" />
		<xsl:variable name="https" select="fn:isolate-pre-flag($text, $https-flag)"  as="xs:integer*" />
		
		<xsl:variable name="min-index" select="fn:min-index(($email[1], $http[1], $https[1]))" as="xs:integer" />
		
		<xsl:choose>
			<!-- when no links remaining -->
			<xsl:when test="$min-index = -1">
				<xsl:value-of select="-1" />
				<xsl:value-of select="0"  />
			</xsl:when>
			
			<!-- when email link is first -->
			<xsl:when test="$email[1] = $min-index">
				<xsl:value-of select="$email[1]" />
				<xsl:value-of select="$email[2]" />
			</xsl:when>
			
			<!-- when url is first -->
			<xsl:when test="$http[1] = $min-index">
				<xsl:value-of select="$http[1]" />
				<xsl:value-of select="$http[2]" />
			</xsl:when>
			
			<!-- when secure url is first -->
			<xsl:when test="$https[1] = $min-index">
				<xsl:value-of select="$https[1]" />
				<xsl:value-of select="$https[2]" />
			</xsl:when>
			
			<!-- otherwise, something's wrong -->
			<xsl:otherwise>
				<xsl:message>!Error!: Could not find minimum index for next link.</xsl:message>
				<xsl:message>email: <xsl:value-of select="$email[1]" /></xsl:message>
				<xsl:message>http:  <xsl:value-of select="$http[1]" /></xsl:message>
				<xsl:message>https: <xsl:value-of select="$https[1]" /></xsl:message>
				<xsl:message>min:   <xsl:value-of select="$min-index" /></xsl:message>
				<xsl:value-of select="-1" />
				<xsl:value-of select="0"  />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:min-index" as="xs:integer">
		<xsl:param name="indices" as="xs:integer*" />
		
		<xsl:choose>
			<xsl:when test="count($indices) = 0">
				<xsl:value-of select="-1" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:min-index($indices, 2, 1)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:min-index" as="xs:integer">
		<xsl:param name="indices" as="xs:integer*" />
		<xsl:param name="cur" as="xs:integer" />
		<xsl:param name="min" as="xs:integer"  />
		
		<xsl:choose>
			<xsl:when test="$cur &gt; count($indices)">
				<xsl:value-of select="$indices[$min]" />
			</xsl:when>
			<xsl:when test="$indices[$cur] &lt; $indices[$min]">
				<xsl:value-of select="fn:min-index($indices, $cur+1, $cur)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:min-index($indices, $cur+1, $min)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:isolate-post-flag" as="xs:integer*">
		<xsl:param name="text" as="xs:string" />
		<xsl:param name="flag" as="xs:string" />
		
		<xsl:if test="contains($text, $flag)">
		<xsl:variable name="pre-flag" select="substring-before($text, $flag)" />
		<xsl:variable name="tokens" select="tokenize($pre-flag, '\s')" />
		<xsl:variable name="last-token" select="reverse($tokens)[1]" />
		<xsl:variable name="pre-link" select="substring-before($text, concat($last-token, $flag))" />
		
		<xsl:variable name="index" select="string-length($pre-link)" as="xs:integer" />
		<xsl:variable name="length" select="string-length(concat($last-token, $flag))" as="xs:integer" />
		
		<xsl:value-of select="$index + 1" />
		<xsl:value-of select="$length" />
		</xsl:if>
	</xsl:function>
	<xsl:function name="fn:isolate-pre-flag" as="xs:integer*">
		<xsl:param name="text" as="xs:string" />
		<xsl:param name="flag" as="xs:string" />
		
		<xsl:if test="contains($text, $flag)">
			<xsl:variable name="post-flag" select="substring-after($text, $flag)" />
		<xsl:variable name="tokens" select="tokenize($post-flag, '\s')" />
		<xsl:variable name="first-token" select="$tokens[1]" />
		<xsl:variable name="pre-flag" select="substring-before($text, $flag)" />
		
		<xsl:variable name="index" select="string-length($pre-flag)" as="xs:integer" />
		<xsl:variable name="length" select="string-length(concat($flag, $first-token))" as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="ends-with($first-token, '.')">
				<xsl:value-of select="$index + 1" />
				<xsl:value-of select="$length - 1" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$index + 1" />
				<xsl:value-of select="$length" />
			</xsl:otherwise>
		</xsl:choose>
			</xsl:if>
	</xsl:function>
	
	<xsl:function name="fn:is-email" as="xs:boolean">
		<xsl:param name="text" as="xs:string" />
		
		<xsl:value-of select="contains($text, $email-flag)" />
	</xsl:function>
	
	<xsl:function name="fn:is-url">
		<xsl:param name="text" as="xs:string" />
		
		<xsl:value-of select="contains($text, $http-flag) or contains($text, $https-flag)" />
	</xsl:function>
	
</xsl:stylesheet>