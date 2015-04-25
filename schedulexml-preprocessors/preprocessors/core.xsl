<?xml version="1.0" encoding="UTF-8"?>

<!--
    This preprocessor replaces the value of the @core-code attribute on any
    <course> element with the actual name of the core component.  This data
    should probably go on its own @core-component attribute.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <!-- get the mapping into a variable -->
    <xsl:variable name="components" select="document('../mappings/core.xml')//component" />

    <xsl:template match="/">
        <xsl:message>Preprocessor: <xsl:value-of select="base-uri(document(''))" /></xsl:message>
        <xsl:apply-templates />
    </xsl:template>

    <!-- we only need to mess with <course>s which actually have a @core-code
         attribute -->
    <xsl:template match="course[@core-code]">
        <!-- look up the component name in the mapping variable -->
        <xsl:variable name="code" select="@core-code" />
        <xsl:variable name="component-name" select="$components[@code = $code]/@name" />
        
        <xsl:copy>
            <!-- replace the @core-code attribute's value with the component name -->
            <xsl:attribute name="core-code">
                <xsl:value-of select="$component-name" />
            </xsl:attribute>
            <!-- copy everything else except for the old @core-code attribute -->
            <xsl:apply-templates select="(@* except @core-code) | *" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
