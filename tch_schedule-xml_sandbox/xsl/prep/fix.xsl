<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<!-- utility functions -->
	<xsl:include
		href="prep-utils.xsl" />
	<!-- output -->
	<xsl:output
		method="xml"
		encoding="iso-8859-1"
		indent="yes"
		exclude-result-prefixes="xs utils fn"
		doctype-system="../dtds/xml-fixed.dtd" />
	
	
	<!--=====================================================================
		Parameters
		======================================================================-->
	<!-- a second input file (for Summer semesters) -->
	<xsl:param name="second-schedule" />
	
	<!-- for puting classes into division/subject/etc heirarchy -->
	<xsl:param name="path-mappings" />
	
	<!-- for sortkey values -->
	<xsl:param name="path-sortkeys" />
	<xsl:param name="path-core"     />
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<!-- check for presence of second file -->
	<xsl:variable name="doc-schedule" select="if (contains($second-schedule, '.xml') and utils:check-file($second-schedule)) then doc(replace($second-schedule, '\\','/'))/schedule  else ''" />
	<xsl:variable name="doc-mappings" select="if (utils:check-file($path-mappings))   then doc(replace($path-mappings, '\\','/'))/mappings    else ''" />
	<xsl:variable name="doc-sortkeys" select="if (utils:check-file($path-sortkeys))   then doc(replace($path-sortkeys, '\\','/'))/sortkeys    else ''" />
	<xsl:variable name="doc-core"     select="if (utils:check-file($path-core))       then doc(replace($path-core, '\\','/'))/core-components else ''" />
	
	<!--=====================================================================
		Begin Transformation
		
		Note: if there is more than one input file, the creation datetime
		will reflect the creation of the oldest input file.
		======================================================================-->
	<xsl:template match="/schedule">
		<xsl:choose>
			<!-- if there's errors loading the required docs, bail out -->
			<xsl:when test="$doc-mappings = '' or $doc-core = '' or $doc-sortkeys = ''">
				<xsl:message>
					<xsl:text>Unable to load: </xsl:text>
					<xsl:value-of select="if($doc-mappings = '') then $path-mappings else ''" />
					<xsl:value-of select="if($doc-sortkeys = '') then $path-sortkeys else ''" />
					<xsl:value-of select="if($doc-core     = '') then $path-core     else ''" />
				</xsl:message>
			</xsl:when>
			
			<!-- otherwise, proceed -->
			<xsl:otherwise>
				<xsl:copy>
					<xsl:call-template name="set-semester-year">
						<xsl:with-param name="semesters" select="term/@name, if($doc-schedule != '') then $doc-schedule//term/@name else none" />
						<xsl:with-param name="years"     select="term/@year, if($doc-schedule != '') then $doc-schedule//term/@year else none" />
					</xsl:call-template>
					<xsl:call-template name="set-creation-datetime">
						<xsl:with-param name="dates" select="@date-created, if($doc-schedule != '') then $doc-schedule//term/@date-created else none" />
						<xsl:with-param name="times" select="@time-created, if($doc-schedule != '') then $doc-schedule//term/@time-created else none" />
					</xsl:call-template>
					
					<!-- it doesn't matter what term a course falls into in dsc xml, we have our own dates -->
					<xsl:variable name="other-courses" select="if($doc-schedule != '') then $doc-schedule//course else none" as="element()*"></xsl:variable>
					<xsl:call-template name="create-terms">
						<xsl:with-param name="courses" select="//course | $other-courses" />
					</xsl:call-template>
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="create-terms">
		<xsl:param name="courses" as="element()*" />

		<!-- get a list of possible terms -->
		<xsl:variable name="terms" select="$doc-mappings/info/term" as="element()*" />
		
		<!-- for each term, spit out classes -->
		<xsl:for-each select="$terms">
			<xsl:sort select="utils:convert-date-ord(@date-start)" data-type="number" />
			
			<xsl:variable name="date-min" select="@date-start" as="xs:string" />
			<xsl:variable name="date-max" select="@date-end"   as="xs:string" />
			<xsl:apply-templates select=".">
				<xsl:with-param name="courses" 
					select="$courses[class[utils:compare-dates-between(@start-date, $date-min, $date-max, true(), true())]]" />
			</xsl:apply-templates>
		</xsl:for-each>
		
		<!-- if there are any that didn't fit into the terms, spit 'em out  -->
		<xsl:call-template name="create-term-leftovers">
			<xsl:with-param name="terms"   select="$terms"  />
			<xsl:with-param name="classes" select="//class" />
		</xsl:call-template>
	</xsl:template>
	
	<!--=====================================================================
		Regular Templates
		
		Create & process the sub-elements of the schedule
		======================================================================-->
	<xsl:template match="term">
		<xsl:param name="courses" as="element()*" />
		
		<xsl:copy>
			<xsl:attribute name="name"       select="@name"                               />
			<xsl:attribute name="date-start" select="utils:convert-date-std(@date-start)" />
			<xsl:attribute name="date-end"   select="utils:convert-date-std(@date-end)"   />
			<xsl:attribute name="display"    select="'true'" />
			<xsl:attribute name="sortkey"    select="@sortkey" />
			
			<xsl:apply-templates select="$courses">
				<xsl:with-param name="date-min" select="@date-start" />
				<xsl:with-param name="date-max" select="@date-end"   />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="course">
		<xsl:param name="date-min" as="xs:string" />
		<xsl:param name="date-max" as="xs:string" />
		
		<xsl:copy>
			<xsl:attribute name="rubric"  select="@rubric" />
			<xsl:attribute name="number"  select="@number" />
			<xsl:apply-templates          select="@credit-hours" />
			<xsl:if test="@core-code">
				<xsl:attribute name="core-code" select="@core-code" />
				<xsl:variable name="code" select="@core-code" />
				<xsl:attribute name="core-name" select="$doc-core/component[@code = $code]/@name" />
			</xsl:if>
			<!-- oddly enough, course titles are not used, only class titles 
			<xsl:attribute name="title-short"  select="@title" />
			<xsl:attribute name="title-long"   select="@long-title" /> -->
			
			<xsl:apply-templates select="description" />
			<xsl:apply-templates select="class[utils:compare-dates-between(@start-date, $date-min, $date-max, true(), true())]" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="course/@credit-hours">
		<xsl:attribute name="credit-hours" select="replace(., '.00', '')" />
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:copy>
			<xsl:attribute name="synonym" select="@synonym" />
			<xsl:attribute name="section" select="@section" />
			<xsl:attribute name="title"   select="@title"   />
			<xsl:attribute name="date-start" select="utils:convert-date-std(@start-date)" />
			<xsl:attribute name="date-end" select="utils:convert-date-std(@end-date)" />
			<xsl:attribute name="schedule-type" select="@schedule-type" />
			<xsl:attribute name="topic-code" select="@topic-code" />
			<xsl:attribute name="weeks" select="@weeks" />
			<xsl:attribute name="capacity" select="@capacity" />
			<xsl:attribute name="sortkey-dates" select="utils:convert-date-ord(@start-date)" />
			<!-- these attributes from the dtd seem mildly useful, but don't actually exist in the data
			<xsl:attribute name="seats-available" select="@seats-available" />
			<xsl:attribute name="tuition" select="@tuition" /> -->
			<!-- this one seems like it may be useful, but I'm not sure how yet
			<xsl:attribute name="online-primary" select="@online-primary-class" /> -->
			
			<!-- these are some artificial attributes that I'm going to put in the data, 
				since they are an integral part of how the output is produced. Maybe not
				the perfect solution, but it makes my life easier -->
			<xsl:element name="visibility">
				<xsl:attribute name="is-suppressed" select="@topic-code = ('XX','YY') or not(meeting)" />
				<xsl:attribute name="is-dl" select="@schedule-type = 'DL'" />
				<xsl:attribute name="is-w" select="@schedule-type = 'W'" />
				<xsl:attribute name="is-wcc" select="@schedule-type = 'W' and ancestor::course/@core-code and ancestor::course/@core-code != ''" />
				<xsl:attribute name="is-flex" select="@schedule-type = ('FD','FN')" />
				<xsl:if test="@schedule-type = ('FD','FN')">
					<xsl:attribute name="flex-month" select="utils:month-name(tokenize(utils:convert-date-std(@start-date), '/')[1])" />
				</xsl:if>
			</xsl:element>
			
			<!-- figure out where it should be in the division structure -->
			<xsl:element name="hierarchy">
				<xsl:variable name="class-id" select="concat(parent::course/@rubric, ' ', parent::course/@number, '-', @section)" as="xs:string" />
				<xsl:choose>
					<!-- special type (by topic-code): Emeritus = Senior Adult -->
					<xsl:when test="@topic-code = ('E','EG','EMBLG')">
						<xsl:variable name="match-node" select="$doc-mappings//subject[@name = 'Senior Adult Education Program']" />
						<xsl:call-template name="apply-sorting-node">
							<xsl:with-param name="match-node" select="$match-node" />
							<xsl:with-param name="class-id"   select="$class-id"   />
						</xsl:call-template>
					</xsl:when>
					<!-- special sorting (topics/subtopics, etc) -->
					<xsl:otherwise>
						<xsl:call-template name="apply-sorting-node">
							<xsl:with-param name="match-node" select="$doc-mappings/descendant::pattern[matches($class-id, @match)]" as="element()*" />
							<xsl:with-param name="class-id"   select="$class-id" as="xs:string" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			
			
			<xsl:apply-templates select="description" />
			<xsl:apply-templates select="meeting" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:copy>
			<xsl:attribute name="method" select="@method" />
			<xsl:attribute name="days" select="@days" />
			<xsl:attribute name="bldg" select="@building" />
			<xsl:attribute name="room" select="@room" />
			<xsl:attribute name="time-start" select="utils:convert-time-std(@start-time)" />
			<xsl:attribute name="time-end" select="utils:convert-time-std(@end-time)" />
			
			<!-- insert sortkeys -->
			<!-- write sortkey-days -->
			<xsl:variable name="days" select="@days" />
			<xsl:variable name="sortkey-days" select="index-of($doc-sortkeys/sortkey[@type = 'days']/days/@id, $days)" as="xs:integer*" />
			<xsl:attribute name="sortkey-days" select="if (not($sortkey-days)) then 0 else $sortkey-days" />
			
			<!-- write sortkey-times -->
			<xsl:attribute name="sortkey-times" select="utils:convert-time-ord(@start-time)" />
			
			<!-- write sortkey-method -->
			<xsl:variable name="method" select="@method" />
			<xsl:variable name="sortkey-method" select="index-of($doc-sortkeys/sortkey[@type = 'method']/method/@id, $method)" as="xs:integer*" />
			<xsl:attribute name="sortkey-method" select="if (not($sortkey-method)) then 0 else $sortkey-method" />
			
			<xsl:apply-templates select="faculty" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="faculty">
		<xsl:copy>
			<xsl:attribute name="name-first"  select="@first-name"  />
			<xsl:attribute name="name-middle" select="@middle-name" />
			<xsl:attribute name="name-last"   select="@last-name"   />
			<xsl:attribute name="email"       select="@email"       />
			<xsl:attribute name="phone"       select="@phone"       />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="description">
		<xsl:element name="comments">
			<xsl:copy-of select="text()" />
		</xsl:element>
	</xsl:template>
	
	
	<!--=====================================================================
		Sorting Templates
		
		These templates do some lookups to determine where the class fits into
		the div/subj/etc heirarchy
		======================================================================-->
	<!-- error-check the match node -->
	<xsl:template name="apply-sorting-node">
		<xsl:param name="match-node"     as="element()*" />
		<xsl:param name="class-id"       as="xs:string"  />
		
		<xsl:choose>
			<!-- no matches -->
			<xsl:when test="count($match-node) &lt; 1">
				<xsl:value-of select="$match-node/@name" />
				<xsl:message><xsl:text>!Warning! no matches found for </xsl:text><xsl:value-of select="$class-id" /></xsl:message>
				<xsl:attribute name="name-of-division" select="'Unknown Division'" />
				<xsl:attribute name="name-of-subject"  select="'Unknown Subject'"  />
			</xsl:when>
			<!-- multiple matches -->
			<xsl:when test="count($match-node) &gt; 1">
				<!-- first choose highest priority(s), then longest lengths (most precise, roughly) -->
				<xsl:variable name="temp-node" select="$match-node[@priority = max($match-node/@priority)]" as="element()*" />
				<xsl:variable name="max-node"  select="$temp-node[string-length(@match) = max(fn:string-length($temp-node/@match))]" as="element()*" />				<xsl:choose>
					<!-- still multiple matches -->
					<xsl:when test="count($max-node) != 1">
						<xsl:message>!Warning! unable to resolve multiple match results for <xsl:value-of select="$class-id" /></xsl:message>
						<xsl:attribute name="name-of-division" select="fn:merge-identical($max-node/ancestor::division/@name, 'Unknown Division')" />
						<xsl:attribute name="name-of-subject" select="fn:merge-identical($max-node/ancestor::subject/@name, 'Unknown Subject')" />
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
		<xsl:apply-templates select="parent::division" />
	</xsl:template>
	
	<xsl:template match="topic">
		<xsl:param name="class-id" tunnel="yes" as="xs:string" />
		
		<xsl:attribute name="name-of-topic" select="@name" />
		<xsl:apply-templates select="parent::subject" />
	</xsl:template>
	<xsl:template match="subtopic">
		<xsl:param name="class-id" tunnel="yes" as="xs:string" />
		
		<xsl:attribute name="name-of-subtopic" select="@name" />
		<xsl:apply-templates select="parent::topic" />
	</xsl:template>
	
	<!-- this just catches patterns and bumps it back up to the lowest level of organization -->
	<xsl:template match="pattern">
		<xsl:if test="ancestor::subject/@ordered = 'true'"><xsl:attribute name="sortkey" select="@sortkey" /></xsl:if>
		<xsl:apply-templates select="parent::node()" />
	</xsl:template>
	
	
	<!--=====================================================================
		Utility Templates
		
		These templates are here to clean up the code above
		======================================================================-->
	<xsl:template name="set-creation-datetime">
		<xsl:param name="dates" as="xs:string*"/>
		<xsl:param name="times" as="xs:string*" />
		
		<!-- check the number of date-time sets -->
		<xsl:choose>
			<!-- ensure the numbers match -->
			<xsl:when test="count($dates) != count($times)">
				<xsl:message><xsl:text>ERROR: numbers of schedule dates and times do not match.</xsl:text></xsl:message>
			</xsl:when>
			
			<!-- if there is only one set -->
			<xsl:when test="count($dates) = 1">
				<xsl:attribute name="creation-date" select="$dates[1]" />
				<xsl:attribute name="creation-time" select="$times[1]" />
			</xsl:when>
			
			<!-- otherwise there are multiple, so use newest (Summer I stops being produced before Summer II leaves scope) -->
			<xsl:otherwise>
				<xsl:variable name="date-newest" select="utils:select-date-newest($dates)" as="xs:string" />
				<xsl:attribute name="creation-date" select="$date-newest" />
				<xsl:attribute name="creation-time" select="$times[index-of($dates, $date-newest)]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="set-semester-year">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />

		<!-- check the number of semester-year sets -->
		<xsl:choose>
			<!-- ensure the numbers match -->
			<xsl:when test="count($semesters) != count($years)">
				<xsl:message><xsl:text>ERROR: numbers of schedule semesters and years do not match.</xsl:text></xsl:message>
			</xsl:when>
			
			<!-- if there is only one set -->
			<xsl:when test="count($semesters) = 1">
				<xsl:attribute name="semester" select="utils:strip-semester($semesters[1])" />
				<xsl:attribute name="year"     select="$years[1]" />
			</xsl:when>
			
			<!-- if there are two sets, ensure it's summer -->
			<xsl:when test="count($semesters) = 2">
				<xsl:if test="fn:verify-terms($semesters[1], $semesters[2])">
					<xsl:attribute name="semester" select="'Summer'" />
					<xsl:attribute name="year"     select="$years[1]" />
				</xsl:if>
			</xsl:when>
			
			<!-- otherwise there are multiple, and that is not supported -->
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>ERROR: unable to merge multiple, non-Summer schedules.</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="create-term-leftovers">
		<xsl:param name="terms"   as="element()*" />
		<xsl:param name="classes" as="element()*" />
		
		<xsl:choose>
			<!-- if we've finished processing terms -->
			<xsl:when test="count($terms) = 0">
				
				<!-- if we ended up with classes that don't fit -->
				<xsl:if test="count($classes) &gt; 0">
					<xsl:element name="term">
						<xsl:attribute name="name" select="'leftovers'" />
						<xsl:attribute name="date-start" select="'NA'" />
						<xsl:attribute name="date-end" select="'NA'" />
						<xsl:attribute name="display" select="'false'" />
						<xsl:attribute name="sortkey" select="999" />
						<xsl:message>
							<xsl:text>!Warning!: </xsl:text>
							<xsl:value-of select="count($classes)"></xsl:value-of>
							<xsl:text> Classes do not fit into any term.</xsl:text>
						</xsl:message>
						
						<xsl:for-each-group select="$classes" group-by="ancestor::course/@rubric">
							<xsl:for-each-group select="current-group()" group-by="ancestor::course/@number">
								<xsl:variable name="course" select="current-group()/parent::course" as="element()" />
								
								<xsl:element name="course">
									<xsl:attribute name="rubric" select="$course/@rubric" />
									<xsl:attribute name="number" select="$course/@number" />
									<xsl:apply-templates         select="$course/@credit-hours" />
									<xsl:if test="$course/@core-code">
										<xsl:attribute name="core-code"    select="$course/@core-code" />
									</xsl:if>
									
									<xsl:apply-templates select="$course/description" />
									<xsl:apply-templates select="current-group()" />
								</xsl:element>
							</xsl:for-each-group>
						</xsl:for-each-group>
					</xsl:element>
				</xsl:if>
			</xsl:when>
			
			<!-- process next term -->
			<xsl:otherwise>
				<xsl:variable name="term-start" select="$terms[1]/@date-start" as="xs:string" />
				<xsl:variable name="term-end"   select="$terms[1]/@date-end"   as="xs:string" />
				
				<xsl:call-template name="create-term-leftovers">
					<xsl:with-param name="terms" select="$terms[position() != 1]" />
					<xsl:with-param name="classes" select="$classes[not(utils:compare-dates-between(@start-date, $term-start, $term-end, true(), true()))]" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!--=====================================================================
		Functions
		
		These functions have use limited only to this document
		======================================================================-->
	<xsl:function name="fn:verify-terms" as="xs:boolean">
		<xsl:param name="term1" as="xs:string" />
		<xsl:param name="term2" as="xs:string" />
		
		<xsl:variable name="t1" select="lower-case(utils:strip-semester($term1))" as="xs:string" />
		<xsl:variable name="t2" select="lower-case(utils:strip-semester($term2))" as="xs:string"/>
		<xsl:variable name="term-list" select="'summer i','summer ii'" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="(compare($t1, $t2) != 0) and ($t1 = $term-list) and ($t2 = $term-list)">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>Unable to merge semesters: '</xsl:text>
					<xsl:value-of select="$term1" />
					<xsl:text>' and '</xsl:text>
					<xsl:value-of select="$term2" />
					<xsl:text>'.</xsl:text>
				</xsl:message>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	<xsl:function name="fn:clean-semester" as="xs:string">
		<xsl:param name="term" as="xs:string" />
		
		<xsl:variable name="stripped" select="lower-case(utils:strip-semester($term))" />
		
		<xsl:choose>
			<xsl:when test="$stripped = 'fall'"><xsl:value-of select="'Fall'" /></xsl:when>
			<xsl:when test="$stripped = 'spring'"><xsl:value-of select="'Spring'" /></xsl:when>
			<xsl:when test="$stripped = 'summer'"><xsl:value-of select="'Summer'" /></xsl:when>
			<xsl:when test="$stripped = 'summer i'"><xsl:value-of select="'Summer'" /></xsl:when>
			<xsl:when test="$stripped = 'summer ii'"><xsl:value-of select="'Summer'" /></xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>Unknown semester: '</xsl:text>
					<xsl:value-of select="$term" />
					<xsl:text>'.</xsl:text>
				</xsl:message>
				<xsl:value-of select="'Unknown'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- if all strings in series are identical, returns the string, otherwise returns the passed default -->
	<xsl:function name="fn:merge-identical">
		<xsl:param name="series"  as="xs:string*" />
		<xsl:param name="default" as="xs:string"  />
		
		<xsl:value-of select="fn:merge-identical($series[1], $series[position() != 1], $default)" />
	</xsl:function>
	<xsl:function name="fn:merge-identical">
		<xsl:param name="match"   as="xs:string"  />
		<xsl:param name="series"  as="xs:string*" />
		<xsl:param name="default" as="xs:string"  />
		
		<xsl:choose>
			<xsl:when test="count($series) = 0">
				<xsl:value-of select="$match" />
			</xsl:when>
			<xsl:when test="$series[1] != $match">
				<xsl:value-of select="$default" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:merge-identical($match, $series[position() != 1], $default)" />
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
	<!-- convert string-length(string) into string-length(strings*) -->
	<xsl:function name="fn:string-length">
		<xsl:param name="strings" as="xs:string*" />
		
		<xsl:for-each select="$strings">
			<xsl:value-of select="string-length(.)" />
		</xsl:for-each>
	</xsl:function>
</xsl:stylesheet>