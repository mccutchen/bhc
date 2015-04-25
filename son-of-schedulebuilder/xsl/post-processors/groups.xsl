<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!--
        $Id: groups.xsl 2380 2006-12-06 21:00:38Z wrm2110 $
        
        This post-processor inserts the appropriate <group> elements
        into the ScheduleXML file.
        
        It looks for any <course> elements that have identical
        @cross-listing attributes, and inserts them into a <group>
        element based on that @cross-listing attribute.  To qualify,
        the courses must have the same parent element, and there must
        be more than one <course> with the same @cross-listing.  For
        example, the following two courses would be inserted into a
        <group cross-listings="XXX"> element:
        
            <subject name="Accounting">
                <course title="Accounting I" cross-listing="XXX" />
                <course title="Accounting II" cross-listing="XXX" />
            </subject>
        
        But, the following courses would not be put into the same
        <group> element:
        
            <subject name="Accounting">
                <course title="Accounting I" cross-listing="XXX" />
            </subject>
            <subject name="Business Accounting">
                <course title="Accounting I" cross-listing="XXX" />
            </subject>
        
        This post-processor also tries to intelligently create
        <comments> elements for each group.  If every <course> element
        in the group has the exact same <comments> element, that
        <comments> element is removed from each <course> and added to
        their parent <group>.
    -->


    <!-- Include the base post-processor -->
    <xsl:include href="base.xsl" />

    <xsl:template match="*[course[@cross-listings]]">
        <!-- This template works by copying the parent element and its
             attributes, then grouping separate courses with the same
             @cross-listings -->
        <xsl:copy>
            <!-- Make sure to copy the parent's attributes -->
            <xsl:apply-templates select="@*" />

            <!-- Make sure we keep applying templates to any child
                 elements that don't need to be grouped into <group>s
                 yet, like courses without cross-listings, topics,
                 subtopics, etc. -->
            <xsl:apply-templates select="*[not(self::course)] | course[not(@cross-listings)]" />

            <!-- Loop through each <course> that has a @cross-listings
                 attribute -->
            <xsl:for-each-group select="course" group-by="@cross-listings">
                <xsl:choose>
                    <!-- Make sure the current group contains more
                         than one element, so we don't put a single
                         <course> element into a <group> element. -->
                    <xsl:when test="count(current-group()) &gt; 1">

                        <!-- Create the new <group> element based on
                             the current grouping key, which is the
                             @cross-listings for this set of courses
                             -->
                        <group cross-listings="{current-grouping-key()}">
                            
                            <!-- The $make-group-comments variable
                                 will be TRUE if every <course> in
                                 this <group> has a <comments> element
                                 and if each <comments> element is
                                 identical. -->
                            <xsl:variable name="make-group-comments"
                                          select="(every $course in current-group() satisfies $course[comments])
                                                  and
                                                  (every $comment in current-group()/comments satisfies $comment = current-group()[1]/comments)" />
                            
                            <!-- If $make-group-comments is TRUE, we
                                 need to copy one of the child
                                 <course> element's <comments> up to
                                 be a child of this <group>. -->
                            <xsl:if test="$make-group-comments">
                                <xsl:copy-of select="current-group()[1]/comments" />
                            </xsl:if>

                            <!-- Finally, copy each of the <course>
                                 elements into this <group>. -->
                            <xsl:apply-templates select="current-group()">
                                <xsl:with-param name="remove-comments" select="$make-group-comments" tunnel="yes" />
                            </xsl:apply-templates>
                        </group>
                    </xsl:when>

                    <!-- If there was just one matching <course>
                         element, just copy it through without adding
                         it to a <group>. -->
                    <xsl:otherwise>
                        <xsl:apply-templates select="current-group()" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="course/comments">
        <!-- This template will remove the <comments> element from a
             <course> element if the $remove-comments parameter is
             TRUE.  $remove-comments should be TRUE if the parent
             <course> element was put in a <group> and if each of the
             parent <course>'s sibling <course> elements had identical
             <comments>. -->

        <xsl:param name="remove-comments" select="false()" tunnel="yes" />
        
        <!-- If we should not remove this <comments> element from its
             parent <course> element, copy it into the result
             document.  Otherwise, do nothing, which will remove this
             <comments> element from its parent <course> element. -->
        <xsl:if test="not($remove-comments)">
            <xsl:copy-of select="." />
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
