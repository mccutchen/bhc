<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:template name="page-template">
        <xsl:param name="page-title" select="@name" />

        <xsl:call-template name="aspx-preamble" />

        <html>
            <head>
                <xsl:call-template name="aspx-meta">
                    <xsl:with-param name="page-title" select="$page-title" />
                </xsl:call-template>

                <!-- schedule-specific stylesheet -->
                <link rel="stylesheet" type="text/css" href="/course-schedules/credit/schedule.css" />
            </head>

            <body>

                <xsl:call-template name="aspx-header" />

                <div id="channel-header" class="course-schedules">
                    <h1><xsl:value-of select="$channel-header" /></h1>
                </div>

                <table id="sidebar-layout-table" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td id="sidebar-in-table" valign="top">
                            <xsl:call-template name="aspx-sidebar" />
                        </td>

                        <td id="page-container" valign="top">

                            <div id="page-header">
                                <xsl:call-template name="make-breadcrumbs" />
                                <h1 class="division"><xsl:value-of select="$page-title" /></h1>
                            </div>

                            <div id="page-content">

                                <xsl:call-template name="special-notice" />

                                <xsl:choose>
                                    <xsl:when test="self::schedule or self::term or self::special-section or self::minimester">
                                        <xsl:apply-templates select="." mode="index" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="." />
                                    </xsl:otherwise>
                                </xsl:choose>

                            </div><!-- end page-content -->
                        </td><!-- page-container -->
                    </tr>
                </table>


                <xsl:call-template name="aspx-footer" />
            </body>
        </html>
    </xsl:template>

    <xsl:template name="special-notice">
        <p class="special-notice">For a live version of the Credit Course Schedule, use <a href="http://econnect.dcccd.edu" target="_blank">eConnect</a>.</p>
    </xsl:template>

    <xsl:template name="preview-special-notice">
        <p class="special-notice">
        	<xsl:text>Registration for continuing students begins April 18.</xsl:text>
        	<xsl:call-template name="br" />
        	<xsl:text>Registration for new students begins April 24.</xsl:text>
        </p>
    </xsl:template>

    <xsl:template name="make-breadcrumbs">
        <!-- <xsl:param name="page-type" tunnel="yes" /> -->
        <xsl:param name="path-root" tunnel="yes" />

        <xsl:variable name="steps" select="tokenize($path-root, '/')" />

        <xsl:variable name="parent-names" select="if ($multiple-terms) then (for $parent in (ancestor::element() except (ancestor::schedule, ancestor::division)) return $parent) else (for $parent in (ancestor::element() except (ancestor::schedule, ancestor::division, ancestor::term)) return $parent)" />

        <xsl:variable name="schedule-root">
            <xsl:value-of select="if ($parent-names) then string-join(for $x in $parent-names return '../', '') else '../'" />
        </xsl:variable>

        <div id="breadcrumbs">
            <a href="/">Home</a>&#160;&#160;&#187;&#160;
            <a href="/course-schedules/">Course Schedules</a>&#160;&#160;&#187;&#160;

            <!-- Every set of breadcrumbs will start off with a link
                 to this schedule's root or index page.  We just have
                 to determine if we are making the index page or
                 not. -->
            <xsl:choose>
                <xsl:when test="self::schedule">
                    <a class="selected"><xsl:value-of select="$schedule-title" /></a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{$schedule-root}"><xsl:value-of select="$schedule-title" /></a>&#160;&#160;&#187;&#160;
                </xsl:otherwise>
            </xsl:choose>

            <!-- Now we try to figure out what needs to come after the
                 link to this schedule's root in the breadcrumbs. -->

            <xsl:for-each select="$parent-names">
                <xsl:variable name="index" select="position()" />
                <xsl:variable name="last-index" select="last()" />
                <xsl:variable name="current-url" select="string-join(for $x in (0 to (count($parent-names) - position())) return (if (position() = last()) then './' else '../'), '')" />
                <a href="{$current-url}"><xsl:value-of select="@name" /></a>&#160;&#160;&#187;&#160;
            </xsl:for-each>

            <a class="selected"><xsl:value-of select="@name" /></a>
        </div>
    </xsl:template>



    <!-- ======================================================================
         ASP.NET-related templates

         These are used to generate the ASP.NET parts of the page template,
         which are invalid and need to be output as non-escaped text.
         ======================================================================= -->
    <xsl:template name="aspx-preamble">
         <!-- this generates an error because it's a text node outside of the root node. However, wrapping it in a comment works because
              xhtml comments can appear anywhere, but ASPX evaluates code inside comments just fine. -->
        <xsl:comment>
        <xsl:text disable-output-escaping="yes">&lt;%@ register tagprefix="bhc" tagname="header" src="~/includes/header.ascx" %&gt;
        &lt;%@ register tagprefix="bhc" tagname="meta" src="~/includes/meta.ascx" %&gt;
        &lt;%@ register tagprefix="bhc" tagname="footer" src="~/includes/footer.ascx" %&gt;

        &lt;%@ register tagprefix="bhc" tagname="sidebar" src="~/course-schedules/credit/sidebar.ascx" %&gt;
        </xsl:text>
        </xsl:comment>
    </xsl:template>

    <xsl:template name="aspx-meta">
        <xsl:param name="page-title" />
        <xsl:text disable-output-escaping="yes">&lt;bhc:meta title="</xsl:text>
    	<xsl:if test="$enrolling-now">Enrolling Now&#8212;</xsl:if>
    	<xsl:value-of select="$page-title" />
    	<xsl:text disable-output-escaping="yes">" runat="server" /&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-header">
        <xsl:text disable-output-escaping="yes">&lt;bhc:header searchPath="~/course-schedules/credit/" runat="server" /&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-footer">
        <xsl:text disable-output-escaping="yes">&lt;bhc:footer runat="server" /&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-sidebar">
        <xsl:text disable-output-escaping="yes">&lt;bhc:sidebar runat="server" /&gt;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
