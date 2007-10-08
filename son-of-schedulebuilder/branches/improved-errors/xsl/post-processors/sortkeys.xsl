<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <!-- $Id: sortkeys.xsl 2389 2006-12-08 14:51:58Z wrm2110 $

         This post-processor attempts to get groups and courses to
         have appropriate @sortkey attributes, mostly to try to make
         the special-regroupings come out right. -->

    <!-- Include the base post-processor -->
    <xsl:include href="base.xsl" />

    <!-- Get a list of sort orders for days and teaching methods from
         the mappings file. -->
    <xsl:variable name="days-order" select="$mappings-file/mapping[@type='days-sort-order'][1]/day/@id" />
    <xsl:variable name="method-order" select="$mappings-file/mapping[@type='method-sort-order'][1]/method/@id" />

    <!-- Regular expression which identifies a Senior Adult course
         section. -->
    <xsl:variable name="senior-adult-regex">^senior\s+adult</xsl:variable>


    <xsl:template match="group">
        <!-- A <group> element's @default-sortkey attribute comes from
             the first class number listed in its @cross-listings
             attribute, so that <group>s are sorted by their primary
             class by default.

             A @sortkey attribute, which will override the
             @default-sortkey attribute, is added if any of the
             <class> elements in this <group> have their own @sortkey
             attributes, which indicates that the <class> was
             specially-sorted in a regrouping.  The @sortkey attribute
             on a <group> will be the smallest @sortkey attribute on
             the <group>'s child <class> elements. -->

        <xsl:copy>
            <!-- Add the @default-sortkey attribute.  A full class
                 number (e.g. ACCT-1301-2001) is 14 characters long,
                 so the @default-sortkey is the first 14 characters of
                 the @cross-listings attribute. -->
            <xsl:attribute name="default-sortkey"><xsl:value-of select="substring(@cross-listings, 1,14)" /></xsl:attribute>

            <!-- The variable $sortkey will contain either the lowest
                 @sortkey attribute from any <class> elements in this
                 <group>, if any of them have @sortkey attributes or
                 nothing. -->
            <xsl:variable name="sortkey" select="if (course/class/@sortkey) then min(course/class/@sortkey) else nothing" />

            <!-- If we have a valid $sortkey, make it this <group>'s
                 @sortkey attribute. -->
            <xsl:if test="$sortkey">
                <xsl:attribute name="sortkey"><xsl:value-of select="$sortkey" /></xsl:attribute>
            </xsl:if>

            <!-- Copy the rest of this <group>'s attributes and child
                 nodes. -->
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="course">
        <!-- If a <class> element has a @sortkey attribute, that class
             was specially-regrouped.  So, if this <course> element
             contains any <class> elements with @sortkey attributes,
             the lowest @sortkey attribute from the <class> elements
             should replace this <course>'s @sortkey.

             Each <course> will also have a @default-sortkey attribute
             added which is composed of the <course>'s @rubrik and
             @number and the smallest @section number from the <class>
             elements in this <course>. -->

        <xsl:copy>
            <!-- Add the @default-sortkey attribute to this <course>
                 element. -->
            <xsl:attribute name="default-sortkey">
                <xsl:value-of select="string-join((@rubrik, @number, string(min(class/@section))), '-')" />
            </xsl:attribute>

            <!-- The variable $sortkey will contain either the lowest
                 @sortkey attribute from any <class> elements in this
                 <course>, if any of them have @sortkey attributes, or
                 nothing. -->
            <xsl:variable name="sortkey" select="if (class/@sortkey) then min(class/@sortkey) else nothing" />

            <!-- If we have a valid $sortkey, make it this <course>'s
                 @sortkey attribute. -->
            <xsl:if test="$sortkey">
                <xsl:attribute name="sortkey"><xsl:value-of select="$sortkey" /></xsl:attribute>
            </xsl:if>

            <!-- Copy the rest of this <course>'s attribute and child
                 nodes, except any preexisting @sortkey and
                 @default-sortkey attributes, so they don't overwrite
                 those that we just created. -->
            <xsl:apply-templates select="(@* except (@sortkey, @default-sortkey)) | node()" />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="group/course">
        <!-- Any <course> elements within <group> elements are sorted
             differently than other <course> elements.

             The @sortkey attribute of a <course> element inside a
             <group> element is based on the order that the class
             number (e.g. ACCT-1301-2001) of the <class> with the
             lowest @section in this <course> appears in the parent
             <group> element's @cross-listings attribute.

             For example, given

                 <group cross-listings="ACCT-1301-2002ACCT-1301-2001" />

             the <course> element which contains the class whose
             number is ACCT-1301-2002 will be sorted first in this
             group. -->

        <xsl:copy>
            <!-- calculate the sortkey, based on the number of characters before this
                 course's number in the cross-listings -->

            <!-- Create the lowest "class number" in this <course> by
                 joining this <course>'s @rubrik and @number and the
                 lowest @section on any of the <class> elements in
                 this <course>. -->
            <xsl:variable name="class-number" select="string-join((@rubrik, @number, string(min(class/@section))), '-')" />

            <!-- The @sortkey attribute for this <course> will be the
                 number of characters before the $class-number in the
                 parent <group>'s @cross-listings attribute.  As a
                 result, the <course> elements in each <group> are
                 sorted according to the order they appear in that
                 <group>'s @cross-listings. -->
            <xsl:attribute name="sortkey">
                <xsl:value-of select="(string-length(substring-before(parent::group/@cross-listings, $class-number)) idiv 14) + 1" />
            </xsl:attribute>

            <!-- Copy the rest of this <course>'s attribute and child
                 nodes, except any preexisting @sortkey attribute, so
                 it doesn't overwrite the one we just created. -->
            <xsl:apply-templates select="(@* except @sortkey) | node()" />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="class">
        <!-- This template adds a @sortkey-days attribute to each
             <class> element, based on the order that each <class>'s
             @days attribute appears in the $days-order list, which
             comes from the mappings file. -->

        <!-- The variable $index will contain either the position this
             <class>'s @days attribute appeared in the $days-order
             list or nothing. -->
        <xsl:variable name="index" select="if (@days) then index-of($days-order, @days)[1] else nothin" />

        <xsl:copy>
            <!-- Add the @sortkey-days attribute -->
            <xsl:attribute name="sortkey-days">
                <!-- The @sortkey-days attribute will be either
                     $index, if the @days of this <class> were in the
                     $days-order list, or the length of the
                     $days-order list.  That way, @days attribute
                     values that don't show up in the $days-order list
                     will appear after all of the other <class>
                     elements. -->
                <xsl:value-of select="if ($index) then $index else count($days-order) + 1" />
            </xsl:attribute>

            <!-- Copy the rest of this <class>'s attributes and child
                 nodes. -->
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>


    <xsl:template match="extra">
        <!-- The <extra> elements are sorted based on the order in
             which their @method attribute appears in the
             $method-order list above. -->

        <!-- Make sure we have a value for $method that can be used to
             look into the $method-list. -->
        <xsl:variable name="method" select="if (@method) then @method else ''" as="xs:string" />

        <!-- Get the index of this <extra> element's @method attribute. -->
        <xsl:variable name="index" select="index-of($method-order, $method)[1]" />

        <xsl:copy>
            <xsl:attribute name="sortkey">
                <!-- The @sortkey attribute is either $index if it
                     exists or the length of the $method-order list,
                     so uknown methods will be sorted last. -->
                <xsl:value-of select="if ($index) then $index else count($method-order) + 1" />
            </xsl:attribute>

            <!-- Copy the rest of this <extra> element's attributes
                 and child nodes. -->
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>


    <!-- ===================================
         Senior Adults special sorting logic
         ===================================

         Senior Adult courses are supposed to come sorted
         alphabetically by course title.  That means that the
         @default-sortkey on <course> elements should come from that
         <course> element's @title and the @default-sortkey on <group>
         elements should come from the @title of the first <course>
         listed in that <group>'s @cross-listings.

         This sorting strategy differs from those above, so these
         templates overrive the previous ones for <course> and <group>
         elements that are in the Senior Adults division.  That's why
         they have a priority of 9. -->

    <xsl:template match="division[matches(@name, $senior-adult-regex, 'i')]//course" priority="9">
        <!-- <course> elements in the Senior Adults division should be
             sorted by their @title attributes rather than any course
             numbers. -->
        <xsl:copy>
            <!-- Add the @default-sortkey based on this <course>
                 element's @title -->
            <xsl:attribute name="default-sortkey"><xsl:value-of select="@title" /></xsl:attribute>

            <!-- Copy evertyhing else, except for any previous
                 sortkeys. -->
            <xsl:apply-templates select="(@* except (@sortkey, @default-sortkey)) | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="division[matches(@name, $senior-adult-regex, 'i')]//group" priority="9">
        <!-- <group> elements inside the Senior Adult division should
             be sorted based on the @title of the first <course>
             listed in their @cross-listings.  That way, the groups
             will appear alphabetically -->
        <xsl:copy>
            <!-- Create the @default-sortkey attribute by finding the
                 @title of the <course> element that is listed first
                 in this <group> element's @cross-listings. -->
            <xsl:attribute name="default-sortkey">
                <xsl:value-of select="course[string-join((@rubrik, @number), '-') = substring(parent::group/@cross-listings,1,9)]/@title" />
            </xsl:attribute>

            <!-- Copy everything else, except for any previous
                 sortkeys. -->
            <xsl:apply-templates select="(@* except (@sortkey, @default-sortkey)) | node()" />
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
