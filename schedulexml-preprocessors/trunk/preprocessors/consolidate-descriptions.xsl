<?xml version="1.0" encoding="UTF-8"?>

<!--
    This preprocessor looks for <course> elements which contain <class>
	elements which all have identical <description> elements.  If it finds
	one, it promotes that <description> up to be a child of the <course> and
	removes the <description> elements from each of the classes.
	
	It also trims duplicate <description> elements from "subject" elements,
	which can result from the subject-* preprocessors.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />

    <!-- we only need to match courses which contain classes with
         descriptions -->
    <xsl:template match="course[class/description]">
		<xsl:variable name="first-description-el" select="(class/description)[1]" />
        <xsl:variable name="first-description" select="normalize-space($first-description-el)" />
        <xsl:choose>
            <xsl:when test="every $d in class/description satisfies normalize-space($d) eq $first-description">
                <xsl:copy>
                    <!-- include this course's attributes -->
                    <xsl:apply-templates select="@*" />

                    <!-- include the description from the first class
                         element as a child of this element -->
                    <xsl:apply-templates select="$first-description-el" />

                    <!-- remove the description elements from this
                         course's classes -->
                    <xsl:apply-templates select="class" mode="remove-description" />

                    <!-- make sure we include any other child elements
                         that are not classes -->
                    <xsl:apply-templates select="*[not(self::class)]" />
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <!-- just include this course as normal -->
                <xsl:next-match />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="class" mode="remove-description">
		<!-- remove the <description> element from the matching <class> -->
        <xsl:copy>
            <xsl:apply-templates select="@* | *[not(self::description)]" />
        </xsl:copy>
    </xsl:template>
    
    
    <!-- trim extra <descriptions> in subjects -->
    <xsl:template match="grouping[@type='subject']/description[preceding-sibling::description]">
        <!-- doing nothing here removes the matching element from the result
             document -->
    </xsl:template>
</xsl:stylesheet>
