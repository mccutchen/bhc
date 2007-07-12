<?xml version="1.0" encoding="UTF-8"?>

<!--
    This preprocessor inserts the appropriate <type>
    elements into the ScheduleXML file by grouping <course>
    elements with the same @type-id into <type> elements.
    
    MUST BE RUN AFTER TYPES-1.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <!-- get the mapping into a variable -->
    <xsl:variable name="type-map" select="document('../mappings/types.xml')//type" />

    <!-- the default type name if none is given -->
    <xsl:variable name="default-name" select="$type-map[@default]/@name" as="xs:string" />
    <xsl:variable name="default-sortkey" select="count($type-map) + 1" as="xs:decimal" />

    <!-- match any element that has child <course> elements -->
    <xsl:template match="*[course]">
        <xsl:copy>
            <!-- copy any attributes and non-<course> children unchanged -->
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates select="*[not(self::course)]" />

            <xsl:for-each-group select="course" group-by="@type-id">
                <!-- get a type name and sortkey from the mapping based on the
                     current @type-id attribute -->
                <xsl:variable name="id" select="current-grouping-key()" as="xs:string" />
                <xsl:variable name="mapping" select="$type-map[@id = $id]" />
                <xsl:variable name="name" select="if ($mapping) then $mapping/@name else $default-name" as="xs:string" />
                <xsl:variable name="sortkey" select="index-of($type-map/@id, $id)[1]" />
                
                <!-- create the actual <grouping> element for this type -->
                <grouping type="type" id="{$id}" name="{$name}" sortkey="{if ($sortkey) then $sortkey else $default-sortkey}">
                    <xsl:apply-templates select="current-group()" />
                </grouping>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
