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
		href="xml-utils.xsl" />
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
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<!-- check for presence of second file -->
	<xsl:variable name="doc-schedule" select="if (utils:check-file($second-schedule)) then doc(replace($second-schedule, '\\', '/'))/schedule else ''" />
	<xsl:variable name="doc-mappings" select="if (utils:check-file($path-mappings)) then doc(replace($path-mappings, '\\', '/'))/mappings else ''" />
	<xsl:variable name="doc-sortkeys" select="if (utils:check-file($path-sortkeys)) then doc(replace($path-sortkeys, '\\', '/'))/sortkeys else ''" />
	
	<!--=====================================================================
		Begin Transformation
		
		Note: if there is more than one input file, the creation datetime
		will reflect the creation of the oldest input file.
		======================================================================-->
	<xsl:template match="/schedule">
		<xsl:choose>
			<xsl:when test="$doc-mappings != '' and $doc-sortkeys != ''">
				<xsl:element name="schedule">
					<xsl:choose>
						<!-- if we are merging two documents -->
						<xsl:when test="$doc-schedule != ''">
							<!-- make sure creation datetime is accurate -->
							<xsl:call-template name="set-creation-datetime">
								<xsl:with-param name="date1" select="@date-created" />
								<xsl:with-param name="time1" select="@time-created" />
								<xsl:with-param name="date2" select="$doc-schedule/@date-created" />
								<xsl:with-param name="time2" select="$doc-schedule/@time-created" />
							</xsl:call-template>
							
							<!-- two docs means summer, so one term will need to be split -->
							<xsl:call-template name="break-terms">
								<xsl:with-param name="t1" select="term"        as="element()*" />
								<xsl:with-param name="t2" select="$doc-schedule//term" as="element()*" />
							</xsl:call-template>
						</xsl:when>
						
						<!-- if we are NOT merging two documents, do it the easy way -->
						<xsl:otherwise>
							<xsl:attribute name="semester"      select="fn:clean-semester(term/@name)"         />
							<xsl:attribute name="year"          select="term/@year"                            />
							<xsl:attribute name="creation-date" select="utils:convert-date-std(@date-created)" />
							<xsl:attribute name="creation-time" select="utils:convert-time-std(@time-created)" />

							
							<xsl:apply-templates select="term" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>Unable to load: </xsl:text>
					<xsl:value-of select="if($doc-mappings = '') then $path-mappings else ''" />
					<xsl:value-of select="if($doc-sortkeys = '') then $path-sortkeys else ''" />
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	<!--=====================================================================
		Regular Templates
		======================================================================-->
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:attribute name="name"       select="utils:strip-semester(@name)"         />
			<xsl:attribute name="date-start" select="utils:convert-date-std(@start-date)" />
			<xsl:attribute name="date-end"   select="utils:convert-date-std(@end-date)"   />
			
			<xsl:apply-templates select="location[@name = 200]//course" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="course">
		<xsl:element name="course">
			<xsl:attribute name="rubric"       select="@rubric" />
			<xsl:attribute name="number"       select="@number" />
			<xsl:apply-templates select="@credit-hours" />
			<xsl:if test="@core-code"><xsl:attribute name="core-code"    select="@core-code" /></xsl:if>
			<xsl:attribute name="title-short"  select="@title" />
			<xsl:attribute name="title-long"   select="@long-title" />
			
			<xsl:apply-templates select="description" />
			<xsl:apply-templates select="class" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="course/@credit-hours">
		<xsl:attribute name="credit-hours" select="replace(., '.00', '')" />
	</xsl:template>
	
	<xsl:template match="class">
		<xsl:element name="class">
			<xsl:attribute name="synonym" select="@synonym" />
			<xsl:attribute name="section" select="@section" />
			<xsl:attribute name="date-start" select="utils:convert-date-std(@start-date)" />
			<xsl:attribute name="date-end" select="utils:convert-date-std(@end-date)" />
			<xsl:attribute name="schedule-type" select="@schedule-type" />
			<xsl:attribute name="topic-code" select="@topic-code" />
			<xsl:attribute name="weeks" select="@weeks" />
			<xsl:attribute name="capacity" select="@capacity" />
			<!-- these attributes from the dtd seem mildly useful, but don't actually exist in the data
			<xsl:attribute name="seats-available" select="@seats-available" />
			<xsl:attribute name="tuition" select="@tuition" /> -->
			<!-- this one seems like it may be useful, but I'm not sure how yet
			<xsl:attribute name="online-primary" select="@online-primary-class" /> -->
			
			<!-- these are some artificial attributes that I'm going to put in the data, 
				since they are an integral part of how the output is produced. Maybe not
				the perfect solution, but it makes my life easier -->
			<xsl:attribute name="is-suppressed" select="@topic-code = ('XX','YY','ZZ') or not(meeting)" />
			<xsl:attribute name="is-dl" select="@schedule-type = 'DL'" />
			<xsl:attribute name="is-w" select="@schedule-type = 'W'" />
			<xsl:attribute name="is-wcc" select="@schedule-type = 'W' and ancestor::course/@core-code and ancestor::course/@core-code != ''" />
			<xsl:attribute name="is-flex" select="@schedule-type = ('FD','FN')" />
			<xsl:if test="@schedule-type = ('FD','FN')">
				<xsl:attribute name="flex-month" select="utils:month-name(tokenize(utils:convert-date-std(@start-date), '/')[1])" />
			</xsl:if>
			
			<!-- figure out where it should be in the division structure -->
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
			
			
			<xsl:apply-templates select="description" />
			<xsl:apply-templates select="meeting" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="meeting">
		<xsl:element name="meeting">
			<xsl:attribute name="method" select="@method" />
			<xsl:attribute name="days" select="@days" />
			<xsl:attribute name="bldg" select="@building" />
			<xsl:attribute name="room" select="@room" />
			<xsl:attribute name="time-start" select="utils:convert-time-std(@start-time)" />
			<xsl:attribute name="time-end" select="utils:convert-time-std(@end-time)" />
			
			<!-- insert sortkeys -->
			<!-- write sortkey-days -->
			<xsl:variable name="days" select="@days" />
			<xsl:attribute name="sortkey-days" select="index-of($doc-sortkeys/sortkey[@type = 'days']/days/@id, $days)" />
			
			<!-- write sortkey-times -->
			<xsl:attribute name="sortkey-times" select="utils:convert-time-ord(@start-time)" />
			
			<!-- write sortkey-method -->
			<xsl:variable name="method" select="@method" />
			<xsl:attribute name="sortkey-method" select="index-of($doc-sortkeys/sortkey[@type = 'method']/method/@id, $method)" />
			
			<xsl:apply-templates select="faculty" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="faculty">
		<xsl:element name="faculty">
			<xsl:attribute name="name-first"  select="@first-name"  />
			<xsl:attribute name="name-middle" select="@middle-name" />
			<xsl:attribute name="name-last"   select="@last-name"   />
			<xsl:attribute name="email"       select="@email"       />
			<xsl:attribute name="phone"       select="@phone"       />
		</xsl:element>
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
			</xsl:when>
			<!-- multiple matches -->
			<xsl:when test="count($match-node) &gt; 1">
				<!-- first choose highest priority(s), then longest lengths (most precise, roughly) -->
				<xsl:variable name="temp-node" select="$match-node[@priority = max($match-node/@priority)]" as="element()*" />
				<xsl:variable name="max-node"  select="$temp-node[string-length(@match) = max(fn:string-length($temp-node/@match))]" as="element()*" />				<xsl:choose>
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
		Restructuring Templates
		
		These templates do some heavy-duty work, but pass control back to the
		above templates once complete
		======================================================================-->
	<xsl:template name="break-terms">
		<xsl:param name="t1" as="element()*" />
		<xsl:param name="t2" as="element()*" />
		
		<!-- verify that the terms are valid -->
		<xsl:choose>
			<!-- when NOT valid: throw error and quit -->
			<xsl:when test="count($t1) != 1 or count($t2) != 1 or not(fn:verify-terms($t1/@name, $t2/@name))">
				<xsl:message>
					<xsl:text>!Error! Unable to merge terms '</xsl:text>
					<xsl:value-of select="$t1/@name" />
					<xsl:text>' with terms '</xsl:text>
					<xsl:value-of select="$t2/@name" />
					<xsl:text>'.</xsl:text>
				</xsl:message>
			</xsl:when>
			<!-- when valid: process -->
			<xsl:otherwise>
				<!-- load the dates for breaking the terms -->
				<xsl:variable name="year" select="$t1/@year" />
				<xsl:variable name="sem"  select="fn:clean-semester($t2/@name)" />
				<xsl:variable name="file" select="concat('../mappings/', $year, '-', $sem, '/base.xml')" as="xs:string" />
				
				<xsl:if test="utils:check-file($file)">
					<xsl:variable name="term-list" select="document($file)//term" as="element()*" />
					
					<xsl:for-each select="$term-list">
						<xsl:sort select="utils:convert-date-ord(@date-start)" data-type="number" />

						<xsl:apply-templates select="$t1 | $t2" mode="break">
							<xsl:with-param name="semester"   select="@semester"   />
							<xsl:with-param name="year"       select="@year"       />
							<xsl:with-param name="date-start" select="@date-start" tunnel="yes" />
							<xsl:with-param name="date-end"   select="@date-end"   tunnel="yes" />
						</xsl:apply-templates>
					</xsl:for-each>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="term" mode="break">
		<xsl:param name="semester"   as="xs:string" />
		<xsl:param name="year"       as="xs:string" />
		<xsl:param name="date-start" as="xs:string" tunnel="yes" />
		<xsl:param name="date-end"   as="xs:string" tunnel="yes" />
		
		<!-- if the term is empty, don't create an element for it -->
		<xsl:if test="location[@name = 200]//course[class[utils:compare-dates(@start-date, $date-start) != -1 and utils:compare-dates(@end-date, $date-end) != 1]]">
			
			<xsl:element name="term">
				<xsl:attribute name="semester"   select="$semester"   />
				<xsl:attribute name="year"       select="$year"       />
				<xsl:attribute name="date-start" select="$date-start" />
				<xsl:attribute name="date-end"   select="$date-end"   />
				
				<xsl:apply-templates 
					select="location[@name = 200]//course[class[utils:compare-dates(@start-date, $date-start) != -1 and utils:compare-dates(@end-date, $date-end) != 1]]"
					mode="break" />
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="course" mode="break">
		<xsl:param name="date-start" as="xs:string" tunnel="yes" />
		<xsl:param name="date-end"   as="xs:string" tunnel="yes" />
		
		<xsl:element name="course">
			<xsl:attribute name="rubric"       select="@rubric" />
			<xsl:attribute name="number"       select="@number" />
			<xsl:attribute name="credit-hours" select="@credit-hours" />
			<xsl:if test="@core-code"><xsl:attribute name="core-code"    select="@core-code" /></xsl:if>
			<xsl:attribute name="title-short"  select="@title" />
			<xsl:attribute name="title-long"   select="@long-title" />
			
			<xsl:apply-templates select="description" />
			<xsl:apply-templates select="class[utils:compare-dates(@start-date, $date-start) != -1 and utils:compare-dates(@end-date, $date-end) != 1]" />
		</xsl:element>
	</xsl:template>
	
	
	<!--=====================================================================
		Utility Templates
		
		These templates are here to clean up the code above
		======================================================================-->
	<xsl:template name="set-creation-datetime">
		<xsl:param name="date1" as="xs:string"/>
		<xsl:param name="time1" as="xs:string" />
		<xsl:param name="date2" as="xs:string" />
		<xsl:param name="time2" as="xs:string" />
		
		<!-- we would hope that these are produced on the same day, but they may not be -->
		<xsl:choose>
			<!-- if they are, we're golden. Just proceed. -->
			<xsl:when test="compare($date1, $date2) = 0">
				<xsl:attribute name="creation-date" select="$date1" />
				<xsl:attribute name="creation-time" select="utils:select-time-oldest($time1, $time2)" />
			</xsl:when>
			
			<!-- otherwise, find the older of the two -->
			<xsl:otherwise>
				<xsl:variable name="oldest-date" select="utils:select-date-oldest($date1, $date2)" as="xs:string" />
				<xsl:variable name="oldest-time" select="if (compare($oldest-date, $date1) = 0) then $time1 else $time2" />
				
				<!-- display warning to user, but continue transformation -->
				<xsl:message>
					<xsl:text>!Warning! documents not produced on the same day:
</xsl:text>
					<xsl:text>S1 (</xsl:text>
					<xsl:value-of select="$date1" /><xsl:text> @ </xsl:text><xsl:value-of select="$time1" />
					<xsl:text>)
</xsl:text>
					<xsl:text>S2 (</xsl:text>
					<xsl:value-of select="$date2" /><xsl:text> @ </xsl:text><xsl:value-of select="$time2" />
					<xsl:text>)</xsl:text>
				</xsl:message>
				
				<xsl:attribute name="creation-date" select="$oldest-date" />
				<xsl:attribute name="creation-time" select="$oldest-time" />
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
	
	<!-- convert string-length(string) into string-length(strings*) -->
	<xsl:function name="fn:string-length">
		<xsl:param name="strings" as="xs:string*" />
		
		<xsl:for-each select="$strings">
			<xsl:value-of select="string-length(.)" />
		</xsl:for-each>
	</xsl:function>
	
</xsl:stylesheet>