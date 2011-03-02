<?xml version="1.0" encoding="UTF-8"?>

<!--
    Breaks large <course> elements up into smaller ones
    by adding a @type-id attribute and only including
    child <class> elements with that schedule type.
    
    This is the first step towards creating actual "type"
    elements, which must be done by a follow-up preprocessor.

    TYPES-2 MUST BE RUN AFTER THIS PREPROCESSOR.
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

    <xsl:template match="course">
        <xsl:for-each-group select="class" group-by="@schedule-type">
            <xsl:variable name="id" select="current-grouping-key()" as="xs:string" />
            
            <!-- create individual <course> elements for each @schedule-type
                 found. -->
            <xsl:apply-templates select="parent::course" mode="type-specific">
                <xsl:with-param name="type-id" select="$id" />
            </xsl:apply-templates>
        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="course" mode="type-specific">
        <xsl:param name="type-id" />
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:attribute name="type-id" select="$type-id" />
            
            <!-- only copy child <class> elements if they have the correct
                 @schedule-type attribute. -->
            <xsl:apply-templates select="class[@schedule-type = $type-id]" />
            
            <!-- copy through any other child elements unchanged -->
            <xsl:apply-templates select="*[not(self::class)]" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
