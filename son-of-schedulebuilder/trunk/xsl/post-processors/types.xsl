<?xml version="1.0" encoding="UTF-8"?>

<!--
    $Id: types.xsl 2379 2006-12-06 19:39:32Z wrm2110 $

    This post-processor inserts the appropriate <type>
    elements into the ScheduleXML file.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <!-- all post-processors include the base stylesheet -->
    <xsl:include href="base.xsl" />

    <!-- get the mapping into a variable -->
    <xsl:variable name="type-map" select="$mappings-file/mapping[@type='class-types'][1]" as="element()" />

    <!-- the default type name if none is given -->
    <xsl:variable name="default-name" select="$type-map/type[@default]/@name" />
    <xsl:variable name="default-sortkey" select="count($type-map/type) + 1" as="xs:decimal" />

    <xsl:template match="*[course]">
        <!-- this template works by copying the parent element
             and its attributes, inserting a new <type> element
             with the appropriate @id and @name, and finally
             copying all of the child elements into the new
             <type> element. -->

        <xsl:copy>
            <!-- make sure to copy the parent's attributes -->
            <xsl:apply-templates select="@*" />

            <!-- make sure we keep applying templates to any child
                 elements that don't need to be grouped into <type>s
                 yet, like topics, subtopics, etc. -->
            <xsl:apply-templates select="*[not(self::course)]" />

            <!-- make a <type> element for each @type found -->
            <xsl:for-each-group select="course" group-by="@type">
                <xsl:variable name="id" select="current-grouping-key()" as="xs:string" />
                <!-- figure out which element in the $type-map this type maps to -->
                <xsl:variable name="mapping" select="if ($type-map/type[@id = $id])
													 then $type-map/type[@id = $id]
													 else $type-map/type[@default = 'true']" />
                <!-- get this type's name out of the mapping -->
                <xsl:variable name="name" select="$mapping/@name" as="xs:string" />
                <!-- get this type's machine-name out of the mapping -->
                <xsl:variable name="machine-name" select="$mapping/@machine-name" as="xs:string" />
                <!-- and calculate its sortkey -->
                <xsl:variable name="sortkey" select="index-of($type-map/type/@id, $id)[1]" />

                <!-- add the <type> element for this group, and then copy over its contents -->
                <type id="{$id}" name="{$name}" machine_name="{$machine-name}" sortkey="{if ($sortkey) then $sortkey else $default-sortkey}">
                    <xsl:apply-templates select="current-group()" />
                </type>
            </xsl:for-each-group>

            <!-- make sure we put any courses without @type attributes into
                 the default <type> -->
            <xsl:if test="course[not(@type)]">
                <type name="{$default-name}" sortkey="{$default-sortkey}">
                    <xsl:apply-templates select="course[not(@type)]" />
                </type>
            </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
