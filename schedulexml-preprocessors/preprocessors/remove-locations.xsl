<?xml version="1.0" encoding="UTF-8"?>

<!--
    Removes all <location> elements while preserving their
    child elements if they are from the Brookhaven College
    (200) location.
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

    <xsl:template match="location[@name='200']">
        <xsl:apply-templates select="*" />
    </xsl:template>
</xsl:stylesheet>
