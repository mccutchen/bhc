<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <!-- Adds a vita-id attribute to each <class> and <extra> element, based
         on their faculty names. -->

    <!-- Include the base post-processor -->
    <xsl:include href="base.xsl" />

    <!-- Get the "vita" mapping into a variable -->
    <xsl:variable name="vitas"
                  select="$mappings-file/mapping[@type='vitas'][1]"
                  as="element()" />

    <xsl:template match="class | extra">
        <!-- First, we store the current element's local-name() and
             @name in variables for use in the XPath which finds the
             mapping below -->
        <xsl:variable name="last-name" select="@faculty-last-name" />
        <xsl:variable name="first-initial" select="@faculty-first-initial" />

        <!-- Find the mapping that matches this element by @name
             (stored in $key) -->
        <xsl:variable name="vita-id"
                      select="$vitas/*[
                              @last-name=$last-name and
                              starts-with(@first-name, $first-initial)
                              ][1]/@id"/>

        <xsl:if test="not($vita-id) and $last-name and $first-initial">
            <xsl:message>Missing vita ID for class <xsl:value-of select="@synonym"/> taught by <xsl:value-of select="@faculty-name"/> (<xsl:value-of select="$last-name"/>, <xsl:value-of select="$first-initial"/>).</xsl:message>
        </xsl:if>

        <xsl:copy>
            <!-- Add the new vita-id attribute, if we have one -->
            <xsl:if test="$vita-id">
                <xsl:attribute name="vita-id" select="$vita-id"/>
            </xsl:if>
            <!-- Then, copy the rest of the existing on this element
                 and all of its children -->
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
