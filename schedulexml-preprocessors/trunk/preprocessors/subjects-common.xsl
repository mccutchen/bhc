<!-- subjects-common.xsl - sets up variables shared by both of the
     subjects preprocessors -->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <!-- Get the patterns from the mappings file(s) -->
    <xsl:variable name="base-mappings-path">../mappings/subjects/base.xml</xsl:variable>
    <xsl:variable name="term-mappings-path">../mappings/subjects/<xsl:value-of select="//term[1]/@name"/>.xml</xsl:variable>
    <xsl:variable name="mappings" select="document($base-mappings-path) | document($term-mappings-path)" />
</xsl:stylesheet>
