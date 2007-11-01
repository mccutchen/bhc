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
	<xsl:include href="xml-utils.xsl"/>
	<!-- output -->
	<xsl:output method="xml" encoding="iso-8859-1" indent="yes"
		exclude-result-prefixes="xs utils fn" doctype-system="../dtds/xml-formed.dtd"/>


	<!--=====================================================================
		Parameters
		======================================================================-->
	<!-- sorting and heirarchy info -->
	<xsl:param name="path-sortkeys"/>
	<xsl:param name="path-mappings"/>


	<!--=====================================================================
		Globals
		======================================================================-->
	<!-- check for presence of mapping and sorting info -->
	<xsl:variable name="doc-mappings"
		select="if (utils:check-file($path-mappings)) then doc(replace($path-mappings, '\\', '/'))/mappings else ''"/>
	<xsl:variable name="doc-sortkeys"
		select="if (utils:check-file($path-sortkeys)) then doc(replace($path-sortkeys, '\\', '/'))/sortkeys else ''"/>


	<!--=====================================================================
		Begin Transformation
		
		Creates Division, Subject, Topic, Subtopic, and Type elements
		======================================================================-->
	<xsl:template match="/schedule">
		<xsl:element name="schedule">
			<xsl:copy-of select="attribute()" />
			
			<xsl:apply-templates select="term" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="term">
		<xsl:element name="term">
			<xsl:copy-of select="attribute()" />
			
			<xsl:for-each-group select="descendant::class" group-by="@name-of-division">
				<xsl:variable name="node" select="$doc-mappings//division[@name = current-grouping-key()]" />
				<xsl:if test="count($node) != 1">
					<xsl:call-template name="print-error">
						<xsl:with-param name="text" select="$node/@name" />
					</xsl:call-template>
				</xsl:if>
				
				<xsl:call-template name="create-division">
					<xsl:with-param name="classes" select="current-group()" />
					<xsl:with-param name="division" select="$node" />
				</xsl:call-template>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="create-division">
		<xsl:param name="classes"  as="element()*" />
		<xsl:param name="division" as="element()"  />
		
		<xsl:element name="division">
			<xsl:copy-of select="$division/attribute()" />
			<xsl:copy-of select="$division/contact"     />
			
			<xsl:for-each-group select="$classes" group-by="@name-of-subject">
				<xsl:variable name="node" select="$division/subject[@name = current-grouping-key()]" />
				<xsl:if test="count($node) != 1">
					<xsl:call-template name="print-error">
						<xsl:with-param name="text" select="$node/@name" />
						<xsl:with-param name="match" select="current-grouping-key()" />
						<xsl:with-param name="level" select="'subject'" />
					</xsl:call-template>
				</xsl:if>
				
				<xsl:call-template name="create-subject">
					<xsl:with-param name="classes" select="current-group()" />
					<xsl:with-param name="subject" select="$node" />
				</xsl:call-template>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="create-subject">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="subject" as="element()"  />
		
		<xsl:element name="subject">
			<xsl:copy-of select="$subject/attribute()" />
			<xsl:copy-of select="$subject/contact"     />
			<xsl:copy-of select="$subject/comments"    />
			
			<!-- split off the classese w/o a topic -->
			<xsl:variable name="classes-type"  select="$classes[not(@name-of-topic)]" as="element()*" />
			<xsl:variable name="classes-topic" select="$classes[@name-of-topic]" as="element()*"      />
			
			<!-- types -->
			<xsl:call-template name="create-types">
				<xsl:with-param name="classes" select="$classes-type" />
			</xsl:call-template>
			
			<!-- topics -->
			<xsl:for-each-group select="$classes" group-by="@name-of-topic">
				<xsl:variable name="node" select="$subject/topic[@name = current-grouping-key()]" />
				<xsl:if test="count($node) != 1">
					<xsl:call-template name="print-error">
						<xsl:with-param name="text" select="$node/@name" />
						<xsl:with-param name="match" select="current-grouping-key()" />
						<xsl:with-param name="level" select="'topic'" />
					</xsl:call-template>
				</xsl:if>
				
				<xsl:call-template name="create-topic">
					<xsl:with-param name="classes" select="current-group()" />
					<xsl:with-param name="topic"   select="$node" />
				</xsl:call-template>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>

	<xsl:template name="create-topic">
		<xsl:param name="classes" as="element()*" />
		<xsl:param name="topic"   as="element()"  />
		
		<xsl:element name="topic">
			<xsl:copy-of select="$topic/attribute()" />
			<xsl:copy-of select="$topic/comments"    />
			
			<!-- split off the classese w/o a topic -->
			<xsl:variable name="classes-type"     select="$classes[not(@name-of-subtopic)]" as="element()*" />
			<xsl:variable name="classes-subtopic" select="$classes[@name-of-subtopic]"      as="element()*" />
			
			<!-- types -->
			<xsl:call-template name="create-types">
				<xsl:with-param name="classes" select="$classes-type" />
			</xsl:call-template>
			
			<!-- subtopics -->
			<xsl:for-each-group select="$classes" group-by="@name-of-subtopic">
				<xsl:variable name="node" select="$topic/subtopic[@name = current-grouping-key()]" />
				<xsl:if test="count($node) != 1">
					<xsl:call-template name="print-error">
						<xsl:with-param name="text" select="$node/@name" />
						<xsl:with-param name="match" select="current-grouping-key()" />
						<xsl:with-param name="level" select="'suptopic'" />
					</xsl:call-template>
				</xsl:if>
				
				<xsl:call-template name="create-subtopic">
					<xsl:with-param name="classes" select="current-group()" />
					<xsl:with-param name="subtopic"   select="$node" />
				</xsl:call-template>
			</xsl:for-each-group>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="create-subtopic">
		<xsl:param name="classes"  as="element()*" />
		<xsl:param name="subtopic" as="element()"  />
		
		<xsl:element name="subtopic">
			<xsl:copy-of select="$subtopic/attribute()" />
			<xsl:copy-of select="$subtopic/comments"    />
			
			<!-- types only -->
			<xsl:call-template name="create-types">
				<xsl:with-param name="classes" select="$classes" />
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="create-types">
		<xsl:param name="classes" as="element()*"/>

		<xsl:for-each-group select="$classes" group-by="@schedule-type">
			<xsl:variable name="type" select="$doc-sortkeys//type[@id = current-grouping-key()]" />
			
			<xsl:choose>
				<!-- error -->
				<xsl:when test="(count($type) &gt; 1) or (count($type) = 0 and current-grouping-key() != '')">
					<xsl:call-template name="print-error">
						<xsl:with-param name="text"  select="$type/@id" />
						<xsl:with-param name="match" select="current-grouping-key()" />
						<xsl:with-param name="level" select="'type'" />
					</xsl:call-template>
				</xsl:when>
				<!-- no type -->
				<xsl:when test="count($type) = 0">
					<xsl:element name="type">
						<xsl:attribute name="id"      select="''" />
						<xsl:attribute name="name"    select="'none'" />
						<xsl:attribute name="sortkey" select="0" />
						
						<xsl:call-template name="create-courses">
							<xsl:with-param name="classes" select="current-group()" />
						</xsl:call-template>
					</xsl:element>
				</xsl:when>
				<!-- norm -->
				<xsl:otherwise>
					<xsl:element name="type">
						<xsl:copy-of select="$type/attribute()" />
						<xsl:attribute name="sortkey" select="index-of($doc-sortkeys//type/@id, current-grouping-key())" />
						
						<xsl:call-template name="create-courses">
							<xsl:with-param name="classes" select="current-group()" />
						</xsl:call-template>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template name="create-courses">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each-group select="$classes" group-by="parent::course/@rubric">
			<xsl:sort select="parent::course/@rubric"/>
			
			<xsl:for-each-group select="current-group()" group-by="parent::course/@number">
				<xsl:sort select="parent::course/@number"/>
				
				<!-- note: if a course has classes that fall into multiple terms, the current-group()
					may have multpiple matches for parent::course - but all matches are identical, so
					just use one -->
				<xsl:variable name="course" select="current-group()/parent::course" as="element()*" />
				
				<xsl:element name="course">
					<xsl:copy-of select="$course[1]/attribute()" />
					<xsl:copy-of select="$course[1]/comments" />
					
					<xsl:call-template name="create-classes">
						<xsl:with-param name="classes" select="current-group()" />
					</xsl:call-template>
				</xsl:element>
			</xsl:for-each-group>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template name="create-classes">
		<xsl:param name="classes" as="element()*" />
		
		<xsl:for-each select="$classes">
			<xsl:element name="class">
				<xsl:copy-of select="@synonym|@section|@date-start|@date-end|@schedule-type|@topic-code|@weeks|@capacity"/>
				<xsl:copy-of select="@sortkey-days|@sortkey-times|@sortkey-method" />
				<xsl:copy-of select="@is-suppressed|@is-dl|@is-w|@is-wcc|@is-flex|@sortkey"/>
				
				<xsl:copy-of select="comments" />
				<xsl:copy-of select="meeting"  />
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="print-error">
		<xsl:param name="text" as="xs:string*" />
		<xsl:param name="match" as="xs:string" />
		<xsl:param name="level" as="xs:string" />
		
		<xsl:message>
			<xsl:text>!Error! </xsl:text>
			<xsl:if test="count($text) &gt; 1">
			<xsl:text>Unable to resolve multiple match nodes for </xsl:text>
				<xsl:value-of select="$level" />
				<xsl:text>(</xsl:text>
				<xsl:value-of select="if ($match = '') then '-none-' else $match" />
			<xsl:text>):
'</xsl:text>
				<xsl:for-each select="$text">
					<xsl:value-of select="." />
					<xsl:if test="position() != last()">
						<xsl:value-of select="' '" />
					</xsl:if>
				</xsl:for-each>
				<xsl:text>'.</xsl:text>
			</xsl:if>
			<xsl:if test="count($text) &lt; 1">
				<xsl:text>Unable to match any nodes for </xsl:text>
				<xsl:value-of select="$level" />
				<xsl:text>(</xsl:text>
				<xsl:value-of select="if ($match = '') then '-none-' else $match" />
				<xsl:text>).</xsl:text>
			</xsl:if>
		</xsl:message>
	</xsl:template>

</xsl:stylesheet>
