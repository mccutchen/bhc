<?xml version="1.0" encoding="UTF-8"?>

<!--

Translates <grouping type="rubric"> elements into
<grouping type="subject"> elements by looking up the
rubrics in mappings.xml.

This can leave duplicate subject groupings when two
or more rubrics map to the same subject (e.g. ACCT, ACNT),
so subjects-2 should be run directly after this one.

This can also leave duplicate <description> elements in each new subject
grouping if the subject has <comments> in the mappings.  This is taken care
of by the consolidate-descriptions preprocessor.

SUBJECTS-2 MUST BE RUN IMMEDIATELY AFTER THIS PREPROCESSOR.
CONSOLIDATE-DESCRIPTIONS MUST BE RUN SOME TIME AFTER THIS PREPROCESSOR.

-->


<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />
    <xsl:include href="subjects-common.xsl" />

    <!-- Pull all of the patterns out of the mappings -->
    <xsl:variable name="patterns" select="$mappings//pattern" />

    <!-- Remove each "rubric" grouping, including only its children.
         These will be replaced by "subject" groupings in the next
         step. -->
    <xsl:template match="grouping[@type='rubric']">
        <xsl:apply-templates />
    </xsl:template>

    <!-- Each class element will have at least a subject-name
         attribute added to it.  Each might also have topic- and
         subtopic-name attributes, as well as subject- topic- and
         subtopic-comments child elements added, depending on the
         subject mappings file. -->
    <xsl:template match="class">
        
        <!-- The key to match on -->
        <xsl:variable name="key" select="concat(@rubric, ' ', @number, '-', @section)" />

        <!-- The patterns that match the key for this class -->
        <xsl:variable name="matching-patterns" select="$patterns[matches($key, @match)]" />

        <!-- Figure out which of the matching patterns to use.  If
             there is only one, use it.  If each has the same
             priority, use the last one in document order.  Otherwise,
             use the one with the highest priority. -->
        <xsl:variable name="pattern" as="element()">
            <xsl:choose>
                <!-- We didn't find a matching pattern -->
                <xsl:when test="count($matching-patterns) = 0">
                    <xsl:message>WARNING: No subject found for "<xsl:value-of select="$key" />" in the subjects mapping file.</xsl:message>
                    <!-- Just use an empty pattern -->
                    <pattern />
                </xsl:when>

                <!-- Only one matching pattern -->
                <xsl:when test="count($matching-patterns) = 1">
                    <xsl:sequence select="$matching-patterns[1]" />
                </xsl:when>

                <!-- Multiple patterns, each with the same priority or
                     each with no priority at all, so we choose the
                     one that was defined last in the mappings
                     document. -->
                <xsl:when test="(every $p in $matching-patterns/@priority satisfies $p = $matching-patterns[1]/@priority) or
                                (every $p in $matching-patterns/@priority satisfies not($p))">
                    <xsl:sequence select="$matching-patterns[last()]" />
                </xsl:when>

                <!-- Multiple patterns with different priorities, so
                     we choose the one with the highest priority -->
                <xsl:otherwise>
                    <xsl:sequence select="$matching-patterns[@priority = max($matching-patterns/@priority)]" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- Copy this class element through, adding on the attributes
             for at least the subject name, as well as the topic name,
             subtopic name and sortkey, if applicable. -->
        <xsl:copy>
            <!-- Add subject-, topic- and subtopic-name attributes -->
            <xsl:apply-templates select="$pattern/ancestor::subject |
                                         $pattern/ancestor::topic |
                                         $pattern/ancestor::subtopic">
                <xsl:with-param name="pattern" select="$pattern" />
            </xsl:apply-templates>

            <!-- If we don't have a valid subject, use this class's
                 rubric as the subject name -->
            <xsl:if test="not($pattern/ancestor::subject)">
                <xsl:attribute name="subject-name" select="@rubric" />
            </xsl:if>

            <!-- If this pattern is the child of an element that
                 should be sorted, calculate its sortkey based on its
                 position among its siblings. -->
            <xsl:if test="$pattern/ancestor::element()/@sorted">
                <xsl:attribute name="sortkey-mappings" select="count($pattern/preceding-sibling::pattern)" />
            </xsl:if>

            <!-- Pass through the rest of the attributes -->
            <xsl:apply-templates select="@*" />

            <!-- Pass through the rest of the children -->
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <!-- Add an attribute for each subject, topic or subtopic name -->
    <xsl:template match="subject | topic | subtopic">
        <xsl:param name="pattern" as="element()" />
        <xsl:attribute name="{local-name()}-name" select="@name" />
        <xsl:if test="$pattern/ancestor::element()/@sorted">
            <xsl:attribute name="{local-name()}-sortkey" select="count($pattern/ancestor::self/preceding-sibling::self)" />
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>

