<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
	xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
	exclude-result-prefixes="xs utils fn">
	
	
	<!--=====================================================================
		Setup
		======================================================================-->
	<xsl:include href="output-utils.xsl" />
	<xsl:include href="output-web_index-template.xsl" />
	<xsl:include href="output-web_page-template.xsl"  />
	<xsl:output
		method="xhtml"
		encoding="us-ascii"
		indent="yes"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
	
	
	<!--=====================================================================
		Parameters
		======================================================================-->
	<!-- is this an "enrolling now" schedule? -->
	<xsl:param name="enrolling-now"/>	
	
	
	<!--=====================================================================
		Globals
		======================================================================-->
	<xsl:variable name="output-type" as="xs:string" select="if ($enrolling-now = 'true') then ('web') else ('enrolling')"  />
	<xsl:variable name="ext"         as="xs:string" select="'aspx'" />
	
	
	<!--=====================================================================
		Root
		
		breaks the schedule down into manageable pieces and shuttles those
		pieces off to be processed.
		======================================================================-->
	<xsl:template match="/schedule">
		<!-- processing vars -->
		<xsl:variable name="base-dir" select="utils:generate-outdir(@year, @semester)" as="xs:string" />
		<xsl:variable name="path"     select="concat($base-dir, '_', $output-type)"    as="xs:string" />
		
		<!-- index: create schedule index -->
		<xsl:apply-templates select="." mode="index">
			<xsl:with-param name="path" select="$path" />
		</xsl:apply-templates>
		
		<!-- index: create term indices -->
		<xsl:apply-templates select="term" mode="index">
			<xsl:with-param name="path" select="$path" />
		</xsl:apply-templates>
		
		<!-- setup: terms -->
		<xsl:apply-templates select="term" mode="setup">
			<xsl:with-param name="base-dir" select="$path" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="term" mode="setup">
		<xsl:param name="base-dir" as="xs:string" />
		
		<!-- processing vars -->
		<xsl:variable name="term" select="utils:make-url(@name)"     as="xs:string" />
		<xsl:variable name="path" select="concat($path, '/', $term)" as="xs:string" />
		
		<!-- init: subjects -->
		<xsl:apply-templates select="subject[descendant::class[@is-suppressed = 'false']]" mode="init">
			<xsl:with-param name="path" select="$path" />
		</xsl:apply-templates>
		
		<!-- setup: special sections -->
		<xsl:call-template name="setup-special-sections">
			<xsl:with-param name="base-dir" select="$path" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="setup-special-sections">
		<xsl:param name="base-dir" as="xs:string" />
		
		<!-- distance learning -->
		<xsl:call-template name="init-special-section">
			<xsl:with-param name="base-dir" select="$base-dir" />
			<xsl:with-param name="title"    select="'Distance Learning'" />
			<xsl:with-param name="classes"  select="descendant::class[@is-suppressed = 'false' and @is-dl = 'true'" />
		</xsl:call-template>
		
		<!-- weekend -->
		<xsl:call-template name="init-special-section">
			<xsl:with-param name="base-dir" select="$base-dir" />
			<xsl:with-param name="title"    select="'Weekend'" />
			<xsl:with-param name="classes"  select="descendant::class[@is-suppressed = 'false' and @is-w = 'true'" />
		</xsl:call-template>
		
		<!-- weekend -->
		<xsl:call-template name="init-special-section">
			<xsl:with-param name="base-dir" select="$base-dir" />
			<xsl:with-param name="title"    select="'Weekend Core Curricullum'" />
			<xsl:with-param name="classes"  select="descendant::class[@is-suppressed = 'false' and @is-wcc = 'true'" />
		</xsl:call-template>
		
		<!-- weekend -->
		<xsl:call-template name="init-special-section">
			<xsl:with-param name="base-dir" select="$base-dir" />
			<xsl:with-param name="title"    select="'Weekend'" />
			<xsl:with-param name="classes"  select="descendant::class[@is-suppressed = 'false' and @is-w = 'true'" />
		</xsl:call-template>
	</xsl:template>
	
	<!--=====================================================================
		Init
		
		initializes result documents.
		======================================================================-->
	<xsl:template match="term" mode="init">
		<xsl:param name="base-dir" as="xs:string" />

	<xsl:template match="schedule" mode="index">
		<xsl:variable name="title" select="fn:make-title(@semester, @year)" as="xs:string" />
		<xsl:result-document href="{$outdir}/index.{$ext}">
			<xsl:call-template name="index-schedule">
				<xsl:with-param name="title" select="$title" />
			</xsl:call-template>
		</xsl:result-document>
		
		<!-- initialize terms -->
		<xsl:apply-templates select="term" mode="init">
			<xsl:with-param name="base-dir" select="$outdir" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- term.init -->
	<xsl:template match="term" mode="init">
		<xsl:param name="base-dir" as="xs:string" />
		<!-- processing vars -->
		<xsl:variable name="outdir" select="concat($base-dir, '/', utils:make-url(@semester))" as="xs:string" />
		<xsl:variable name="title"  select="fn:make-title(@semester, @year)"                   as="xs:string" />
		
		<!-- index: create term index -->
		<xsl:result-document href="{$outdir}/index.{$ext}">
			<xsl:call-template name="create-index-term">
				<xsl:with-param name="title" select="$title" />
			</xsl:call-template>
		</xsl:result-document>
		
		<!-- pages: create subject pages -->
		<xsl:apply-templates select="descendant::subject[utils:has-classes(.)]" mode="init-normal" />
		
		
		<!-- create special sections -->
		<!-- distance learning -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="base-dir"    select="$outdir" />
			<xsl:with-param name="title"       select="'Distance Learning'" />
			<xsl:with-param name="filter-type" select="'DL'" />
			<xsl:with-param name="filter-core" select="false()" />
		</xsl:call-template>

		<!-- weekend -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="base-dir"    select="$outdir" />
			<xsl:with-param name="title"       select="'Weekend'" />
			<xsl:with-param name="filter-type" select="'W'" />
			<xsl:with-param name="filter-core" select="false()" />
		</xsl:call-template>
		
		<!-- weekend core curriculum -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="base-dir"    select="$outdir" />
			<xsl:with-param name="title"       select="'Weekend Core Curriculum'" />
			<xsl:with-param name="filter-type" select="'W'" />
			<xsl:with-param name="filter-core" select="true()" />
		</xsl:call-template>
		
		<!-- create flex term sections -->
		<xsl:call-template name="create-flex-sections">
			<xsl:with-param name="base-dir"    select="$outdir" />
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="create-special-section">
		<xsl:param name="base-dir"    as="xs:string"  />
		<xsl:param name="title"       as="xs:string"  />
		<xsl:param name="filter-type" as="xs:string"  />
		<xsl:param name="filter-core" as="xs:boolean" />
		
		<!-- distance learning -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="base-dir" select="$outdir" />
			<xsl:with-param name="title"    select="'Distance Learning'" />
			<xsl:with-param name="courses"  select="descendant::type[@id = 'DL']/course[utils:has-classes(.)]" />
		</xsl:call-template>
		<!-- weekend -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="base-dir" select="$outdir" />
			<xsl:with-param name="title"   select="'Weekend'"  as="xs:string"  />
			<xsl:with-param name="courses" select="descendant::type[@id = 'W']/course[utils:has-classes(.)]" as="element()*" />
		</xsl:call-template>
		<!-- weekend core curriculum -->
		<xsl:call-template name="create-special-section">
			<xsl:with-param name="base-dir" select="$outdir" />
			<xsl:with-param name="title"   select="'Weekend Core Curriculum'"  as="xs:string"  />
			<xsl:with-param name="courses" select="descendant::type[@id = 'W']/descendant::course[@core-code and @core-code != '' and utils:has-classes(.)]" as="element()*" />
		</xsl:call-template>			
		

		<!-- flex term -->
		<xsl:call-template name="create-flex-sections">
			<xsl:with-param name="base-dir"   select="$outdir" />
			<xsl:with-param name="courses"    select="descendant::type[@id = ('FD','FN')]/course[utils:has-classes(.)]" as="element()*" />
		</xsl:call-template>
	</xsl:template>
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	<!--=====================================================================
		Functions
		
		utility functions to make the code above cleaner
		======================================================================-->
	<!-- make-title
		makes a title based on the term attributes -->
	<xsl:function name="fn:make-title" as="xs:string">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />
		
		<xsl:variable name="term-list" select="fn:make-term-list($semesters, $years)" as="xs:string" />
		<xsl:variable name="enrolling" select="if ($enrolling-now and $enrolling-now != '') then 'Enrolling Now&#8212;' else ''" as="xs:string" />
		
		<xsl:value-of select="concat($enrolling, $term-list, ' Credit')" />
	</xsl:function>
	
	<!-- make-term-list
		helper function for make-title -->
	<xsl:function name="fn:make-term-list" as="xs:string">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />
		
		<xsl:choose>
			<!-- when invalid data passed -->
			<xsl:when test="count($semesters) != count($years) or count($semesters) = 0">
				<xsl:value-of select="'Invalid Semester List'" />
			</xsl:when>
			<!-- there is only one semester -->
			<xsl:when test="count($semesters) = 1">
				<xsl:value-of select="concat($semesters[1], ' ', $years[1])" />
			</xsl:when>
			<!-- otherwise, go deeper -->
			<xsl:otherwise>
				<xsl:value-of select="fn:make-term-list($semesters, $years, 1, '')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- make-term-list
		helper for looping within make-term-list prime -->
	<xsl:function name="fn:make-term-list" as="xs:string">
		<xsl:param name="semesters" as="xs:string*" />
		<xsl:param name="years"     as="xs:string*" />
		<xsl:param name="index"     as="xs:integer" />
		<xsl:param name="string"    as="xs:string" />
		
		<xsl:choose>
			<!-- if we're done -->
			<xsl:when test="$index &gt; count($semesters)">
				<xsl:value-of select="$string" />
			</xsl:when>
			<!-- we're not dealing with summer -->
			<xsl:when test="not(contains('Summer', $semesters[$index]))">
				<xsl:variable name="string-new" select="concat(', ', $semesters[$index], ' ', $years[$index])" as="xs:string" />
				<xsl:value-of select="fn:make-term-list($semesters, $years, $index + 1, concat($string, $string-new))" />
			</xsl:when>
			<!-- we're dealing with summer, but it is the first one in the given year -->
			<xsl:when test="not(contains($string, concat('Summer ', $years[$index])))">
				<xsl:variable name="string-new" select="concat(', Summer ', $years[$index])" as="xs:string" />
				<xsl:value-of select="fn:make-term-list($semesters, $years, $index + 1, concat($string, $string-new))" />
			</xsl:when>
			<!-- we're dealing with summer, and it is NOT the first one in the given year -->
			<xsl:otherwise>
				<xsl:value-of select="fn:make-term-list($semesters, $years, $index + 1, $string)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- start-month
		returns the numeric month of the passed date string --> 
	<xsl:function name="fn:start-month">
		<xsl:param name="date" as="xs:string" />
		
		<xsl:value-of select="substring-before($date, '/')" />
	</xsl:function>
	
	<!-- str-month
		returns the text name of a month for the given integer -->
	<xsl:function name="fn:str-month" as="xs:string">
		<xsl:param name="month" as="xs:integer" />
		
		<xsl:variable name="month-names" select="'January','February','March','April','May','June','July','Augutst','September','October','November','December'" as="xs:string*" />
		
		<xsl:choose>
			<xsl:when test="$month &lt; 1 or $month &gt; 12">
				<xsl:message>
					<xsl:text>!Warning! Cannot convert '</xsl:text>
					<xsl:value-of select="$month" />
					<xsl:text>' to a month name.</xsl:text>
				</xsl:message>
				<xsl:value-of select="''" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$month-names[$month - 1]" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
</xsl:stylesheet>