<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">	
	<!-- utility functions -->
	<xsl:include
		href="libs/utils.xsl" />
	
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes"
		exclude-result-prefixes="utils" />
	
	<!-- command line parameters -->
	<xsl:param name="semester" as="xs:string" />
	<xsl:param name="year"     as="xs:string" />
	
	<!-- save some typing on edit -->
	<xsl:variable name="dir-mappings"  select="'mappings/'"                                                 as="xs:string"  />
	<xsl:variable name="file-sorting"  select="concat($year, '-', lower-case($semester), '.xml')"           as="xs:string"  />
	
	<!-- some global vars -->
	<xsl:variable name="doc-divisions" select="document(concat($dir-mappings, 'divisions.xml'))/divisions"  as="element()*" />
	<xsl:variable name="doc-semester"  select="document(concat($dir-mappings, $file-sorting))/mappings"     as="element()*" />
	<xsl:variable name="doc-sortkeys"  select="document('mappings/sortkeys.xml')/sortkeys"                  as="element()*" />
	<!-- something for sorting into minimesters -->

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
		<!-- ensure the parameters got passed -->
		<xsl:if test="fn:is-valid-params() = 'yes'">
			<!-- copy over some of the pertinant info -->
			<xsl:apply-templates select="schedule" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="schedule">
		<xsl:element name="schedule">
			<xsl:copy-of select="attribute()" />
			<xsl:apply-templates select="term" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:copy-of select="attribute()" />
			
			<xsl:call-template name="create-divisions">
				<xsl:with-param name="classes" select="class" as="element()*" />
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
					<xsl:with-param name="classes" select="current-group()" as="element()*" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- now create subjects -->
	<xsl:template name="create-subjects">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each-group select="$classes" group-by="@name-of-subject">
			<xsl:element name="subject">
				<xsl:variable name="name"            select="@name-of-subject"                                              as="xs:string"  />
				<xsl:variable name="subject-special" select="$doc-semester/descendant::subject[compare(@name, $name) = 0]"  as="element()*" />
				<xsl:variable name="subject-normal"  select="$doc-divisions/descendant::subject[compare(@name, $name) = 0]" as="element()*" />
				
				<!-- write subject info -->
				<xsl:attribute name="name" select="$name" />
				<xsl:copy-of select="$subject-normal/contact"  />
				<xsl:copy-of select="$subject-normal/comments" />
				
				<!-- send those with topics to create-topics, those without to create-types -->
				<xsl:variable name="courses-topic" select="current-group()[@name-of-topic]" as="element()*" />
				<xsl:if test="count($courses-topic) &gt; 0">
					<xsl:call-template name="create-topics">
						<xsl:with-param name="classes"         select="$courses-topic"   as="element()*" />
						<xsl:with-param name="subject-special" select="$subject-special" as="element()*" />
						<xsl:with-param name="subject-normal"  select="$subject-normal"  as="element()*" />
					</xsl:call-template>
				</xsl:if>
				<xsl:variable name="courses-types" select="current-group()[not(@name-of-topic)]" as="element()*" />
				<xsl:if test="count($courses-types) &gt; 0">
					<xsl:call-template name="create-types">
						<xsl:with-param name="classes" select="$courses-types" />
					</xsl:call-template>
				</xsl:if>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- create topics, if they exist -->
	<xsl:template name="create-topics">
		<xsl:param name="classes"         as="element()*" />
		<xsl:param name="subject-special" as="element()*" />
		<xsl:param name="subject-normal"  as="element()*" />
		
		<!-- group by topic -->
		<xsl:for-each-group select="$classes" group-by="@name-of-topic">
			<xsl:variable name="name"          select="@name-of-topic"   as="xs:string"  />
			<xsl:variable name="topic-special" select="$subject-special/topic[compare(@name, $name) = 0]" as="element()*" />
			<xsl:variable name="topic-normal"  select="$subject-normal/topic[compare(@name, $name) = 0]"  as="element()*" />

			<!-- determine whether to use special or normal -->
			<xsl:choose>
				<!-- special topic name 'none' just means "group, but don't display topic name" -->
				<xsl:when test="compare(@name-of-topic, 'none') = 0">
					<xsl:element name="topic">
						<xsl:attribute name="name" select="'none'" />
						
						<xsl:call-template name="create-types">
							<xsl:with-param name="classes" select="current-group()" />
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:when test="count($topic-special) = 1">
					<xsl:element name="topic">
						<xsl:attribute name="name"    select="current-grouping-key()"                        />
						<xsl:attribute name="sortkey" select="index-of($subject-special/topic/@name, $name)" />
						
						<!-- copy comments, if they exist -->
						<xsl:copy-of select="$topic-special/comments" />
						
						<!-- send those with topics to create-topics, those without to create-types -->
						<xsl:variable name="courses-subtopic" select="current-group()[@name-of-subtopic]" as="element()*" />
						<xsl:if test="count($courses-subtopic) &gt; 0">
							<xsl:call-template name="create-subtopics">
								<xsl:with-param name="classes"       select="$courses-subtopic" as="element()*" />
								<xsl:with-param name="topic-special" select="$topic-special"    as="element()*" />
								<xsl:with-param name="topic-normal"  select="$topic-normal"     as="element()*" />
							</xsl:call-template>
						</xsl:if>
						<xsl:variable name="courses-types" select="current-group()[not(@name-of-subtopic)]" as="element()*" />
						<xsl:if test="count($courses-types) &gt; 0">
							<xsl:call-template name="create-types">
								<xsl:with-param name="classes" select="$courses-types" />
							</xsl:call-template>
						</xsl:if>
					</xsl:element>
				</xsl:when>
				<xsl:when test="count($topic-special) &gt; 1">
					<xsl:message>!Warning! Unable to resolve topic <xsl:value-of select="current-grouping-key()" /> to a single topic in <xsl:value-of select="@name-of-subject" />.</xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count($topic-normal) = 1">
							<xsl:element name="topic">
								<xsl:attribute name="name"    select="current-grouping-key()"                       />
								<xsl:attribute name="sortkey" select="index-of($subject-normal/topic/@name, $name)" />
								
								<!-- copy comments, if they exist -->
								<xsl:copy-of select="$topic-normal/comments" />
								
								<!-- send those with topics to create-topics, those without to create-types -->
								<xsl:variable name="courses-subtopic" select="current-group()[@name-of-subtopic]" as="element()*" />
								<xsl:if test="count($courses-subtopic) &gt; 0">
									<xsl:call-template name="create-subtopics">
										<xsl:with-param name="classes"       select="$courses-subtopic" as="element()*" />
										<xsl:with-param name="topic-special" select="$topic-special"    as="element()*" />
										<xsl:with-param name="topic-normal"  select="$topic-normal"     as="element()*" />
									</xsl:call-template>
								</xsl:if>
								<xsl:variable name="courses-types" select="current-group()[not(@name-of-subtopic)]" as="element()*" />
								<xsl:if test="count($courses-types) &gt; 0">
									<xsl:call-template name="create-types">
										<xsl:with-param name="classes" select="$courses-types" />
									</xsl:call-template>
								</xsl:if>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>!Warning! Unable to resolve topic <xsl:value-of select="current-grouping-key()" /> to a single topic in <xsl:value-of select="@name-of-subject" />.</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- create subtopics, if they exist -->
	<xsl:template name="create-subtopics">
		<xsl:param name="classes"       as="element()*" />
		<xsl:param name="topic-special" as="element()*" />
		<xsl:param name="topic-normal"  as="element()*" />
		
		<!-- group by subtopic -->
		<xsl:for-each-group select="$classes" group-by="@name-of-subtopic">
			<xsl:variable name="name"             select="@name-of-subtopic"                                  as="xs:string"  />
			<xsl:variable name="subtopic-special" select="$topic-special/subtopic[compare(@name, $name) = 0]" as="element()*" />
			<xsl:variable name="subtopic-normal"  select="$topic-normal/subtopic[compare(@name, $name) = 0]"  as="element()*" />
			
			<!-- determine whether to use special or normal -->
			<xsl:choose>
				<xsl:when test="count($subtopic-special) = 1">
					<xsl:element name="subtopic">
						<xsl:attribute name="name"    select="current-grouping-key()"                         />
						<xsl:attribute name="sortkey" select="index-of($topic-special/subtopic/@name, $name)" />
						
						<xsl:call-template name="create-types">
							<xsl:with-param name="classes" select="current-group()" />
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<xsl:when test="count($topic-special) &gt; 1">
					<xsl:message>!Warning! Unable to resolve subtopic <xsl:value-of select="current-grouping-key()" /> to a single subtopic in topic <xsl:value-of select="@name-of-topic" /> in subject <xsl:value-of select="@name-of-subject" />.</xsl:message>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="count($topic-normal) = 1">
							<xsl:element name="topic">
								<xsl:attribute name="name"    select="current-grouping-key()"                        />
								<xsl:attribute name="sortkey" select="index-of($topic-normal/subtopic/@name, $name)" />
								
								<xsl:call-template name="create-types">
									<xsl:with-param name="classes" select="current-group()" />
								</xsl:call-template>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>!Warning! Unable to resolve subtopic <xsl:value-of select="current-grouping-key()" /> to a single subtopic in topic <xsl:value-of select="@name-of-topic" /> in subject <xsl:value-of select="@name-of-subject" />.</xsl:message>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- create types -->
	<xsl:template name="create-types">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each-group select="$classes" group-by="@type-schedule">
			<xsl:element name="type">
				<xsl:variable name="id" select="@type-schedule" as="xs:string" />
				
				<!-- write type info -->
				<xsl:attribute name="id"   select="@type-schedule"                                              />
				<xsl:attribute name="name" select="$doc-sortkeys/sortkey[@type = 'type']/type[@id = $id]/@name" />
				
				<!-- write sortkey-type -->
				<xsl:attribute name="sortkey-type" select="index-of($doc-sortkeys/sortkey[@type = 'type']/type/@id, current-grouping-key())" />
				
				<!-- proceed to courses -->
				<xsl:call-template name="create-courses">
					<xsl:with-param name="classes" select="current-group()" as="element()*" />
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- re-create courses -->
	<xsl:template name="create-courses">
		<xsl:param name="classes" as="element()*" />
		
		<!-- since the xml is pre-sorted by flatten_xml.xsl, we can just group-adjacent -->
		<xsl:for-each-group select="$classes" group-adjacent="@rubric">
			<xsl:for-each-group select="current-group()" group-adjacent="@number">
				<xsl:element name="course">
					<!-- write class info -->
					<xsl:copy-of select="@rubric|@number|@title-short|@title-long|@credit-hours|@core-code|@core-name" />
					
					<!-- try to clump multiple, identical class comments -->
					<xsl:variable name="clump" select="string-length(normalize-space(fn:compare-comments(current-group()))) = 0" as="xs:boolean" />
					
					<xsl:if test="$clump">
						<xsl:call-template name="create-comments">
							<xsl:with-param name="comments" select="current-group()[1]/comments" />
						</xsl:call-template>
					</xsl:if>
					
					<!-- copy comments -->
					<xsl:apply-templates select="comments-course" />
					
					<!-- proceed to classes -->
					<xsl:apply-templates select="current-group()">
						<xsl:with-param name="clump" select="$clump" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:element>
			</xsl:for-each-group>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template name="create-comments">
		<xsl:param name="comments" as="element()" />
		
		<xsl:element name="comments">
			<xsl:copy-of select="$comments/text()" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:param name="clump" tunnel="yes" />
		
		<xsl:element name="class">
			<xsl:copy-of select="@section|@synonym|@type-credit|@topic-code|@capacity|@weeks|@date-start|@date-end" />
			
			<!-- for sorting purposes -->
			<xsl:attribute name="sortkey-days"  select="fn:safe-min(meeting[@method = 'LEC']/@sortkey-days)"  />
			<xsl:attribute name="sortkey-times" select="fn:safe-min(meeting[@method = 'LEC']/@sortkey-times)" />

			<!-- copy meeting (with a few changes) -->
			<xsl:apply-templates select="meeting" />
			
			<!-- if not clumped, copy comments -->
			<xsl:if test="not($clump) and comments">
				<xsl:call-template name="create-comments">
					<xsl:with-param name="comments" select="comments" />
				</xsl:call-template>
			</xsl:if>
			<!-- copy sub-elements -->
			<xsl:copy-of select="xlisting|corequisite-section"/>
			
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:element name="meeting">
			<!-- copy attributes -->
			<xsl:copy-of select="attribute()" />
			
			<!-- copy the rest of the element's sub-elements -->
			<xsl:copy-of select="*" />
		</xsl:element>
	</xsl:template>
	
	<!-- functions -->
	<xsl:function name="fn:is-valid-params">
		<xsl:choose>
			<xsl:when test="(fn:is-valid-semester() != 'yes') or (fn:is-valid-year() != 'yes')">
				<xsl:if test="fn:is-valid-semester() != 'yes'"><xsl:message>!Warning! Invalid semester passed: semester(<xsl:value-of select="$semester" />).</xsl:message></xsl:if>
				<xsl:if test="fn:is-valid-year() != 'yes'"><xsl:message>!Warning! Invalid year passed: year(<xsl:value-of select="$year" />).</xsl:message></xsl:if>
			</xsl:when>
			<xsl:when test="count($doc-semester) = 0">
				<xsl:message>!Warning! couldn't load special sorting for: semester(<xsl:value-of select="$semester" />), year(<xsl:value-of select="$year" />).</xsl:message>
			</xsl:when>
			<xsl:when test="count($doc-sortkeys) = 0">
				<xsl:message>!Warning! couldn't load type info.</xsl:message>
			</xsl:when>
			<xsl:when test="count($doc-divisions) = 0">
				<xsl:message>!Warning! couldn't load division info.</xsl:message>
			</xsl:when>
			<xsl:otherwise>yes</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:is-valid-semester">
		<xsl:choose>
			<xsl:when test="$semester = 'Fall'">yes</xsl:when>
			<xsl:when test="$semester = 'Summer'">yes</xsl:when>
			<xsl:when test="$semester = 'Spring'">yes</xsl:when>
			<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="fn:is-valid-year">
		<xsl:choose>
			<!-- I know this looks stupid, but it's just testing that year is a number -->
			<xsl:when test="number($year) = number($year)">yes</xsl:when>
			<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:safe-min">
		<xsl:param name="set_str" as="xs:string*" />
		
		<!-- And why, exactly, can't a null string be converted to an int? Who knows?
			 Every other language I've used says an empty string evaluates to zero. -->
		<xsl:variable name="set_non-empty" select="$set_str[string-length() &gt; 0]" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="count($set_non-empty)">
				<xsl:value-of select="min($set_non-empty)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:compare-comments" as="xs:string">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:choose>
			<xsl:when test="count($classes) &lt; 1">
				<xsl:value-of select="'false'" />
			</xsl:when>
			<xsl:when test="count($classes) != count($classes/comments)">
				<xsl:value-of select="'false'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="comments" select="$classes/comments" as="element()*" />
				<xsl:variable name="base" select="$comments[1]/text()" as="xs:string" />
						
				<xsl:value-of select="fn:compare-comments($base, $comments, 2)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="fn:compare-comments" as="xs:string">
		<xsl:param name="base"     as="xs:string"  />
		<xsl:param name="comments" as="element()*" />
		<xsl:param name="index"    as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="count($comments) &lt; $index">
				<xsl:value-of select="''" />
			</xsl:when>
			<xsl:when test="compare($base, $comments[$index]/text()) = 0">
				<xsl:value-of select="fn:compare-comments($base, $comments, $index + 1)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>
