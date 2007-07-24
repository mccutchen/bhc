<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:utils="http://www.brookhavencollege.edu/xml/utils"> <!-- for functions -->

	<!-- utility functions
	<xsl:include
	  href="utils.xsl" /> -->
	  
	<!-- DEV NOTE: change this to xml later, for now I kinda like it -->
	<xsl:output
	  method="xml"
	  encoding="iso-8859-1"
	  indent="yes" />
	  
	<!-- some global vars -->
	<xsl:variable name="doc-subjects" select="document('subjects.xml')/subjects" />
	<xsl:variable name="doc-contacts" select="document('base.xml')/mappings/mapping[@type = 'contact-info']" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="/divisions/*" />
	</xsl:template>
	
	<xsl:template match="division">
		<xsl:element name="division">
			<!-- copy division info -->
			<xsl:attribute name="title" select="@name" />
			
			<!-- select appropriate contact info -->
			<xsl:variable name="name"         select="@name" />
			<xsl:variable name="contact-info" select="$doc-contacts/division[@name = $name]" />
			
			<!-- copy contact info -->
			<xsl:attribute name="ext" select="$contact-info/@ext" />
			<xsl:attribute name="room" select="$contact-info/@room" />
			<xsl:attribute name="email" select="$contact-info/@email" />
			
			<!-- if we didn't get a single match, slap up an error -->
			<xsl:choose>
				<xsl:when test="count($contact-info) &lt; 1">
					<xsl:message>Warning! - could not find contact info for <xsl:value-of select="$name" />.</xsl:message>
				</xsl:when>
				<xsl:when test="count($contact-info) &gt; 1">
					<xsl:message>Warning! - found more than one match for <xsl:value-of select="$name" />.</xsl:message>
				</xsl:when>
			</xsl:choose>
			
			<!-- debug:
			<xsl:text>&#10; matched </xsl:text>
				<xsl:value-of select="count($contact-info)" />
				<xsl:text> of </xsl:text>
				<xsl:value-of select="count($doc-contacts/division)" />
				<xsl:text> contacts.</xsl:text>
			<xsl:text>&#10;</xsl:text> -->
			
			<!-- build a list of patterns in this division -->
			<xsl:call-template name="match-rubrics">
				<xsl:with-param name="rubrics-list" select="string-join(pattern/@match, ' ')" />
			</xsl:call-template>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="match-rubrics">
		<xsl:param name="rubrics-list" />
		<xsl:variable name="rubric-count" select="count(tokenize($rubrics-list, ' '))" />
		
		<!-- debug: find subjects to stuff division with
		<xsl:text>&#10; rubric's left (</xsl:text>
			<xsl:value-of select="$rubric-count" />
			<xsl:text>): </xsl:text>
			<xsl:value-of select="$rubrics-list" />
		<xsl:text>&#10;</xsl:text> -->
		
		<!-- recursively call find-subject until we're done -->
		<xsl:call-template name="find-subject">
			<xsl:with-param name="rubrics-list"  select="$rubrics-list" />
			<xsl:with-param name="subjects-done" select="''"            />
			<xsl:with-param name="index"         select="1"             />
			<xsl:with-param name="total"         select="$rubric-count" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="find-subject">
		<xsl:param name="rubrics-list" />
		<xsl:param name="subjects-done" />
		<xsl:param name="index"        />
		<xsl:param name="total"        />
		
		<!-- since this is a recursive template, check if we're still working -->
		<xsl:if test="$index &lt;= $total">
			<!-- split the list into an array (kinda) -->
			<xsl:variable name="rubric" select="tokenize($rubrics-list, ' ')" />
			<!-- get the subset of subjects that contain our rubric in their patterns -->
			<xsl:variable name="subject" select="$doc-subjects//pattern[contains(string-join(utils:is-matching-rubric(replace(@match, ' ', '_'),$rubrics-list),' '), 'true')]//ancestor::subject" />
			<!-- get the patterns listed in the subjects selected -->
			<xsl:variable name="subjects-finished" select="replace($subject/@name, ' ', '_')" />
			
			<!-- if we found at least one subject -->
			<xsl:choose>
				<xsl:when test="count($subject) &gt; 0">
					<!-- loop through each of the results -->
					<xsl:for-each select="$subject">
						<xsl:sort select="@name" />
						<xsl:if test="not(contains($subjects-done, @name))">
							<!-- debug: get the subject name(s)
							<xsl:text>    </xsl:text>
								<xsl:value-of select="@match" />
								<xsl:text>: '</xsl:text>
								<xsl:value-of select="(ancestor::subject)/@name" />
								<xsl:text>'&#10;</xsl:text> -->
							
							<!-- copy the subject -->
							<xsl:apply-templates select="." />
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<!-- display warning -->
					<xsl:message>Could not find containing subject for <xsl:value-of select="$rubric[$index]" />.</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
				
			<!-- we're not done, so process next
			<xsl:call-template name="find-subject">
				<xsl:with-param name="rubrics-list" select="$rubrics-list" />
				<xsl:with-param name="subjects-done" select="concat($subjects-done, ' ', string-join($subjects-finished, ' '))" />
				<xsl:with-param name="index"        select="number($index)+1" />
				<xsl:with-param name="total"        select="$total" />
			</xsl:call-template> -->
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="subject">
		<!-- find contact info -->
		<xsl:element name="subject">
			<!-- select appropriate contact info -->
			<xsl:variable name="name"         select="replace(@name, ' - Unsorted', '')" />
			<xsl:variable name="contact-info" select="$doc-contacts/subject[@name = $name]" />
			
			<!-- copy subject info -->
			<xsl:attribute name="title" select="$name" />
			
			<!-- copy contact info -->
			<xsl:attribute name="ext" select="$contact-info/@ext" />
			<xsl:attribute name="room" select="$contact-info/@room" />
			<xsl:attribute name="email" select="$contact-info/@email" />
			
			<!-- if we gott several matches, slap up an error -->
			<xsl:if test="count($contact-info) &gt; 1">
				<xsl:message>Warning! - found more than one match for <xsl:value-of select="$name" />.</xsl:message>
			</xsl:if>
			
			<!-- if there are comments, copy them over -->
			<xsl:if test="count(comments) &gt; 0">
				<xsl:copy-of select="comments" />

				<!-- if there's more than one comment, toss a warning to user -->
				<xsl:if test="count(comments) &gt; 1">
					<xsl:message>Warning! More than one comment attatched to subject <xsl:value-of select="@name" />.</xsl:message>
				</xsl:if>
			</xsl:if>
			
			<!-- if there are patterns, copy them over -->
			<xsl:if test="count(pattern) &gt; 0">
				<xsl:copy-of select="pattern" />
			</xsl:if>
			
			<!-- if there are topics, copy them over -->
			<xsl:if test="count(topic) &gt; 0">
				<xsl:copy-of select="topic" />
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<!-- figure this out Monday 
	<xsl:template match="comments">
		<xsl:element name="comment">
			<xsl:choose>
				<xsl:when test="count(p) &lt; 1">
					<xsl:element name="p">
						<xsl:apply-templates select="."> -->
				
	
	<xsl:function name="utils:is-matching-rubric">
		<xsl:param name="match-string" />
		<xsl:param name="rubric-list"  />
		
		<!-- break the rubric list into a sequence -->
		<xsl:variable name="rubric" select="tokenize($rubric-list, ' ')" />
		
		<!-- check to see if each rubric is in the list -->
		<xsl:for-each select="$rubric">
			<xsl:choose>
				<xsl:when test="contains($match-string, .)">
					<xsl:value-of select="'true '" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'false '" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:function>

</xsl:stylesheet>