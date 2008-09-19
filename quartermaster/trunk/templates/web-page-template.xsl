<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template name="page-template">
        <xsl:param name="page-title" />

        <xsl:call-template name="aspx-preamble" />

        <html>
            <head>
                <xsl:call-template name="aspx-meta">
                    <xsl:with-param name="page-title"><xsl:value-of select="$channel-title" /><xsl:text>: </xsl:text><xsl:value-of select="$page-title" /></xsl:with-param>
                </xsl:call-template>
                <link rel="stylesheet" type="text/css" href="css/new-cce-schedule.css" media="screen, projection" />
            </head>

            <body>
                <xsl:call-template name="aspx-header" />

                <div id="channel-header">
                    <h1><xsl:value-of select="$channel-title" /></h1>
                </div>

                <table id="sidebar-layout-table" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td id="sidebar-in-table" valign="top">
                            <xsl:call-template name="aspx-sidebar" />
                        </td>

                        <td id="page-container" valign="top">
                            <div id="page-header">
                                <xsl:call-template name="make-breadcrumbs" />
                                <h1><xsl:value-of select="$page-title" /></h1>
								
								<!-- only output the Youth Summer Program link if we're in the Youth Summer
									 Program page -->
								<xsl:if test="ancestor-or-self::division/@name = 'YOUTH SUMMER PROGRAM'">
									<p><a href="/instruction/cce/youth-summer-program/">Click here for Youth Summer Program Brochure and Forms</a></p>
								</xsl:if>

                                <!-- only output the financial aid notice in the header if this page has
                                     financial aid courses or is the main schedule index. -->
                                <xsl:if test="current()//course[@financial_aid] or current()/self::schedule">
                                    <p class="financial-aid">Look for courses eligible for <a href="/instruction/cce/financial-aid">Financial Aid</a> highlighted in green.<br />
                                        <strong>NOTE:</strong> When filing for financial aid, note the term in which the class is offered. Class term and financial aid terms MUST match.</p>
                                </xsl:if>
                            </div>

                            <div id="page-content">
                                <xsl:apply-templates select="." />
                            </div><!-- end page-content -->
                        </td><!-- page-container -->
                    </tr>
                </table>

                <!-- include the sitewide footer -->
                <xsl:call-template name="aspx-footer" />
            </body>
        </html>
    </xsl:template>


    <xsl:template name="make-breadcrumbs">
        <div id="breadcrumbs">
            <a href="/course-schedules/">Course Schedules</a>&#160;&#160;&#187;&#160;
            <xsl:choose>
                <xsl:when test="not(@machine_name)">
                    <a href="/course-schedules/non-credit/" class="selected">Workforce &amp; Continuing Education</a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="/course-schedules/non-credit/">Workforce &amp; Continuing Education</a>&#160;&#160;&#187;&#160;
                    <a href="{@machine_name}.aspx" class="selected"><xsl:value-of select="@name" /></a>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="aspx-preamble">
        <xsl:text disable-output-escaping="yes">&lt;%@ register tagprefix="bhc" tagname="header" src="~/includes/header.ascx" %&gt;
            &lt;%@ register tagprefix="bhc" tagname="meta" src="~/includes/meta.ascx" %&gt;
            &lt;%@ register tagprefix="bhc" tagname="footer" src="~/includes/footer.ascx" %&gt;
            &lt;%@ register tagprefix="bhc" tagname="sidebar" src="sidebar.ascx" %&gt;
</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-meta">
        <xsl:param name="page-title" />
        <xsl:text disable-output-escaping="yes">
&lt;bhc:meta title="</xsl:text><xsl:value-of select="$page-title" /><xsl:text disable-output-escaping="yes">" runat="server" /&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-header">
        <xsl:text disable-output-escaping="yes">
&lt;bhc:header runat="server" /&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-sidebar">
        <xsl:text disable-output-escaping="yes">
&lt;bhc:sidebar runat="server" /&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="aspx-footer">
        <xsl:text disable-output-escaping="yes">
&lt;bhc:footer runat="server" /&gt;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
