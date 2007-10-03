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
		exclude-result-prefixes="xs utils fn" />
	
	<!-- command line parameters -->
	<xsl:param name="semester" as="xs:string" />
	<xsl:param name="year"     as="xs:string" />
	  
	<!-- save some typing on edit -->
	<xsl:variable name="dir-mappings"  select="'mappings/'"                                                 as="xs:string"  />
	<xsl:variable name="file-semester" select="concat($year, '-', lower-case($semester), '.xml')"           as="xs:string"  />
	
	<!-- some global vars -->
	<xsl:variable name="doc-divisions" select="document(concat($dir-mappings, 'divisions.xml'))/divisions"  as="element()*" />
	<xsl:variable name="doc-semester"  select="document(concat($dir-mappings, $file-semester))/mappings"    as="element()*" />
	<xsl:variable name="doc-sortkeys"  select="document('mappings/sortkeys.xml')/sortkeys"                  as="element()*" />
	<xsl:variable name="doc-core"      select="document(concat($dir-mappings, 'core.xml'))/core-components" as="element()*" />
	<!-- something for sorting into minimesters -->
	
	<!-- for debugging purposes -->
	<xsl:variable name="release-type" select="'final'" />
	<!--
		<xsl:variable name="release-type" select="'debug-templates'" as="xs:string" />
		<xsl:variable name="release-type" select="'debug-functions'" />
	-->
	
	<!-- 
		This is the first step in creating a fairly neat and tidy xml document containing the useful information
		from DSC XML. This transform merely flattens the XML, exposing the data elements needed for tidy_xml.xsl.
	-->
	
	
	<!-- start (mostly for setting up debugging info) -->
	<xsl:template match="/">
		<!-- ensure the parameters got passed -->
		<xsl:if test="fn:is-valid-params() = 'yes'">
			<!-- copy over some of the pertinant info -->
			<xsl:apply-templates select="schedule" />
		</xsl:if>
	</xsl:template>
		
	<!-- match and fix schedule elements -->
	<xsl:template match="schedule">
		<xsl:element name="schedule">
			<xsl:attribute name="date-created" select="utils:convert-date-std(@date-created)" />
			<xsl:attribute name="time-created" select="utils:convert-time-std(@time-created)" />
			
			<xsl:apply-templates select="term" />
		</xsl:element>
	</xsl:template>
	
	<!-- match and fix term elements -->
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:attribute name="year"       select="@year"                               />
			<xsl:attribute name="semester"   select="utils:strip-semester(@name)"         />
			<xsl:attribute name="date-start" select="utils:convert-date-std(@start-date)" />
			<xsl:attribute name="date-end"   select="utils:convert-date-std(@end-date)"   />
			
			<!-- we're only going to process Brookhaven classes --> 
			<xsl:apply-templates select="location[@name='200']//descendant::class">
				<xsl:sort select="ancestor::course/@rubric" data-type="text"   />
				<xsl:sort select="ancestor::course/@number" data-type="number" />
				<xsl:sort select="@section"                 data-type="number" />
			</xsl:apply-templates>
		</xsl:element>
	</xsl:template>
	
	<!-- begin flattening the xml -->
	<xsl:template match="class">
		<xsl:variable name="class-id" select="concat(@rubric, ' ', @number, '-', @section)" as="xs:string" />
		
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
			<xsl:apply-templates select="ancestor::course/@credit-hours" />
			<xsl:apply-templates select="ancestor::course/@core-code"    />
			<xsl:attribute name="capacity"      select="@capacity"                           />
			<xsl:attribute name="weeks"         select="@weeks"                              />
			<xsl:attribute name="date-start"    select="utils:convert-date-std(@start-date)" />
			<xsl:attribute name="date-end"      select="utils:convert-date-std(@end-date)"   />
			<xsl:attribute name="title-short"   select="ancestor::course/@title"             />
			<xsl:attribute name="title-long"    select="ancestor::course/@long-title"        />

			<!-- now just stuff it with sorting info -->
			<xsl:choose>
				<!-- Special type (by topic-code): Emeritus = Senior Adult -->
				<xsl:when test="@topic-code = ('E','EG','EMBLG')">
					<xsl:variable name="match-node" select="$doc-divisions//subject[@name = 'Senior Adult Education Program']" />
					<xsl:call-template name="apply-sorting-node">
						<xsl:with-param name="match-node" select="$match-node" />
						<xsl:with-param name="class-id"   select="$class-id"   />
					</xsl:call-template>
				</xsl:when>
				<!-- special sorting (topics/subtopics, etc) -->
				<xsl:otherwise>
					<xsl:variable name="match-node-special" select="$doc-semester/descendant::pattern[matches($class-id, @match)]" />
					<xsl:choose>
						<xsl:when test="count($match-node-special) &gt; 0">
							<xsl:call-template name="apply-sorting-node">
								<xsl:with-param name="match-node" select="$match-node-special" />
								<xsl:with-param name="class-id"   select="$class-id"           />
							</xsl:call-template>
						</xsl:when>
						<!-- normal sorting (by division/subject) -->
						<xsl:otherwise>
							<xsl:variable name="match-node-normal" select="$doc-divisions/descendant::pattern[matches($class-id, @match)]" />
							<xsl:call-template name="apply-sorting-node">
								<xsl:with-param name="match-node" select="$match-node-normal"  />
								<xsl:with-param name="class-id"   select="$class-id"           />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- copy descriptions -->
			<xsl:if test="ancestor::course/description">
				<xsl:element name="comments-course">
					<xsl:value-of select="ancestor::course/description" />
				</xsl:element>
			</xsl:if>
			<xsl:if test="description">
				<xsl:element name="comments">
					<xsl:value-of select="description" />
				</xsl:element>
			</xsl:if>

			
			<!-- now copy over the rest of the info in this class -->
			<xsl:apply-templates select="meeting|xlisting|corequisite-section" />
			<!-- there are additional items listed in the district dtd, but I haven't seen them yet. -->
			
		<!-- we're done. -->
		</xsl:element>
	</xsl:template>
	
	<!-- when copying the credit hours, strip off the .00 -->
	<xsl:template match="@credit-hours">
		<xsl:attribute name="credit-hours"  select="replace(., '.00', '')" />
	</xsl:template>
	
	<!-- copying the core code involves a look-up -->
	<xsl:template match="@core-code">
		<xsl:variable name="code" select="." />
		<xsl:variable name="name" select="$doc-core/component[@code = $code]/@name" as="xs:string" />
		<xsl:if test="$name">
			<xsl:attribute name="core-code" select="."     />
			<xsl:attribute name="core-name" select="$name" />
		</xsl:if>
		<xsl:if test="not($name)">
			<xsl:message>!Warning! No core course name for <xsl:value-of select="$code" />.</xsl:message>
		</xsl:if>
	</xsl:template>
	
	<!-- error-check the match node -->
	<xsl:template name="apply-sorting-node">
		<xsl:param name="match-node"     as="element()*" />
		<xsl:param name="class-id"       as="xs:string"  />
		
		<xsl:choose>
			<!-- no matches -->
			<xsl:when test="count($match-node) &lt; 1">
				<xsl:value-of select="$match-node/@name" />
				<xsl:message><xsl:text>!Warning! no matches found for </xsl:text><xsl:value-of select="$class-id" /></xsl:message>
			</xsl:when>
			<!-- multiple matches -->
			<xsl:when test="count($match-node) &gt; 1">
				<xsl:variable name="max-node" select="$match-node[@priority = max($match-node/@priority)]" as="element()*" />
				<xsl:variable name="max-node-index" select="$match-node[@priority = max($match-node/@priority)]/position()" as="xs:integer*" />
				<xsl:choose>
					<!-- still multiple matches -->
					<xsl:when test="count($max-node) != 1">
						<xsl:message>!Warning! unable to resolve multiple match results for <xsl:value-of select="$class-id" /></xsl:message>
					</xsl:when>
					<!-- pared down to single match -->
					<xsl:otherwise>
						<xsl:apply-templates select="$max-node">
							<xsl:with-param name="class-id" select="$class-id" tunnel="yes" as="xs:string" />
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- single match -->
			<xsl:otherwise>
				<xsl:apply-templates select="$match-node">
					<xsl:with-param name="class-id" select="$class-id" tunnel="yes" as="xs:string" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- ok, so the types of matches we can get off the preceeding code are: subtopic, topic, or subject.
		 Each of the preceeding elements will be nested inside those elements that follow it. -->
	<xsl:template match="division">
		<xsl:attribute name="name-of-division" select="@name" />
	</xsl:template>
	
	<xsl:template match="subject">
		<xsl:param name="class-id" tunnel="yes" as="xs:string" />
		
		<xsl:attribute name="name-of-subject" select="@name" />
		
		<!-- switch over to doc-divisions, if necessary -->
		<xsl:choose>
			<xsl:when test="count(parent::division) = 0">
				<xsl:variable name="name"   select="@name" as="xs:string" />
				<xsl:variable name="parent" select="$doc-divisions/descendant::subject[compare(@name, $name) = 0]/parent::node()" />
				<xsl:choose>
					<xsl:when test="count($parent) = 0">
						<xsl:message>!Warning! Unable to resolve subject <xsl:value-of select="$name"/> to a single division</xsl:message>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="$parent" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="parent::division" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="topic">
		<xsl:param name="class-id" tunnel="yes" as="xs:string" />
		
		<xsl:attribute name="name-of-topic" select="@name" />
		
		<xsl:variable name="parent" select="parent::subject" />
		<xsl:choose>
			<xsl:when test="count($parent) != 1">
				<xsl:message>!Warning! Unable to resolve division for <xsl:value-of select="$class-id" />.</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$parent" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="subtopic">
		<xsl:param name="class-id" tunnel="yes" as="xs:string" />
		
		<xsl:attribute name="name-of-subtopic" select="@name" />
		
		<xsl:variable name="parent" select="parent::topic" />
		<xsl:choose>
			<xsl:when test="count($parent) != 1">
				<xsl:message>!Warning! Unable to resolve division for <xsl:value-of select="$class-id" />.</xsl:message>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="$parent" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- this just catches patterns and bumps it back up to the lowest level of organization -->
	<xsl:template match="pattern">
		<xsl:apply-templates select="parent::node()" />
	</xsl:template>
	
	<!-- and just to pretty up the meeting, xlisting, faculty, and corequisite-course/class elements... -->
	<xsl:template match="meeting">
		<xsl:element name="meeting">
			<xsl:attribute name="days"       select="@days"     />
			<xsl:attribute name="method"     select="@method"   />
			<xsl:attribute name="bldg"       select="@building" />
			<xsl:attribute name="room"       select="@room"     />
			<xsl:attribute name="time-start" select="utils:convert-time-std(@start-time)" />
			<xsl:attribute name="time-end"   select="utils:convert-time-std(@end-time)"   />
			
			<!-- insert sortkeys -->
			<!-- write sortkey-days -->
			<xsl:variable name="days" select="@days" />
			<xsl:attribute name="sortkey-days" select="index-of($doc-sortkeys/sortkey[@type = 'days']/days/@id, $days)" />
			
			<!-- write sortkey-times -->
			<xsl:attribute name="sortkey-times" select="fn:build-sortkey-times(@start-time)" />
			
			<!-- write sortkey-method -->
			<xsl:variable name="method" select="@method" />
			<xsl:attribute name="sortkey-method" select="index-of($doc-sortkeys/sortkey[@type = 'method']/method/@id, $method)" />
			
			<!-- for faculty elements -->
			<xsl:apply-templates select="./*" />
		</xsl:element>
	</xsl:template>
	
	<!-- the reason I'm not doing a <xsl:copy-of select="attribute()" /> on these next elements is that
		 there are fields in here that are repetitious and also redundant, too. -->
	<xsl:template match="faculty">
		<xsl:element name="faculty">
			<xsl:attribute name="name-first"  select="@first-name"  />
			<xsl:attribute name="name-middle" select="@middle-name" />
			<xsl:attribute name="name-last"   select="@last-name"   />
			<xsl:attribute name="email"       select="@email"       />
			<xsl:attribute name="phone"       select="@phone"       />
			<xsl:attribute name="class-load"  select="@class-load"  /> <!-- I can't imagine why we'd need this -->
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="xlisting">
		<xsl:element name="xlisting">
			<xsl:attribute name="title"   select="@title"   />
			<xsl:attribute name="synonym" select="@synonym" />
			<xsl:attribute name="rubric"  select="@rubric"  />
			<xsl:attribute name="number"  select="@number"  />
			<xsl:attribute name="section" select="@section" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="corequisite-section">
		<xsl:element name="corequisite-section">
			<xsl:attribute name="title"   select="@title"   />
			<xsl:attribute name="synonym" select="@synonym" />
			<xsl:attribute name="rubric"  select="@rubric"  />
			<xsl:attribute name="number"  select="@number"  />
			<xsl:attribute name="section" select="section"  />
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
			<xsl:when test="count($doc-core) = 0">
				<xsl:message>!Warning! couldn't load core info.</xsl:message>
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
	
	<!-- build sortkey-times -->
	<xsl:function name="fn:build-sortkey-times">
		<xsl:param name="time" as="xs:string" />
		
		<!-- ok, I'm going to cheat a bit here. Since there are only so many times available, we'll just convert to an int -->
		<xsl:variable name="hour" select="substring-before($time, ':')"                 as="xs:string" />
		<xsl:variable name="mins" select="substring(substring-after($time, ':'), 1, 2)" as="xs:string" />
		
		<xsl:choose>
			<!-- pm -->
			<xsl:when test="matches($time, '.*[pP].*')">
				<xsl:choose>
					<!-- if it's not 12pm, add 12 to it -->
					<xsl:when test="$hour != '12'">
						<xsl:value-of select="xs:string(xs:integer($hour) + 12)" /><xsl:value-of select="$mins" />
					</xsl:when>
					<!-- if it is 12pm, leave as-is. -->
					<xsl:when test="$hour = '12'">
						<xsl:value-of select="$hour" /><xsl:value-of select="$mins" />
					</xsl:when>
				</xsl:choose>
			</xsl:when>
			<!-- am -->
			<xsl:when test="matches($time, '.*[aA].*')">
				<xsl:choose>
					<!-- if it's not 12am, leave as-is -->
					<xsl:when test="$hour != '12'">
						<xsl:value-of select="$hour" /><xsl:value-of select="$mins" />
					</xsl:when>
					<!-- if it is 12am, it's really 0am -->
					<xsl:when test="$hour = '12'">
						<xsl:value-of select="'00'" /><xsl:value-of select="$mins" />
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>
