<?xml version="1.0" encoding="UTF-8"?>

<!--

Puts <grouping type="rubric"> elements into
<grouping type="division"> elements by looking up the
rubrics in the divisions map in mappings.xml.

This leaves duplicate <grouping type="division"> elements
in the output, one for each <grouping type="rubric">, so
this preprocessor must be followed by divisions-2 to clean
up.

DIVISIONS-2 MUST BE RUN IMMEDIATELY AFTER THIS PREPROCESSOR.

-->


<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <!-- get the mapping into a variable -->
    <xsl:variable name="patterns" select="document('../mappings/divisions.xml')//division/pattepreprocessorrn" />

    <xsl:template match="grouping[@type='rubric']">
        <xsl:variable name="rubric" select="@name" />
        <xsl:variable name="matching-patterns" select="$patterns[matches($rubric, @match)]" />

        <xsl:variable name="division-name">
            <xsl:choose>
                <xsl:when test="$matching-patterns">
					<!-- if more than one pattern matches, select the highest-
						 priority pattern -->
                    <xsl:value-of select="if (count($matching-patterns) &gt; 1)
                                          then $matching-patterns[@priority = max($matching-patterns/@priority)]/parent::division/@name
                                          else $matching-patterns[1]/parent::division/@name" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('Unknown Division: ', $rubric)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <grouping type="division" name="{$division-name}">
            <xsl:next-match />
        </grouping>
    </xsl:template>

</xsl:stylesheet>
