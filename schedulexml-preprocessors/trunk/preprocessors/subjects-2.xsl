<?xml version="1.0" encoding="UTF-8"?>

<!--

Combines duplicated subjects resulting from the subjects-1 preprocessor
into the same subject.

MUST BE RUN IMMEDIATELY AFTER SUBJECTS-1.

-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:include href="base.xsl" />
    <xsl:include href="subjects-common.xsl" />

    <!-- Any element that contains courses must be matched, so we can
         rebuild the course and class structure based on the subjects,
         topics and subtopics contained therein. -->
    <xsl:template match="*[course]">
        <!-- Make sure to include the containing element. -->
        <xsl:copy>
            <!-- And include the containing element's attributes and
                 non-course children. -->
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[not(self::course)]"/>

            <!-- Loop through each descendent class, grouping by subject
                 name. -->
            <xsl:for-each-group select="course/class" group-by="@subject-name">
                
                <!-- Create the grouping element for this subject. -->
                <grouping type="subject" name="{current-grouping-key()}">
                    <!-- Add the subject sortkey for this class to
                         this subject -->
                    <xsl:apply-templates select="current-group()[1]/@subject-sortkey" />
                    
                    <!-- Insert any comments for this subject found in the
                         mappings. -->
                    <xsl:apply-templates select="$mappings//subject[@name=current-grouping-key()]/comments" />
                    
                    <!-- Loop through each class in this subject group,
                         further grouping by topic name. -->
                    <xsl:for-each-group select="current-group()" group-by="@topic-name">
                        
                        <!-- Create the topic grouping element for this
                             group of classes. -->
                        <grouping type="topic" name="{current-grouping-key()}">
                            <!-- Add topic sortkey from this class -->
                            <xsl:apply-templates select="current-group()[1]/@topic-sortkey" />
                            
                            <!-- Insert any comments for this topic found
                                 in the mappings. -->
                            <xsl:apply-templates select="$mappings//topic[@name=current-grouping-key()]/comments" />
                            
                            
                            <!-- Loop through each class in this topic
                                 group, further grouping by subtopic -->
                            <xsl:for-each-group select="current-group()" group-by="@subtopic-name">
                                
                                <!-- Create the subtopic grouping element
                                     for this group of classes. -->
                                <grouping type="subtopic" name="{current-grouping-key()}">
                                    <!-- Add subtopic sortkey from this class -->
                                    <xsl:apply-templates select="current-group()[1]/@subtopic-sortkey" />
                                    
                                    <!-- Insert any comments for this
                                         subtopic found in the
                                         mappings. -->
                                    <xsl:apply-templates select="$mappings//subtopic[@name=current-grouping-key()]/comments" />
                                    
                                    <!-- Insert these classes and their
                                         parent course elements. -->
                                    <xsl:apply-templates select="current-group()/parent::course" mode="copy-with-classes">
                                        <xsl:with-param name="classes" select="current-group()" />
                                    </xsl:apply-templates>
                                </grouping>
                                
                            </xsl:for-each-group>
                            
                            <!-- If there were classes in this topic group
                                 that do not belong in a subtopic, insert
                                 them and their parent courses. -->
                            <xsl:if test="current-group()[not(@subtopic-name)]">
                                <xsl:apply-templates select="current-group()/parent::course" mode="copy-with-classes">
                                    <xsl:with-param name="classes" select="current-group()[not(@subtopic-name)]" />
                                </xsl:apply-templates>
                            </xsl:if>
                        </grouping><!-- topic grouping -->
                        
                    </xsl:for-each-group>
                    
                    <!-- If there were classes in this subject group that
                         do not belong in a topic, insert them and their
                         parent courses. -->
                    <xsl:if test="current-group()[not(@topic-name)]">
                        <xsl:apply-templates select="current-group()/parent::course" mode="copy-with-classes">
                            <xsl:with-param name="classes" select="current-group()[not(@topic-name)]" />
                        </xsl:apply-templates>
                    </xsl:if>
                    
                </grouping><!-- subject grouping -->
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
        

    <!-- Copy a course into the output document with only its actual
         child classes from the given subset of classes. -->
    <xsl:template match="course" mode="copy-with-classes">
        <!-- The group of possible child classes -->
        <xsl:param name="classes" />

        <!-- We only want to include those classes in the given set
             that are actual children of this course. -->
        <xsl:variable name="child-classes" select="$classes intersect child::class" />

        <!-- Only copy this course into the output if some of its
             children actually need to be included. -->
        <xsl:if test="count($child-classes) &gt; 0">
            <xsl:copy>
                <xsl:apply-templates select="@* | *[not(self::class)]" />
                <xsl:apply-templates select="$child-classes" />
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    

    <!-- Replace comments elements from the mappings with description
         elements -->
    <xsl:template match="subject/comments | topic/comments | subtopic/comments">
        <description>
            <xsl:apply-templates />
        </description>
    </xsl:template>

    <!-- Add the subject, topic and subtopic sortkeys from each
         class to the proper grouping type. -->
    <xsl:template match="class/@subject-sortkey | class/@topic-sortkey | class/@subtopic-sortkey">
        <xsl:attribute name="sortkey" select="." />
    </xsl:template>

    <!-- Remove the subject, topic and subtopic names from each class
         element -->
    <xsl:template match="class/@subject-name | class/@topic-name | class/@subtopic-name" />
</xsl:stylesheet>
