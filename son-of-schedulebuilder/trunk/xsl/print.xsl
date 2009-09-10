<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    xmlns:fn="http://www.brookhavencollege.edu/xml/fn"
    exclude-result-prefixes="xs utils fn">

    <!-- $Id$

         The print output transformer.  This XSLT file generates a set
         of plain text files embedded with Quark XPress Tags.  The
         text files can be imported into Quark XPress, which should
         correctly style the imported text based on the XPress Tags
         therein. -->

    <!-- XPress Tagged Text files should be plain text, ASCII-encoded.
         Any non-ASCII characters must be specially escaped. -->
    <xsl:output
        method="text"
        encoding="us-ascii" />

    <!-- Strip any extra whitespace around elements. -->
    <xsl:strip-space elements="*" />

    <!-- Include utility functions -->
    <xsl:include href="utils.xsl" />

    <!-- for CIT self-paced course mods -->
    <xsl:variable name="CIT_subjects" select="('Computer Information Technology',
        'Computer Science',
        'Computer Studies - Business Computer Information Systems')" />
    
    <!-- =============================================================
         Parameters
         =============================================================

         $output-directory is the name of the directory in which the
         output will be stored.

         $output-extension is file extension the output text files
         should have.  Must start with a period.  This used to be
         ".xtg", but somewhere between version 4 and version 6, Quark
         XPress started to recognize ".txt" files as possibly
         containing Tagged Text.

         $target-platform is the name of the platform/OS that will be
         used to process the output files.  Must be one of "mac", "pc"
         or "unix".  This controls the line-endings used by the "br"
         named template. -->
    <xsl:param name="output-directory">print-output</xsl:param>
    <xsl:param name="output-extension">.txt</xsl:param>
    <xsl:param name="target-platform">mac</xsl:param>

    <!-- OUTPUT PARAMETERS
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -format:
        Determines whether output is formatted for QuarkXpress or InDesign.
         - QuarkXpress: 'quark'
         - InDesign:    'indesign'
        Defaults to QuarkXpress.
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <xsl:param name="format" as="xs:string" select="'quark'" />
    
    
    <!-- =============================================================
         Output document initialization
         =============================================================

         These templates follow this idiom for creating output
         documents:

         1. For each element that will have an output document, create
         a template which matches that element and has a mode of
         "init".  In this template, create an <xsl:result-document>
         element with the proper @href to create the document.  Inside
         the <xsl:result-document>, apply templates to the current
         element, but without the @mode="init" attribute.

         2. In the root-matching template, apply templates to each of
         the elements that should have result documents, with
         @mode="init".

         3. Create another template which matches each element that
         will have an output document, but do not give it a mode.  In
         this template, generate the actual content for the result
         document.  This template will get applied inside each of the
         <xsl:result-document> templates from #1, above. -->

    <xsl:template match="/schedule">
        <!-- check params -->
        <xsl:choose>
            <xsl:when test="lower-case($format) = 'quark' or lower-case($format) = 'indesign'">
                <xsl:apply-templates select="term | term/division/subject | term/special-section" mode="init" />           </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>You must choose either 'quark' or 'indesign' as the output format.</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="term" mode="init">
        <xsl:result-document href="{$output-directory}/{@machine_name}{$output-extension}">
            <!-- preamble -->
            <xsl:value-of select="fn:preamble()" />
            
            <xsl:apply-templates select="." />
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="subject" mode="init">
        <xsl:result-document href="{$output-directory}/{ancestor::term/@machine_name}/{ancestor::division/@machine_name}/{@machine_name}{$output-extension}">
            <!-- preamble -->
            <xsl:value-of select="fn:preamble()" />
            
            <xsl:apply-templates select="." />
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="special-section" mode="init">
        <xsl:result-document href="{$output-directory}/{ancestor::term/@machine_name}/{@machine_name}{$output-extension}">
            <!-- preamble -->
            <xsl:value-of select="fn:preamble()" />
            
            <xsl:apply-templates select="." />
        </xsl:result-document>
    </xsl:template>


    <!-- =============================================================
         Output content templates
         =============================================================

         The rest of the templates in this XSLT file are responsible
         for actually creating the content for the result documents
         that were created by the above templates. -->

    <xsl:template match="term">
        <!-- only output the term header if there is more than one term -->
        <xsl:if test="count(/schedule/term) &gt; 1">
            <xsl:value-of select="fn:p-tag('Term Header')" /><xsl:value-of select="@name" /><xsl:value-of select="fn:newline()" />
            <xsl:value-of select="fn:p-tag('Term Dates')" /><xsl:value-of select="@dates" /><xsl:value-of select="fn:newline()" />
        </xsl:if>

        <!-- first, output everything that's not in the School of the Arts or Students 50+ Education -->
        <xsl:apply-templates select="division[@name != 'School of the Arts' and @name != 'Students 50+ Education Office']/subject | special-section">
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- let it breathe! -->
        <xsl:value-of select="fn:br(4)" />
        
        <!-- output School of the Arts -->
        <xsl:apply-templates select="division[@name = 'School of the Arts']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- let it breathe! -->
        <xsl:value-of select="fn:br(4)" />
        
        <!-- output the Senior Adult courses -->
        <xsl:apply-templates select="division[@name = 'Students 50+ Education Office']/subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="special-section">
        <xsl:value-of select="fn:p-tag('Subject Header')" /><xsl:apply-templates select="." mode="subject-header" />
        <xsl:apply-templates select="." mode="insert-header-text" />
        <xsl:value-of select="fn:br()" />
        
        <xsl:apply-templates select="subject | minimester">
            <xsl:sort select="@sortkey" />
            <xsl:sort select="@name" />
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template mode="subject-header" match="special-section[@name = 'Weekend Core Curriculum']">
        <xsl:text>YOU CAN COMPLETE YOUR CORE CURRICULUM ON WEEKENDS!</xsl:text><xsl:value-of select="fn:newline()" />
    </xsl:template>
    <xsl:template mode="subject-header" match="special-section">
        <xsl:value-of select="upper-case(@name)" /><xsl:text> COURSES</xsl:text><xsl:value-of select="fn:newline()" />
    </xsl:template>
    
    <xsl:template mode="insert-header-text" match="special-section[@name = 'Distance Learning']">
        <xsl:value-of select="fn:p-tag('SubjectHeaderLargeComment')" /><xsl:text>For course annotations, turn to the alphabetical listing of the course in this publication, or contact the instructional division office.</xsl:text><xsl:value-of select="fn:newline()" /> 
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:text>Distance learning courses provide instruction to students who are not at the same location as the instructors and can use various forms of technology - television, computer, telephone and the Internet.  Students must meet prerequisites or assessment scores where applicable.  Dallas County Community College District distance learning courses will transfer to other institutions.  Students who plan to transfer should consult the catalog of that institution and work with an advisor in planning their academic programs.  Campus-based distance courses are offered by all seven colleges of the Dallas County Community College District and may include some on-site instruction.</xsl:text><xsl:value-of select="fn:newline()" />   
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:value-of select="fn:c-tag('SubjectHeaderSmallCommentBold','Online, OL')" /><xsl:text> - All content is delivered through computers and multimedia.  These courses use eCampus and may include CDs and audio/video streaming or publisher video cartridge.  No on-campus testing or activities are required; however, off-campus proctored exams may be required.</xsl:text><xsl:value-of select="fn:newline()" />
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:value-of select="fn:c-tag('SubjectHeaderSmallCommentBold','Online Partial, OLP')" /><xsl:text> - Most of the content is delivered through computers and multimedia. These courses use eCampus and may include CDs and audio/video streaming.  On-campus testing, orientation, and/or other activities may be required.</xsl:text><xsl:value-of select="fn:newline()" />
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:value-of select="fn:c-tag('SubjectHeaderSmallCommentBold','Online/Classroom, OLC')" /><xsl:text> - Content delivered through an even distribution (50 percent-50 percent) of online and classroom activities.  These courses use components of computer instruction, multimedia activities, and classroom time.  On-Campus classroom time is required.</xsl:text><xsl:value-of select="fn:newline()" />
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:value-of select="fn:c-tag('SubjectHeaderSmallCommentBold','Video-Based, VB')" /><xsl:text> - Content delivered through a local cable channel, CD, DVD, MP4 system, or VHS cassette.  On-campus testing or activities may be required.  Content is not delivered through computer Internet activities, but instructor may provide some communications, syllabus, orientation and test review by e-mail.</xsl:text><xsl:value-of select="fn:newline()" /> 
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:text>If you have any questions about Distance Learning course formats, please call the division office for that course.</xsl:text><xsl:value-of select="fn:newline()" />
        <xsl:value-of select="fn:p-tag('SubjectHeaderSmallComment')" /><xsl:text>For further information concerning distance learning, please contact Sam Govea at 972-860-4216 or e-mail </xsl:text><xsl:value-of select="fn:c-tag('website', 'sGovea@dcccd.edu')" /><xsl:text>.</xsl:text><xsl:value-of select="fn:newline()" />
    </xsl:template>
    <xsl:template mode="insert-header-text" match="special-section[@name = 'Flex Term']">
        <xsl:value-of select="fn:p-tag('SubjectHeaderLargeComment')" /><xsl:text>Previously called minimesters, the following classes meet for less than 15 weeks and are listed by the month in which they begin.</xsl:text><xsl:value-of select="fn:newline()" /> 
    </xsl:template>
    <xsl:template mode="insert-header-text" match="special-section[@name = 'Learning Community']">
        <xsl:value-of select="fn:p-tag('SubjectHeaderLargeComment')" /><xsl:text>Learning communities are linked courses that students take together.  Ask your advisor if one of these communities fits into your academic plan!  Students who participate in learning communities have shown a higher success rate than those who take stand-alone courses.  See ads in the front and back sections of this schedule for paired courses and more information.</xsl:text><xsl:value-of select="fn:newline()" />
    </xsl:template>
    <xsl:template mode="insert-header-text" match="special-section[@name = 'Weekend']">
        <xsl:value-of select="fn:p-tag('SubjectHeaderLargeComment')" /><xsl:text>Weekend courses meet on Friday, Saturday and Sunday, Saturday only, Sunday only and Saturday and Sunday.  For assistance in planning your degree plan to fit a weekend schedule, please see an academic advisor.</xsl:text><xsl:value-of select="fn:newline()" />
    </xsl:template>
    <xsl:template mode="insert-header-text" match="special-section[@name = 'Weekend Core Curriculum']">
        <xsl:value-of select="fn:p-tag('SubjectHeaderLargeComment')" /><xsl:text>For assistance in planning your degree plan to fit a weekend schedule, please see an academic advisor.</xsl:text><xsl:value-of select="fn:newline()" /> 
    </xsl:template>
    <xsl:template mode="insert-header-text" match="special-section">
    </xsl:template>
    
    <xsl:template match="minimester">
        <xsl:value-of select="fn:p-tag('Minimester Header')" /><xsl:value-of select="upper-case(@name)" /><xsl:value-of select="fn:newline()" />
        <xsl:apply-templates select="subject">
            <xsl:sort select="@name" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="subject">
        <xsl:apply-templates select="@name" />

        <!-- print the division information -->
        <xsl:call-template name="division-info" />

        <xsl:apply-templates select="comments" />

        <!-- insert a list of the Core courses -->
        <xsl:call-template name="make-core-list" />

        <!-- if this is the Senior Adults subject, manually add a 'credit courses'
             topic header -->
        <xsl:if test="@name = 'Students 50+ Education Program'">
            <xsl:value-of select="fn:p-tag('Topic Header')" />
            <xsl:text>CREDIT COURSES</xsl:text>
            <xsl:value-of select="fn:newline()" />
        </xsl:if>

        <!-- Output any stand-alone types before topics or subtopics.  This allows some
             special regroupings to have courses that aren't in a subgroup (topic, etc.)
             and courses that are in a subgroup.  See, e.g. EMS courses. -->
        <xsl:apply-templates select="type">
            <xsl:sort select="@sortkey" data-type="number" />
        </xsl:apply-templates>

        <xsl:apply-templates select="topic">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- this will print out any courses in a <special-subject> -->
        <xsl:apply-templates select="group | course">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@default-sortkey" />
            <xsl:sort select="min(descendant::class/@section)" />
        </xsl:apply-templates>

        <!-- each subject section should be followed by three blank lines -->
        <xsl:value-of select="fn:br(3)" />
    </xsl:template>


    <xsl:template match="topic">
        <xsl:apply-templates select="@name" />
        <xsl:apply-templates select="comments" />

        <!-- output any stand-alone types before topics or subtopics -->
        <xsl:apply-templates select="type">
            <xsl:sort select="@sortkey" data-type="number" />
        </xsl:apply-templates>

        <xsl:apply-templates select="subtopic">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@name" />
        </xsl:apply-templates>

        <!-- this will print out any courses in a <special-subject> -->
        <xsl:apply-templates select="group | course">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@default-sortkey" />
            <xsl:sort select="min(descendant::class/@section)" />
        </xsl:apply-templates>

        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:br()" />
            
        </xsl:if>
    </xsl:template>


    <xsl:template match="subtopic">
        <xsl:apply-templates select="@name" />
        <xsl:apply-templates select="comments" />

        <xsl:apply-templates select="type">
            <xsl:sort select="@sortkey" data-type="number" />
        </xsl:apply-templates>

        <!-- this will print out any courses in a <special-subject> -->
        <xsl:apply-templates select="group | course">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@default-sortkey" />
            <xsl:sort select="min(descendant::class/@section)" />
        </xsl:apply-templates>

        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>


    <!--<xsl:template match="(subject | topic | subtopic)/@name">-->
    <xsl:template match="subject/@name | topic/@name | subtopic/@name">
        <xsl:variable name="style-name">
            <!-- if this is a child of a special-section element, add that to its Xtag -->
            <xsl:if test="ancestor::special-section">Special </xsl:if>
            <xsl:value-of select="concat(upper-case(substring(../local-name(), 1,1)), lower-case(substring(../local-name(), 2)))" /> Header
        </xsl:variable>
        <xsl:value-of select="fn:p-tag($style-name)" />
        <xsl:value-of select="upper-case(.)" />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>


    <xsl:template match="type">
        <xsl:apply-templates select="@name" />

        <xsl:apply-templates select="group | course">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@default-sortkey" />
            <xsl:sort select="min(descendant::class/@section)" />
        </xsl:apply-templates>

        <!-- each type section should be followed by one blank line -->
        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="type/@name">
        <!-- only output the type header if we're not in a special-section with the same name -->
        <xsl:if test="normalize-space(.) != normalize-space(ancestor::special-section[1]/@name)">
            <xsl:value-of select="fn:p-tag('Type Header')" /><xsl:value-of select="." /> Courses<xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>



    <xsl:template match="group">
        <xsl:apply-templates select="course">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@default-sortkey" />
            <xsl:sort select="min(descendant::class/@section)" />
        </xsl:apply-templates>
        <xsl:apply-templates select="comments" />

        <!-- each group section should be followed by one blank line -->
        <xsl:value-of select="fn:br()" />
    </xsl:template>




    <xsl:template match="course">
        <xsl:apply-templates select="class">
            <xsl:sort select="@sortkey" data-type="number" />
            <xsl:sort select="@sortkey-date" data-type="number" />
            <xsl:sort select="@sortkey-days" data-type="number" />
			<xsl:sort select="@sortkey-time" data-type="number" order="ascending" />
            <xsl:sort select="@section" />
        </xsl:apply-templates>

        <xsl:apply-templates select="comments" />

        <!-- only add a blank line after the comments if this is not the
             last course and if this isn't part of a <group> -->
        <xsl:if test="position() != last() and not(ancestor::group) and not(ancestor::special-section and following-sibling::course/@number = self::course/@number)">
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>




    <xsl:template match="class">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="ancestor::type"><xsl:value-of select="ancestor::type/@name" /></xsl:when>
                <xsl:when test="ancestor::special-section"><xsl:value-of select="ancestor::special-section/@name" /></xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="main-style-name">
            <!-- this should define the possible different class-type styles -->
            <xsl:choose>
                <xsl:when test="$type = 'Night' or $type = 'Flex - Night' or $type = 'Fast Track Night'">Night</xsl:when>
                <xsl:when test="$type = 'Distance Learning'">Distance Learning</xsl:when>
                <xsl:otherwise>Normal</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="style-name">
            <!-- prepend Core to the style name if it's a Core Course -->
            <xsl:choose>
                <xsl:when test="parent::course/@core-component and parent::course/@core-component != ''">Core <xsl:value-of select="$main-style-name" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="$main-style-name" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="fn:p-tag(concat($style-name, ' Class'))" />

        <!-- the class number is a composite of the course's @rubrik and @number and the class's @section -->
        <xsl:value-of select="../@rubrik" /><xsl:text> </xsl:text>
        <xsl:value-of select="../@number" /><xsl:text>-</xsl:text>
        <xsl:value-of select="@section" /><xsl:value-of select="fn:sep()" />

        <xsl:value-of select="../@title" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@synonym" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="../@credit-hours" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@formatted-dates" /> <xsl:apply-templates select="@weeks" /><xsl:value-of select="fn:newline()" />
        <xsl:apply-templates select="@days" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@formatted-times" /> / <xsl:value-of select="@method" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@room" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@faculty-name" /><xsl:value-of select="fn:newline()" />

        <xsl:apply-templates select="extra">
            <xsl:sort select="@sortkey" />
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="class/@weeks">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="." />
        <xsl:text> Wks)</xsl:text>
    </xsl:template>

    <xsl:template match="class[ancestor::subject/@name = 'Students 50+ Education Program']/@weeks" priority="1">
        <!-- don't output the number of weeks for Senior Adult courses -->
    </xsl:template>

    <xsl:template match="class[ancestor::subject/@name = 'Students 50+ Education Program']/@days">
        <!-- spell out the days of the week for Senior Adult courses -->
        <xsl:value-of select="utils:senior-adult-days(.)" />
    </xsl:template>


    <xsl:template match="extra[@method = ('LEC','')]">
        <xsl:value-of select="@days" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@formatted-times" /> / <xsl:value-of select="@method" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@room" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@faculty-name" /><xsl:value-of select="fn:newline()" />
    </xsl:template>

    <xsl:template match="extra">
        <xsl:value-of select="fn:p-tag('Extra Class')" />
        <xsl:value-of select="@method" /><xsl:value-of select="fn:sep()" />
        <xsl:apply-templates select="@formatted-times" /><xsl:value-of select="fn:sep()" />
        <xsl:apply-templates select="@days" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@room" /><xsl:value-of select="fn:sep()" />
        <xsl:value-of select="@faculty-name" /><xsl:value-of select="fn:newline()" />
    </xsl:template>

    <!-- CIT self-paced mods -->
    <xsl:template match="//extra[@method = ('LAB') and @formatted-times = 'TBA' and ancestor::subject/@name = $CIT_subjects]/@formatted-times">
        <xsl:value-of select="'Self-Paced'" />
    </xsl:template>
    <xsl:template match="//extra[@method = ('LAB') and @formatted-times = 'TBA' and ancestor::subject/@name = $CIT_subjects]/@days">
        <xsl:value-of select="' '" />
    </xsl:template>
    
    
    <!-- =============================================================
         <comments> element templates
         =============================================================

         <comments> elements are allowed to have a small subset of
         HTML elements as children, in addition to the special
         elements <url> and <email.  The set of HTML elements allowed
         in <comments> elements is:

             h1, p, b, i, table, tr, td

         The following templates handle the proper Quark XPress Tag
         generation for the <comments> element and its children.  -->
    <xsl:template match="comments">
        <xsl:variable name="style-name">
            <xsl:choose>
                <xsl:when test="parent::subject">Subject Comments</xsl:when>
                <xsl:when test="parent::topic">Topic Comments</xsl:when>
                <xsl:when test="parent::subtopic">Subtopic Comments</xsl:when>
                <xsl:when test="parent::group">Group Comments</xsl:when>
                <xsl:otherwise>Annotation</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:value-of select="fn:p-tag($style-name)" />

        <xsl:apply-templates>
            <xsl:with-param name="comments-style" select="$style-name" tunnel="yes" />
        </xsl:apply-templates>
        <xsl:value-of select="fn:newline()" />
    </xsl:template>

    <!-- Remove <comments> inside of <special-section>s (unless we're
         in a Learning Community special section) -->
    <xsl:template match="comments[ancestor::special-section[not(@name = 'Learning Community - Interdisciplinary Studies')]]" />

    <xsl:template match="comments//p">
        <xsl:apply-templates />
        <xsl:if test="position() != last()">
            <xsl:value-of select="fn:newline()" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="comments//h1">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:value-of select="fn:c-tag(concat($comments-style, ' Header'), current())" />
        <xsl:value-of select="fn:newline()" />
    </xsl:template>

    <xsl:template match="comments//b | comments//i">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:variable name="style-suffix" select="if (local-name() = 'b') then ' Bold' else ' Italic'" />
        <xsl:value-of select="fn:c-tag(concat($comments-style, $style-suffix), current())" />
    </xsl:template>

    <xsl:template match="comments//table">
        <xsl:param name="comments-style" tunnel="yes" />
        <xsl:choose>
            <xsl:when test="$format = 'quark'"><xsl:apply-templates select="*" /></xsl:when>
            <xsl:when test="$format = 'indesign'">
                <xsl:value-of select="fn:TableStyle($comments-style)" />
                <xsl:value-of select="fn:TableStart(count(tr), count(tr[1]/td))" />
                <xsl:apply-templates select="tr" />
                <xsl:value-of select="fn:TableEnd()" />
                <xsl:value-of select="fn:newline()" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="comments//tr">
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <xsl:if test="not(count(td) = (1, 2))">
                    <xsl:message>Error in <xsl:value-of select="ancestor::comments/parent::element()/@name" /> comments (from the custom mappings files): Tables must have either one or two columns</xsl:message>
                </xsl:if>
                
                <xsl:choose>
                    <xsl:when test="count(td) = 2">
                        <!-- The following line sets the tabs for these two
                            columns to be positioned at 125 pts, aligned
                            left, and filled with blank spaces ("1 ") -->
                        <xsl:text>&lt;*t(125.0,0,"1 ")&gt;</xsl:text>
                        <xsl:apply-templates select="td[1]" />
                        <xsl:value-of select="fn:sep()" />
                        <xsl:apply-templates select="td[2]" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="td[1]" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="fn:newline()" />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <xsl:value-of select="fn:RowStart()" />
                <xsl:apply-templates select="td" />
                <xsl:value-of select="fn:RowEnd()" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="comments//td">
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <xsl:apply-templates />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <xsl:value-of select="fn:CellStart()" />
                <xsl:apply-templates />
                <xsl:value-of select="fn:CellEnd()" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="url | email">
        <xsl:value-of select="fn:c-tag('website', current())" />
    </xsl:template>


    <!-- =============================================================
         Specialty named templates
         =============================================================

         Named templates that serve a very specific purpose, like
         creating the division information at the top of each subject
         and getting a nicely-formatted list of the Core Curriculum
         courses in each subject.  -->

    <xsl:template name="division-info">
        <xsl:value-of select="fn:p-tag('Division Info')" />
        <xsl:choose>
            <!-- if we're inside a division, print the full division contact info -->
            <xsl:when test="ancestor::division">
                <!-- Get the division info.  Any info on this element overrides the info provided
                     by the ancestor division. -->
                <xsl:variable name="division-name" select="upper-case(ancestor::division/@name)" />
                <xsl:variable name="ext" select="if (@ext) then @ext else ancestor::division/@ext" />
                <xsl:variable name="room" select="if (@room) then @room else ancestor::division/@room" />
                <xsl:variable name="extra-room" select="if (@extra-room) then @extra-room else ancestor::division/@extra-room" />
                <xsl:variable name="email" select="if (@email) then @email else ancestor::division/@email" />

                <!-- division name -->
                <xsl:value-of select="$division-name" /><xsl:text>  |  </xsl:text>

                <!-- phone number plus extension -->
                <xsl:text>972-860-</xsl:text><xsl:value-of select="$ext" /><xsl:text>  |  </xsl:text>

                <!-- either room or rooms or location -->
                <xsl:choose>
                    <!-- if there is a @location, don't print 'ROOM ' first, just print
                         the location -->
                    <xsl:when test="@location">
                        <xsl:value-of select="@location" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- if there is an @extra-room, add an S to ROOM -->
                        <xsl:text>ROOM</xsl:text><xsl:value-of select="if ($extra-room) then 'S ' else ' '" />

                        <!-- the actual room number -->
                        <xsl:value-of select="$room" />

                        <!-- if there's an extra room, add it -->
                        <xsl:if test="$extra-room">
                            <xsl:text> and </xsl:text><xsl:value-of select="$extra-room" />
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="fn:newline()" />

                <!-- email address -->
                <xsl:text>E-MAIL:  </xsl:text><xsl:value-of select="$email" />
            </xsl:when>

            <!-- otherwise (we're probably in a special-section), just try to print the division name -->
            <xsl:otherwise><xsl:value-of select="if (@division-name) then upper-case(@division-name) else 'UNKNOWN DIVISION'" /></xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="fn:newline()" />
    </xsl:template>


    <!-- the next template creates the list of Core Curriculum courses
         at the top of each subject -->
    <xsl:template name="make-core-list">
        <xsl:variable name="core-courses" select="descendant::course[@core-component and @core-component != '']" />
        <xsl:if test="$core-courses and not(ancestor::special-section)">
            <xsl:variable name="core-component" select="lower-case((descendant::course/@core-component)[1])" />

            <xsl:value-of select="fn:p-tag('Core List Header')" />
            <xsl:text>The following courses </xsl:text>
            <xsl:if test="$core-component = 'other'">in this subject </xsl:if>
            <xsl:text>are part of</xsl:text>
            <xsl:value-of select="fn:newline()" />
            <xsl:text>the </xsl:text>
            <xsl:if test="$core-component != 'other'"><xsl:value-of select="$core-component" /> component of the </xsl:if>
            <xsl:text>Core Curriculum:</xsl:text>
            <xsl:value-of select="fn:newline()" />

            <xsl:value-of select="fn:p-tag('Core List')" />
            <xsl:for-each-group select="$core-courses" group-by="@rubrik">
                <xsl:sort select="@rubrik" />

                <xsl:for-each-group select="current-group()" group-by="@number">
                    <xsl:sort select="@number" />
                    <xsl:value-of select="concat(@rubrik, ' ', @number)" />

                    <xsl:if test="position() != last()">
                        <xsl:value-of select="', '" />
                    </xsl:if>
                </xsl:for-each-group>

                <xsl:if test="position() != last()">
                    <xsl:value-of select="', '" />
                </xsl:if>
            </xsl:for-each-group>

            <xsl:value-of select="fn:newline()" />
            <xsl:value-of select="fn:br()" />
        </xsl:if>
    </xsl:template>




    <!--PICK-FORMAT NAMED TEMPLATES
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        insert special characters into the output
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <!-- insert preamble -->
    <xsl:function name="fn:preamble" as="xs:string">
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <!-- quark preamble is <v7.31><e0>\r -->
                <xsl:value-of select="concat('&lt;v7.31&gt;&lt;e0&gt;', fn:newline())" />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <!-- InDesign preamble is <ASCII-MAC>\n<Version:3><FeatureSet:InDesign-Roman><ColorTable:=<Black:COLOR:CMYK:Process:0,0,0,1>>\n -->
                <xsl:value-of select="concat('&lt;ASCII-MAC&gt;', fn:newline(), '&lt;Version:3&gt;', '&lt;FeatureSet:InDesign-Roman&gt;&lt;ColorTable:=&lt;Black:COLOR:CMYK:Process:0,0,0,1&gt;&gt;', fn:newline())" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- insert one or more newline/return/etc characters -->
    <xsl:function name="fn:newline" as="xs:string">
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <!-- quark requires mac-style line markers, '\r' -->
                <xsl:text>&#13;</xsl:text>
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <!-- newline -->
                <xsl:text>&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="fn:newline" as="xs:string">
        <xsl:param name="count" as="xs:integer" />
        
        <xsl:choose>
            <xsl:when test="$count &lt; 1"><xsl:value-of select="''" /></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$format = 'quark'">
                        <xsl:value-of select="concat(fn:newline(), fn:newline($count - 1))" />
                    </xsl:when>
                    <xsl:when test="$format = 'indesign'">
                        <xsl:value-of select="concat(fn:newline(), fn:newline($count - 1))" />
                    </xsl:when>
                    <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- insert seperater -->
    <xsl:function name="fn:sep" as="xs:string">
        <xsl:choose>
            <xsl:when test="$format = ('quark', 'indesign')">
                <xsl:text>&#9;</xsl:text>
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- inserts a blank line into the output -->
    <xsl:function name="fn:br" as="xs:string">		
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <xsl:value-of select="concat(fn:p-tag('Normal Class'), fn:newline())" />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <xsl:value-of select="concat(fn:p-tag(''), fn:newline())" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="fn:br" as="xs:string">
        <xsl:param name="count" as="xs:integer" />
        
        <xsl:choose>
            <xsl:when test="$count &lt; 1"><xsl:value-of select="''" /></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$format = 'quark'">
                        <xsl:value-of select="concat(fn:br(), fn:br($count - 1))" />
                    </xsl:when>
                    <xsl:when test="$format = 'indesign'">
                        <xsl:value-of select="concat(fn:br(), fn:br($count - 1))" />
                    </xsl:when>
                    <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- insert paragraph style -->
    <xsl:function name="fn:p-tag" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <!-- looks like '@style:' -->
                <xsl:value-of select="concat('@', normalize-space($style-name), ':')" />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <!-- looks like '<ParaStyle:[name]>' -->
                <xsl:value-of select="concat('&lt;ParaStyle:', normalize-space($style-name), '&gt;')" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- insert character style -->
    <xsl:function name="fn:c-tag" as="xs:string">
        <xsl:param name="style-name"    as="xs:string" />
        <xsl:param name="content"       as="xs:string" />
        
        <xsl:choose>
            <xsl:when test="$format = 'quark'">
                <!-- looks like '<@style>...<@$p>' -->
                <xsl:value-of select="concat('&lt;@', normalize-space($style-name), '&gt;', $content, '&lt;@$p&gt;')" />
            </xsl:when>
            <xsl:when test="$format = 'indesign'">
                <!-- looks like '<CharStyle:[name]>' -->
                <xsl:value-of select="concat('&lt;CharStyle:', normalize-space($style-name), '&gt;', $content, '&lt;CharStyle:&gt;')" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="no-such-format" /></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="no-such-format" as="xs:string">
        <xsl:message>
            <xsl:text>No format named </xsl:text>
            <xsl:value-of select="$format" />
            <xsl:text>.</xsl:text>
        </xsl:message>
        <xsl:value-of select="''" />
    </xsl:template>
    
    
    <!--INDESIGN TABLE BUILDER FUNCTIONS
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        insert InDesign Tables into the output
        table tags (look like '<TableStyle:StyleName><TableStart><RowStart><CellStart><CellEnd><RowEnd><TableEnd>')
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->
    <xsl:function name="fn:TableStyle" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:value-of select="concat('&lt;TableStyle:', normalize-space($style-name), '&gt;')" />
    </xsl:function>
    <xsl:function name="fn:TableStart" as="xs:string">
        <xsl:param name="rows" as="xs:integer" />
        <xsl:param name="cols" as="xs:integer" />
        
        <xsl:value-of select="concat('&lt;TableStart:', $rows, ',', $cols, ':0:0&gt;')" />
    </xsl:function>
    
    <xsl:function name="fn:TableEnd" as="xs:string">
        <xsl:text>&lt;TableEnd:&gt;</xsl:text>
    </xsl:function>
    
    <xsl:function name="fn:RowStart" as="xs:string">
        <xsl:text>&lt;RowStart:&gt;</xsl:text>
    </xsl:function>
    
    <xsl:function name="fn:RowEnd" as="xs:string">
        <xsl:text>&lt;RowEnd:&gt;</xsl:text>
    </xsl:function>
    
    <xsl:function name="fn:CellStart" as="xs:string">
        <xsl:text>&lt;CellStart:1,1&gt;</xsl:text>
    </xsl:function>
    
    <xsl:function name="fn:CellEnd" as="xs:string">
        <xsl:text>&lt;CellEnd:&gt;</xsl:text>
    </xsl:function>
</xsl:stylesheet>
