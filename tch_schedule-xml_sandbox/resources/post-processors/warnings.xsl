<?xml version="1.0" encoding="UTF-8"?>

<!--
    $Id: warnings.xsl 2390 2006-12-08 14:54:47Z wrm2110 $

    A stylesheet which will emit warnings for whatever
    templates are matched.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- include the base post-processor -->
    <xsl:include href="base.xsl" />


    <!-- the set of warnings conditions to check.  Each condition has
         an element and attribute to match, along with a pattern to
         check the attribute value against, and a message to issue
         if there is a match. -->
    <xsl:variable name="warnings">
        <!-- warn about subjects that need to be regrouped -->
        <warning element="subject" attribute="name" pattern="Unsorted" message="Unsorted subject" />
        <!-- warn about subjects that don't have their rubriks mapped to real names -->
        <warning element="subject" attribute="name" pattern="^[A-Z]{{4}}$" message="Unmapped subject" />
        <!-- warn about missing days on classes -->
        <warning element="class" attribute="days" pattern="^$" message="Missing days" />
    </xsl:variable>


    <!-- this template attempts to match the patterns defined in $warnings
         and issue warnings when it succeeds -->
    <xsl:template match="@*[local-name() = $warnings/warning/@attribute]">
        <!-- we need to save this info in variables for some reason -->
        <xsl:variable name="attribute" select="local-name()" />
        <xsl:variable name="value" select="current()" />
        <xsl:variable name="element" select="local-name(..)" />

        <!-- for each possibly-applicable warning, if the pattern matches,
             issue the warning message -->
        <xsl:for-each select="$warnings/warning[@attribute = $attribute and @element = $element]">
            <xsl:if test="matches($value, current()/@pattern)">
                <xsl:message>WARNING: <xsl:value-of select="current()/@message" /> (<xsl:value-of select="$attribute" />=<xsl:value-of select="$value" />)</xsl:message>
            </xsl:if>
        </xsl:for-each>

        <!-- insert this attribute into the document -->
        <xsl:copy-of select="current()" />
    </xsl:template>
</xsl:stylesheet>
