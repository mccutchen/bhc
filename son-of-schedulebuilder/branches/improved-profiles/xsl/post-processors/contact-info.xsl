<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <!--
        $Id: contact-info.xsl 2379 2006-12-06 19:39:32Z wrm2110 $

        Adds division and subject contact information to the schedule.
        This information is stored in the base mappings file, in a
        <mapping type="contact-info"> element.
    -->


    <!-- Include the base post-processor -->
    <xsl:include href="base.xsl" />

    <!-- Get the "contact-info" mapping into a variable -->
    <xsl:variable name="contact-info" select="$mappings-file/mapping[@type='contact-info'][1]" as="element()" />

    <xsl:template match="division | subject">
        <!-- First, we store the current element's local-name() and
             @name in variables for use in the XPath which finds the
             mapping below -->
        <xsl:variable name="element" select="local-name()" />
        <xsl:variable name="key" select="@name" />

        <!-- Find the mapping that matches this element by @name
             (stored in $key) -->
        <xsl:variable name="mapping" select="$contact-info/element()[local-name() = $element and @name = $key]" />

        <xsl:copy>
            <!-- First, copy the new attributes gotten from the
                 mapping, which will copy over the @ext and @email
                 attributes -->
            <xsl:apply-templates select="$mapping/@* except $mapping/@name" />

            <!-- Then, copy the rest of the existing on this element
                 and all of its children -->
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
