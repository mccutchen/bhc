<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:utils="http://www.brookhavencollege.edu/xml/utils">

	<!-- utility functions -->
	<xsl:include
	  href="utils.xsl" />
	  
	<xsl:output
	  method="xml"
	  encoding="iso-8859-1"
	  indent="yes" />
	  
	<!-- some global vars -->
	<xsl:variable name="doc-special"   select="document('special-sorting.xml')/mappings" />
	<xsl:variable name="doc-subjects"  select="document('subjects.xml')/subjects"   />
	<xsl:variable name="doc-divisions" select="document('divisions.xml')/divisions" />
	<!-- something for sorting into minimesters -->
	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'debug-templates'" />
	<!--
	<xsl:variable name="release-type" select="'final'" />
	<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- HUGE DISCLAIMER: this code is not elegant. In fact, from where it's sitting (off in some
	     dark corner, crying softly to itself) it can't even see elegant. It probably doesn't 
		 realize such a thing could even exist.
		 Basically, what this Frankenstein transform does is the logical equivalent of dropping an
		 elephant on DSC XML, over and over again, until it's flat enough to see through. 
		 That's it, really. I'm not proud of this code, but it works, and for the record, XSL sucks. -->
	
	
	<!-- start the madness -->
	<xsl:template match="/">

		<!-- copy over some of the pertinant info -->
		<xsl:if test="$release-type = 'final' or $release-type = 'debug-templates'">
		<xsl:apply-templates select="schedule" />
		</xsl:if>
	</xsl:template>
		
	<!-- match and fix schedule elements -->
	<xsl:template match="schedule">
		<xsl:element name="schedule">
			<xsl:attribute name="date-created"><xsl:value-of select="utils:convert-date-std(@date-created)" /></xsl:attribute>
			<xsl:attribute name="time-created"><xsl:value-of select="utils:convert-time-std(@time-created)" /></xsl:attribute>
			
			<xsl:apply-templates select="term" />
		</xsl:element>
	</xsl:template>
	
	<!-- match and fix term elements -->
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:attribute name="year"><xsl:value-of select="@year" /></xsl:attribute>
			<xsl:attribute name="semester"><xsl:value-of select="utils:strip-semester(@name)" /></xsl:attribute>
			<xsl:attribute name="date-start"><xsl:value-of select="utils:convert-date-std(@start-date)" /></xsl:attribute>
			<xsl:attribute name="date-end"><xsl:value-of select="utils:convert-date-std(@end-date)" /></xsl:attribute>
			
			<!-- we're only going to process Brookhaven classes --> 
			<xsl:apply-templates select="location[@name='200']//descendant::class" />
		</xsl:element>
	</xsl:template>
	
	<!-- this is where the elephant hits the first time. we are going to super-saturate the class element with data 
		 (which will be expanded later 'cause it's messy) -->
	<xsl:template match="class">
		<xsl:variable name="class-id" select="concat(@rubric, ' ', @number, '-', @section)" />
		
		<!-- now write the class with the sorting info in it -->
		<xsl:element name="class">
			<!-- copy over course & class info -->
			<xsl:attribute name="rubric"        select="ancestor::course/@rubric"            />
			<xsl:attribute name="number"        select="ancestor::course/@number"            />
			<xsl:attribute name="section"       select="@section"                            />
			<xsl:attribute name="synonym"       select="@synonym"                            />
			<xsl:attribute name="type-credit"   select="@credit-type"                        />  <!-- I don't know if this is useful for anything, so I'll keep it -->
			<xsl:attribute name="type-schedule" select="@schedule-type"                      />
			<xsl:attribute name="topic-code"    select="@topic-code"                         />
			<xsl:attribute name="credits"       select="ancestor::course/@credit-hours"      />
			<xsl:attribute name="weeks"         select="@weeks"                              />
			<xsl:attribute name="date-start"    select="utils:convert-date-std(@start-date)" />
			<xsl:attribute name="date-end"      select="utils:convert-date-std(@end-date)"   />
			<xsl:attribute name="title-short"   select="ancestor::course/@title"             />
			<xsl:attribute name="title-long"    select="ancestor::course/@long-title"        />

			<!-- now just stuff it with sorting info -->
			<xsl:choose>
				<!-- Emeritus = Senior Adult -->
				<xsl:when test="(@topic-code = 'E') or (@topic-code = 'EG') or (@topic-code = 'EMBLG')">
					<xsl:call-template name="apply-sorting-node">
						<xsl:with-param name="match-node" select="$doc-divisions//subject[@name = 'Senior Adult Education Program']" />
						<xsl:with-param name="class-id"   select="$class-id"          />
					</xsl:call-template>
				</xsl:when>
				<!-- if it's not a special type, do regular processing -->
				<xsl:otherwise>
					<!-- get special sorting, if it exists -->
					<xsl:variable name="match-node-special" select="$doc-special/descendant::pattern[matches($class-id, @match)]" />
					<xsl:choose>
						<!-- special sorting -->
						<xsl:when test="count($match-node-special) &gt; 0">
							<xsl:call-template name="apply-sorting-node">
								<xsl:with-param name="match-node" select="$match-node-special" />
								<xsl:with-param name="class-id"   select="$class-id" />
							</xsl:call-template>
						</xsl:when>
						<!-- no special sorting -->
						<xsl:otherwise>
							<!-- get non-special sorting -->
							<xsl:variable name="match-node-normal"  select="$doc-divisions/descendant::pattern[matches($class-id, @match)]" />
							<xsl:call-template name="apply-sorting-node">
								<xsl:with-param name="match-node" select="$match-node-normal" />
								<xsl:with-param name="class-id"   select="$class-id"          />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- copy descriptions -->
			<xsl:if test="ancestor::course/description">
				<xsl:element name="desc-course">
					<xsl:value-of select="ancestor::course/description" />
				</xsl:element>
			</xsl:if>
			<xsl:if test="description">
				<xsl:element name="desc-class">
					<xsl:value-of select="description" />
				</xsl:element>
			</xsl:if>

			
			<!-- now copy over the rest of the info in this class -->
			<xsl:apply-templates select="meeting" />
			<xsl:apply-templates select="xlisting" />
			<xsl:apply-templates select="corequisite-section" />
			
		<!-- we're done. Let the poor XML heal -->
		</xsl:element>
	</xsl:template>
	
	<!-- some quick error checks on the sorting node -->
	<xsl:template name="apply-sorting-node">
		<xsl:param name="match-node" as="element()*" />
		<xsl:param name="class-id"   as="xs:string"/>
				
		<xsl:choose>
			<!-- no matches -->
			<xsl:when test="count($match-node) &lt; 1">
				<xsl:message><xsl:text>!Warning! no matches found for </xsl:text><xsl:value-of select="$class-id" /></xsl:message>
			</xsl:when>
			<!-- multiple matches -->
			<xsl:when test="count($match-node) &gt; 1">
				<xsl:variable name="max-node" select="$match-node[@priority = max($match-node/@priority)]" as="element()*" />
				<!-- still multiple matches -->
				<xsl:choose>
					<xsl:when test="count($max-node) &lt; 1">
						<xsl:message>!Warning! unable to resolve multiple match results for <xsl:value-of select="$class-id" /></xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$max-node/parent::node()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- single match -->
			<xsl:otherwise>
				<xsl:apply-templates select="$match-node/parent::node()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ok, so the types of matches we can get off the preceeding 'code' are: subtopic, topic, or subject.
		 Each of the preceeding elements will be nested inside those elements that follow it. -->
	<xsl:template match="division">
		<xsl:attribute name="name-of-division" select="@name" />
	</xsl:template>
	<xsl:template match="subject">
		<xsl:attribute name="name-of-subject" select="@name" />
		<xsl:apply-templates select="parent::division" />
	</xsl:template>
	<xsl:template match="topic">
		<xsl:attribute name="name-of-topic" select="@name" />
		<xsl:variable name="subject-name" select="parent::subject/@name" />
		<xsl:variable name="subject"      select="$doc-divisions/descendant::subject[@name = $subject-name]" />
		<xsl:choose>
			<xsl:when test="count($subject) = 1">
				<xsl:apply-templates select="$subject" />
			</xsl:when>
			<xsl:when test="count($subject) &gt; 1">
				<xsl:message><xsl:text>Multiple subject matches when resolving sort order for </xsl:text><xsl:value-of select="@subject-name" /></xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message><xsl:text>No subject match when resolving sort order for </xsl:text><xsl:value-of select="@subject-name" /></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="subtopic">
		<xsl:attribute name="name-of-subtopic" select="@name" />
		<xsl:apply-templates select="parent::topic" />
	</xsl:template>
	
	<!-- and just to pretty up the meeting, xlisting, faculty, and corequisite-course/class elements... -->
	<xsl:template match="meeting">
		<xsl:element name="meeting">
			<xsl:attribute name="days"       select="@days" />
			<xsl:attribute name="method"     select="@method" />
			<xsl:attribute name="bldg"       select="@building" />
			<xsl:attribute name="room"       select="@room" />
			<xsl:attribute name="time-start" select="utils:convert-time-std(@start-time)" />
			<xsl:attribute name="time-end"   select="utils:convert-time-std(@end-time)" />
			
			<!-- for faculty elements -->
			<xsl:apply-templates select="./*" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="faculty">
		<xsl:element name="faculty">
			<xsl:attribute name="name-first" select="@first-name" />
			<xsl:attribute name="name-middle" select="@middle-name" />
			<xsl:attribute name="name-last"   select="@last-name" />
			<xsl:attribute name="email"       select="@email" />
			<xsl:attribute name="phone"       select="@phone" />
			<xsl:attribute name="class-load"  select="@class-load" /> <!-- I can't imagine why we'd need this -->
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="xlisting">
		<xsl:element name="xlisting">
			<xsl:attribute name="title" select="@title" />
			<xsl:attribute name="synonym" select="@synonym" />
			<xsl:attribute name="rubric"  select="@rubric" />
			<xsl:attribute name="number"  select="@number" />
			<xsl:attribute name="section" select="@section" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="corequisite-section">
		<xsl:element name="corequisite-section">
			<xsl:attribute name="title" select="@title" />
			<xsl:attribute name="synonym" select="@synonym" />
			<xsl:attribute name="rubric"  select="@rubric" />
			<xsl:attribute name="number"  select="@number" />
			<xsl:attribute name="section" select="section" />
		</xsl:element>
	</xsl:template>
	
		
</xsl:stylesheet>
