<?xml version='1.0'?>

<!--
template.xsl
$Id: indexer.xsl 2055 2006-06-21 20:27:06Z wrm2110 $
-->

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="utils">

    <xsl:variable name="index-type">
        <xsl:choose>
            <xsl:when test="/term">term</xsl:when>
            <xsl:when test="/special-section">special-section</xsl:when>
            <xsl:otherwise>schedule</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <xsl:template match="schedule" mode="index">
        <div class="complete-index">
            <xsl:call-template name="index-summary" />

            <xsl:apply-templates select="term" mode="index">
                <xsl:sort select="@sortkey" />
                <xsl:sort select="@name" />
            </xsl:apply-templates>
        </div>
    </xsl:template>


    <xsl:template match="term" mode="index">
        <xsl:variable name="name" select="concat(@semester, ' ', @year)" />
        <div class="term-section">
            <a name="{utils:make-url($name)}" />
            <h2>
                <xsl:choose>
                    <xsl:when test="count(//term) &gt; 1">
                        <a href="{utils:make-url($name)}/"><xsl:value-of select="$name" /></a>
                        <xsl:if test="@dates">
                            &#160;&#8226;&#160;<span><xsl:value-of select="@dates" /></span>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        Regular Credit Courses
                    </xsl:otherwise>
                </xsl:choose>
            </h2>

            <xsl:call-template name="core-notice" />

            <!-- index of "regular" classes -->
            <xsl:call-template name="index-columns">
                <xsl:with-param name="items" select="division/subject" />
            </xsl:call-template>

            <!-- indexes of special-section classes (Weekend, Distance Learning, etc) -->
            <xsl:apply-templates select="special-section[not(minimester)]" mode="index">
                <xsl:sort select="$name" />
            </xsl:apply-templates>

            <!-- indexes of minimester classes -->
            <xsl:apply-templates select="special-section[minimester]" mode="index" />
        </div>
    </xsl:template>


    <xsl:template match="special-section[minimester]" mode="index">
        <!-- insert an anchor before all of the minimester sections -->
        <a name="minimester" />

        <!-- apply the templates to each minimester we have -->
        <xsl:apply-templates select="minimester" mode="index">
            <xsl:sort select="@sortkey" />
        </xsl:apply-templates>
    </xsl:template>


    <!-- no such thing as minimesters or special-sections anymore
    <xsl:template match="special-section[not(minimester)] | minimester" mode="index">
        <xsl:param name="page-type" tunnel="yes" />

        <div class="special-section">
            <a name="{utils:make-url(@name)}" />

            <xsl:choose>
                <xsl:when test="$page-type = 'subindex'">
                    <h2><xsl:value-of select="@name" /> Courses</h2>
                </xsl:when>
                <xsl:otherwise>
                    <h3><xsl:value-of select="@name" /> Courses</h3>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="index-columns">
                <xsl:with-param name="items" select="subject" />
            </xsl:call-template>
        </div>
    </xsl:template>
    -->


    <xsl:template name="index-columns">
        <xsl:param name="items" />
        <xsl:variable name="half" select="ceiling(count($items) div 2)" />

        <div class="fifty-fifty columns">
            <div class="left column">
                <ul class="index-list">
                    <xsl:for-each select="$items">
                        <xsl:sort select="@name" />
                        <xsl:if test="position() &lt;= $half">
                            <xsl:apply-templates select="." mode="index" />
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </div>
            <div class="right column">
                <ul class="index-list">
                    <xsl:for-each select="$items">
                        <xsl:sort select="@name" />
                        <xsl:if test="position() &gt; $half">
                            <xsl:apply-templates select="." mode="index" />
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
        <a href="#top" class="back-to-top">Back to the top</a>
    </xsl:template>


    <xsl:template match="subject" mode="index">
        <xsl:param name="page-type" tunnel="yes" />
        <xsl:param name="url-root" select="''" tunnel="yes" />

        <xsl:variable name="url">
            <xsl:if test="$multiple-terms and $page-type != 'subindex'">
                <xsl:value-of select="concat(ancestor::term/utils:make-url(@name), '/')" />
            </xsl:if>
            <xsl:if test="ancestor::special-section and not(ancestor::minimester) and $page-type != 'subindex'">
                <xsl:value-of select="concat(ancestor::special-section/utils:make-url(@name), '/')" />
            </xsl:if>
            <xsl:if test="ancestor::minimester and $page-type != 'subindex'">
                <xsl:value-of select="concat(ancestor::minimester/utils:make-url(@name), '/')" />
            </xsl:if>
            <xsl:value-of select="concat(utils:make-url(@name), '.', $ext)" />
        </xsl:variable>

        <li>
            <a href="{$url}"><xsl:value-of select="@name" /></a>
            <xsl:if test="not(ancestor::special-section)">
                <xsl:call-template name="br" />
                <span class="in-division">
                    <xsl:choose>
                        <xsl:when test="ancestor::division">
                            <xsl:value-of select="ancestor::division/@name" />
                        </xsl:when>
                        <xsl:when test="ancestor::special-section">
                            <xsl:value-of select="@division-name" />
                        </xsl:when>
                    </xsl:choose>
                </span>
            </xsl:if>
        </li>
    </xsl:template>



    <xsl:template name="index-summary">
        <xsl:param name="page-type" tunnel="yes" />
        <p>Jump to:
        <xsl:for-each select="if ($multiple-terms) then term else term/special-section">
            <xsl:sort select="@sortkey" />
            <xsl:sort select="@name" />
            <xsl:choose>
                <xsl:when test="minimester">
                    <a href="#minimester">Flex Term Courses</a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="#{utils:make-url(@name)}"><xsl:value-of select="@name" /> Courses</a>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="position() != last()"><xsl:text>&#160;&#160;|&#160;&#160;</xsl:text></xsl:if>
        </xsl:for-each>
        </p>
    </xsl:template>


    <xsl:template name="core-notice">
        <p class="core-notice">
            Look for <a href="/course-schedules/credit/core/">Core Curriculum</a> courses highlighted in gold.
        </p>
    </xsl:template>
</xsl:stylesheet>
