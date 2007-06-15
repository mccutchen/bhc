<?xml version="1.0" encoding="UTF-8"?>

<!--
    $Id: senior-adults.xsl 1945 2006-04-18 21:00:49Z wrm2110 $

    Senior Adult courses need special post processing because of
    the special way they need to be handled in the schedule.

    They come out of the initial XML building stage in appropriate
    subjects inside a division called Senior Adult Education Office.

    To come out the right way in the schedule, a 'Senior Adult Education
    Program' subject needs to be added to the root of the division, and
    each real subject needs to be turned into a topic, because that's the
    way they are displayed.
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <!-- all post-processors include the base stylesheet -->
    <xsl:include href="base.xsl" />

    <!-- the name of the division, used in template matching clauses -->
    <xsl:variable name="senior-division-name">Senior Adult Education Office</xsl:variable>

    <!-- this inserts a subject called 'Senior Adult Education Program' into
         the top level of the division, which all of the other subjects will
         be copied into -->
    <xsl:template match="division[@name=$senior-division-name]">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <subject name="Senior Adult Education Program" machine_name="senior_adult_education_program">
                <comments>All courses listed under Senior Adult Education Program have been planned for adults who are 50 years or older.  For information and personal assistance with registration, please call DeBorah Whaley- Stephenson at 972-860-4807 or Janice Groeneman at 972-860-4698.  The Senior Adult Education offices are located in Building M, in rooms M203 and M211A. Are you eligible for FREE tuition?  If you are 65 years or older and reside in Dallas County (or own property in Dallas County subject to ad valorem taxation), tuition for credit classes is waived for up to six credit hours per semester.</comments>
                <xsl:apply-templates select="node()" />
            </subject>
        </xsl:copy>
    </xsl:template>

    <!-- each subject is turned into a topic child of the main subject created
         above.  each topic and subtopic inside the subject is promoted to that
         subject's top level. -->
    <xsl:template match="division[@name=$senior-division-name]/subject">
        <!-- Generate a sortkey for each subject.  Right now, this returns
             1 for Office Technology and 0 for everything else, because Janice
             wants all of the Office Technology courses to come out at the end
             of the Senior Adults section -->
        <xsl:variable name="sortkey" as="xs:decimal">
            <xsl:choose>
                <xsl:when test="@name = 'Office Technology'"><xsl:number value="1" /></xsl:when>
                <xsl:otherwise><xsl:number value="0" /></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <topic>
            <xsl:attribute name="sortkey"><xsl:value-of select="$sortkey" /></xsl:attribute>
            <xsl:apply-templates select="@* except @sortkey" />
            <xsl:apply-templates select="topic/* except subtopic" />
            <xsl:apply-templates select="topic/subtopic/*" />
            <xsl:apply-templates select="node() except topic" />
        </topic>
    </xsl:template>

    <!-- the Office Technology and Visual Communications subjects have their
         @name attributes modified.  All other subjects are left alone -->
    <xsl:template match="division[@name=$senior-division-name]/subject/@name">
        <xsl:choose>
            <xsl:when test="current() = 'Office Technology'">
                <xsl:attribute name="name">Computer Courses, Office Technology</xsl:attribute>
            </xsl:when>
            <xsl:when test="current() = 'Visual Communications'">
                <xsl:attribute name="name">Macintosh Courses, Visual Communications</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
