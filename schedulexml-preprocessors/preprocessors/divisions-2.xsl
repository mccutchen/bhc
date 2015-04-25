<?xml version="1.0" encoding="UTF-8"?>

<!--

Combines duplicated divisions resulting from the divisions-1 preprocessor
into the same division.

MUST BE RUN AFTER DIVISIONS-1.

-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <xsl:template match="/">
        <xsl:message>Preprocessor: <xsl:value-of select="base-uri(document(''))" /></xsl:message>
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="*[grouping[@type='division']]">
        <!-- make sure we include the element that contains
             the subject grouping -->
        <xsl:copy>
            <!-- include its attributes, too -->
            <xsl:apply-templates select="@*" />

            <!-- collect duplicate subject groupings into one -->
            <xsl:for-each-group select="grouping[@type='division']" group-by="@name">
                <grouping type="division" name="{current-grouping-key()}">
                    <xsl:apply-templates select="current-group()/@*" />
                    <xsl:apply-templates select="current-group()/*" />
                </grouping>
            </xsl:for-each-group>

            <!-- copy through any other child elements unchanged -->
            <xsl:apply-templates select="*[not(self::grouping[@type='division'])]" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
