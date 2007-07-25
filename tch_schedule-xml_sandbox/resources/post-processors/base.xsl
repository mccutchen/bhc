<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- 
         $Id: base.xsl 2377 2006-12-06 19:08:43Z wrm2110 $
         
         The base post-processor stylesheet, which is included in
         every other post-processor.
         
         The base post-processor provides the "identity" template,
         which automatically copies all elements and attributes in the
         input document.  By including this post-processor, every
         other post-processor can selectively handle whatever elements
         they need to modify, while all the others will automatically
         be copied through by the identity template.
         
         The base post-processor also provides the <xsl:output>
         statement that will control the output of all of the other
         post-processors, so that there is only one place to change.
         
         The base post-processor also stores the base mappings file in
         the variable $mappings-file, so that other post-processors
         can easily access the contents of the mappings.
    -->

    <!-- This <xsl:output> element controls the output of all of the
         other post-processors -->
    <xsl:output
        method="xml"
        encoding="us-ascii"
        indent="yes"
        omit-xml-declaration="no" />
    
    <!-- Store the base mappings file in a variable, for easy access
         for other post-processors -->
    <xsl:variable name="mappings-file" select="document('../../mappings/base.xml')/mappings" />

    <!-- The "identity" template -->
    <xsl:template match="@* | node()" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="#current" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
