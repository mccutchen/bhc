<?xml version="1.0" encoding="UTF-8"?>

<!--

Combines duplicated subjects resulting from the subjects-1 preprocessor
into the same subject.

MUST BE RUN IMMEDIATELY AFTER SUBJECTS-1.

-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <xsl:template match="*[grouping[@type='subject']]">
        <!-- make sure we include the element that contains
             the subject grouping -->
        <xsl:copy>
            <!-- include its attributes, too -->
            <xsl:apply-templates select="@*" />

            <!-- collect duplicate subject groupings into one -->
            <xsl:for-each-group select="grouping[@type='subject']" group-by="@name">
                <grouping type="subject" name="{current-grouping-key()}">
                    <xsl:apply-templates select="current-group()/@*" />
                    <xsl:apply-templates select="current-group()/*" />
                </grouping>
            </xsl:for-each-group>

            <!-- copy through any other child elements unchanged -->
            <xsl:apply-templates select="*[not(self::grouping[@type='subject'])]" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
