<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- $Id: special-sections.xsl 2382 2006-12-06 22:21:20Z wrm2110 $
         
         This post-processor ensures that each <subject> inside a
         <special-section> element has its division name in a
         @division-name attribute.  Otherwise, that division
         information is lost in the <special-sections>. -->

    <!-- Include the base post-processor -->
    <xsl:include href="base.xsl" />

    
    <xsl:template match="special-section//subject">
        <!-- Make sure this <subject> has its <division>'s @name
             attribute attached to itself in the @division-name
             attribute. -->

        <!-- Store this <subject>'s @name in a variable, to simplify
             the XPath expression below. -->
        <xsl:variable name="name" select="@name" />
        <xsl:copy>
            <!-- Add the @name of the first <division> which contains
                 a <subject> with the same @name as this <subject> to
                 this subject in the @division-name attribute. -->
            <xsl:attribute name="division-name" select="(ancestor::term/division[subject[@name = $name]][1])/@name" />

            <!-- Copy everything else. -->
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
