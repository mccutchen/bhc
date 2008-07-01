<xsl:stylesheet 
	version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.brookhavencollege.edu/xml/utils">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- output -->
	<xsl:output 
		method="xml" 
		encoding="iso-8859-1" 
		indent="yes"
		exclude-result-prefixes="xs fn" 
		doctype-system="../dtds/grouped.dtd"/>
	
	
	<!--=====================================================================
		Simple Transformation
		
		Adjacent classes with mutual cross-listings are noted
		======================================================================-->
	<xsl:template match="schedule | term | division | subject | topic | subtopic | type">
		<xsl:copy>
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="contact | comments">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="course">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			
			<!-- group the classes -->
			<xsl:call-template name="group">
				<xsl:with-param name="classes" select="class" />
				<xsl:with-param name="min-index" select="1" />
			</xsl:call-template>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template name="group">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="min-index" as="xs:integer" />
		
		<!-- find how many classes to group -->
		<xsl:variable name="max-cross-match" select="fn:find-max-cross-match($classes, $min-index)" as="xs:integer" />
		<xsl:choose>
			<!-- for debugging purposes only -->
			<xsl:when test="$max-cross-match &lt; $min-index">
				<xsl:message>_ERROR_001_</xsl:message>
			</xsl:when>
			<!-- if there is no group, pass the class on to comment grouping -->
			<xsl:when test="$max-cross-match = $min-index">
				<xsl:call-template name="group-comments">
					<xsl:with-param name="classes" select="$classes[$min-index]" />
					<xsl:with-param name="min-index" select="1" />
				</xsl:call-template>
			</xsl:when>
			<!-- if there is a group, put it into a <cross-group> and pass the classes on to comment grouping -->
			<xsl:otherwise>
				<xsl:element name="cross-group">
					<xsl:call-template name="group-comments">
						<xsl:with-param name="classes" select="$classes[position() &gt;= $min-index and position() &lt;= $max-cross-match]" />
						<xsl:with-param name="min-index" select="1" />
					</xsl:call-template>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- continue with the next class in the list -->
		<xsl:if test="$max-cross-match &lt; count($classes)">
			<xsl:call-template name="group">
				<xsl:with-param name="classes" select="$classes" />
				<xsl:with-param name="min-index" select="$max-cross-match + 1" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="group-comments">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="min-index" as="xs:integer" />
		
		<!-- find how many classes share comments -->
		<xsl:variable name="max-comment-match" select="fn:find-max-comment-match($classes, $min-index)" as="xs:integer" />
		<xsl:choose>
			<!-- for debugging purposes only -->
			<xsl:when test="$max-comment-match &lt; $min-index">
				<xsl:message>_ERROR_001_</xsl:message>
			</xsl:when>
			<!-- if there is no group, copy the class -->
			<xsl:when test="$max-comment-match = $min-index">
				<xsl:copy-of select="$classes[$min-index]" />
			</xsl:when>
			<!-- if there is a group, put it into a <comment-group> and copy the classes -->
			<xsl:otherwise>
				<xsl:element name="comment-group">
					<xsl:copy-of select="$classes[$min-index]/comments" />
					
					<xsl:copy-of select="$classes[position() &gt;= $min-index and position() &lt;= $max-comment-match]" />
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		
		<!-- continue with the next class in the list -->
		<xsl:if test="$max-comment-match &lt; count($classes)">
			<xsl:call-template name="group-comments">
				<xsl:with-param name="classes" select="$classes" />
				<xsl:with-param name="min-index" select="$max-comment-match + 1" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	

	

	<!--=====================================================================
		Extending XSL Functions
		=====================================================================-->
	<!-- converts concat to work on lists -->
	<xsl:function name="fn:concat" as="xs:string">
		<xsl:param name="list" as="xs:string*" />
		<xsl:value-of select="fn:concat('',$list)" />
	</xsl:function>
	<xsl:function name="fn:concat" as="xs:string">
		<xsl:param name="string" as="xs:string" />
		<xsl:param name="list" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="count($list) = 0">
				<xsl:value-of select="$string" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:concat(concat($string, $list[1]), $list[position() != 1])" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- converts normalize-space() to work on sequences of strings -->
	<xsl:function name="fn:normalize-space" as="xs:string">
		<xsl:param name="text" as="xs:string*" />
		
		<xsl:value-of select="fn:normalize-space(fn:concat($text))" />
	</xsl:function>
	
	<!--=====================================================================
		Cross-Listing Groupers
		=====================================================================-->
	<xsl:function name="fn:find-max-cross-match" as="xs:integer">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="index"   as="xs:integer" />
		
		<xsl:choose>
			<!-- if there are no crosslistings for this course, it can't be grouped -->
			<xsl:when test="not($classes[$index]/cross-listing)">
				<xsl:value-of select="$index" />
			</xsl:when>
			<!-- otherwise, store the cross list and loop -->
			<xsl:otherwise>
				<xsl:variable name="cross" select="fn:concat($classes[$index]/cross-listing/@synonym)" as="xs:string" />
				<xsl:variable name="synonym" select="$classes[$index]/@synonym" as="xs:string" />
				<xsl:value-of select="fn:cross-match-loop($cross, $synonym, $classes, $index + 1)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:cross-match-loop" as="xs:integer">
		<xsl:param name="cross"   as="xs:string"  />
		<xsl:param name="synonym" as="xs:string"  />
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="index"   as="xs:integer" />
		
		<xsl:choose>
			<!-- if we're off the end of the class list, return the last item in the class list -->
			<xsl:when test="$index &gt; count($classes)">
				<xsl:value-of select="count($classes)" />
			</xsl:when>
			<!-- if the synonym matches the cross list, proceed to next -->
			<xsl:when test="contains($cross, $classes[$index]/@synonym)">
				<xsl:value-of select="fn:cross-match-loop($cross, $synonym, $classes, $index + 1)" />
			</xsl:when>
			<!-- if this class has cross listing(s) -->
			<xsl:when test="count($classes[$index]/cross-listing) &gt; 0">
				<xsl:variable name="back-cross" select="fn:concat($classes[$index]/cross-listing/@synonym)" as="xs:string" />
				<xsl:choose>
					<!-- if there's a back-match, combine cross and continue -->
					<xsl:when test="contains($back-cross, $synonym)">
						<xsl:value-of select="fn:cross-match-loop(concat($cross, ' ', $back-cross), $synonym, $classes, $index + 1)" />
					</xsl:when>
					<!-- otherwise, there's no match -->
					<xsl:otherwise>
						<xsl:value-of select="$index - 1" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- otherwise, there's no match -->
			<xsl:otherwise>
				<xsl:value-of select="$index - 1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!--=====================================================================
		Comment Groupers
		=====================================================================-->
	<xsl:function name="fn:find-max-comment-match" as="xs:integer">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="index"   as="xs:integer" />
		
		<xsl:choose>
			<!-- if there are no comments for this course, it can't be grouped -->
			<xsl:when test="not($classes[$index]/comments)">
				<xsl:value-of select="$index" />
			</xsl:when>
			<!-- otherwise, store the comment and loop -->
			<xsl:otherwise>
				<xsl:variable name="comment" select="normalize-space(fn:concat($classes[$index]/comments/text()))" as="xs:string" />
				<xsl:value-of select="fn:comment-match-loop($comment, $classes, $index + 1)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:comment-match-loop" as="xs:integer">
		<xsl:param name="comment" as="xs:string"  />
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="index"   as="xs:integer" />
		
		<xsl:choose>
			<!-- if we're off the end of the class list, return the last item in the class list -->
			<xsl:when test="$index &gt; count($classes)">
				<xsl:value-of select="count($classes)" />
			</xsl:when>
			<!-- if the comment matches the base comment, proceed to next -->
			<xsl:when test="compare($comment, normalize-space(fn:concat($classes[$index]/comments/text()))) = 0">
				<xsl:value-of select="fn:comment-match-loop($comment, $classes, $index + 1)" />
			</xsl:when>
			<!-- otherwise, there's no match -->
			<xsl:otherwise>
				<xsl:value-of select="$index - 1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>