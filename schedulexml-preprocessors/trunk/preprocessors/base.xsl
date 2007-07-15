<?xml version="1.0" encoding="UTF-8"?>

<!--
    The base preprocessor stylesheet, which is included in every other
    preprocessor.

    The <xsl:output> element in this stylesheet controls the output for each
    of the other preprocessors.  By default, this stylesheet simply copies
    each element in the input unchanged by using the "identity" transform.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- This <xsl:output> element will control the output of every other
         preprocessor. -->
    <xsl:output
        method="xml"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="no" />

    <!-- The "identity" template
         (see: http://www.dpawson.co.uk/xsl/sect2/identity.html) -->
    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
