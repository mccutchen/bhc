<?xml version="1.0" encoding="UTF-8"?>

<!--

Translates <grouping type="rubric"> elements into
<grouping type="subject"> elements by looking up the
rubrics in mappings.xml.

This can leave duplicate subject groupings when two
or more rubrics map to the same subject (e.g. ACCT, ACNT),
so subjects-2 should be run directly after this one.

SUBJECTS-2 MUST BE RUN IMMEDIATELY AFTER THIS PREPROCESSOR.

-->


<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <!-- get the mapping into a variable -->
    <xsl:variable name="patterns" select="document('../mappings/subjects.xml')//subject/pattern" />

    <xsl:template match="grouping[@type='rubric']">
        <xsl:variable name="rubric" select="@name" />
        <xsl:variable name="matching-patterns" select="$patterns[matches($rubric, @match)]" />

        <xsl:variable name="subject-name">
            <xsl:choose>
                <xsl:when test="$matching-patterns">
                    <!-- We've found at least one matching pattern, which
                         gives us at least one subject name.  If we have more
                         than one, we pick the one with the highest priority
                         as defined in the mappings. -->
                    <xsl:value-of select="if (count($matching-patterns) &gt; 1)
                                          then $matching-patterns[@priority = max($matching-patterns/@priority)]/parent::subject/@name
                                          else $matching-patterns[1]/parent::subject/@name" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- We didn't find a match, so we just use the rubric
                         itself as the subject name. -->
                    <xsl:value-of select="$rubric" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- if we found a matching pattern in the mappings, put any <comments>
             in the matching subject in a variable -->
        <xsl:variable name="subject-comments"
                      select="if (count($matching-patterns) &gt; 1)
                              then $matching-patterns[@priority = max($matching-patterns/@priority)]/parent::subject/comments
                              else $matching-patterns[1]/parent::subject/comments" />

        <!-- create the actual <grouping> element with the subject name we
             found above. -->
        <grouping type="subject" name="{$subject-name}">
            <!-- include any comments found in the mappings -->
            <xsl:apply-templates select="$subject-comments" />
            <!-- include everything else -->
            <xsl:apply-templates />
        </grouping>
    </xsl:template>
    
    <xsl:template match="subject/comments">
        <!-- turn any <comments> elements into <description> elements to match
             the ScheduleXML spec -->
        <description>
            <xsl:apply-templates select="*" />
        </description>
    </xsl:template>
</xsl:stylesheet>
