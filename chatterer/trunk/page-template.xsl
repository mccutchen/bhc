<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:template name="page-template">
        <xsl:param name="page-title" select="$default-page-title" as="xs:string" />
        <xsl:param name="url-prefix" select="$default-url-prefix" as="xs:string" tunnel="yes" />
        <xsl:variable name="this-issue" select="ancestor-or-self::issue" as="element()" />

        <html>
            <head>
                <title>Courtyard Chatter<xsl:if test="$page-title">: <xsl:value-of select="$page-title" /></xsl:if></title>
                <meta http-equiv="imagetoolbar" content="no" />
                <meta http-equiv="Pragma" content="no-cache" />
                <link rel="stylesheet" type="text/css" href="/chatter/css/base.css" />
                <link rel="stylesheet" type="text/css" href="/chatter/css/header-footer.css" />
                <link rel="stylesheet" type="text/css" href="/chatter/css/chatter.css" />
            </head>

            <body class="with-sidebar">
                <!-- the sitewide header -->
                <div id="sitewide-header">
                    <a name="top" id="top"></a>
                    <h1><a href="http://www.BrookhavenCollege.edu/"><img src="/images/bhc/logos/bhc-logo-2004-trimmed.gif" alt="Brookhaven College" border="0" width="227" height="37" /></a></h1>
                </div>
                <hr />

                <!-- the navigation -->
                <div id="sitewide-nav">
                <a href="http://intranet.bhc.dcccd.edu/intranet/dcccd/bhc/mission.html">Mission</a>&#160;&#160;|&#160;
                <a href="http://intranet.bhc.dcccd.edu/intranet/dcccd/bhc/cal.html">Calendars</a>&#160;&#160;|&#160;
                <a href="http://intranet.bhc.dcccd.edu/intranet/dcccd/bhc/onepg04intro.html">Planning</a>&#160;&#160;|&#160;
                <a href="/chatter/">Courtyard&#160;Chatter</a>&#160;&#160;|&#160;
                <a href="http://intranet.bhc.dcccd.edu/intranet/dcccd/bhc/resource/reso.html">Resources</a>&#160;&#160;|&#160;
                <a href="http://intranet.bhc.dcccd.edu/intranet/bhc/sdir/sdir.html">Directories</a>&#160;&#160;|&#160;
                <a href="http://intranet.bhc.dcccd.edu/intranet/dcccd/bhc/emp_inclementweather.html">Emergencies&#160;&amp;&#160;Bad&#160;Weather</a>&#160;&#160;|&#160;
                <a href="http://dsc3.dcccd.edu/intranet/dcccd/" target="_blank">DCCCD&#160;Intranet</a>
                </div>
                <hr />

                <!-- if we're on the index page, insert the masthead -->
                <xsl:if test="self::issue">
                    <div id="channel-header">
                        <h1><img src="/images/bhc/chatter/masthead-gray.gif" alt="Courtyard Chatter" width="374" height="72" border="0" /></h1>
                    </div>
                </xsl:if>

                <!-- the dateline -->
                <div id="sitewide-subnav">Brookhaven College employee newsletter: <xsl:value-of select="if ($this-issue/@day) then $this-issue/@day else $default-day" />, <xsl:value-of select="$this-issue/@date" /></div>
                <hr />

                <!-- page content -->
                <div id="page-container">
                    <!-- only output a page-header if we're not on an index page -->
                    <xsl:if test="not(self::issue)">
                        <div id="page-header">
                            <h1>Courtyard Chatter</h1>
                        </div>
                    </xsl:if>

                    <div id="page-content">
                        <!-- apply-templates to the element that called this template -->
                        <xsl:apply-templates select="." />
                    </div>
                </div>
                <hr />

                <!-- sidebar -->
                <div id="sidebar">
                    <h3>Regular Features</h3>
                    <ul>
                        <xsl:apply-templates select="$this-issue/features/feature" mode="sidebar">
                            <!-- <xsl:sort select="@id" /> -->
                            <!-- <li><a href="{$url-prefix}{@id}{$output-extension}"><xsl:value-of select="title" /></a></li> -->
                        </xsl:apply-templates>
                    </ul>

                    <h3>This Issue</h3>
                    <ul>
                        <li>
                            <xsl:variable name="index-url">
                                <xsl:choose> 
                                    <xsl:when test="self::issue and $url-prefix != ''"><xsl:value-of select="$url-prefix" /></xsl:when>
                                    <xsl:otherwise>./</xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <a href="{$index-url}">Front Page</a>
                        </li>
                        <xsl:apply-templates select="$this-issue/articles/article" mode="sidebar" />
                    </ul>

                    <h3>Archive</h3>
                    <ul>
                        <li><a href="/chatter/">Courtyard Chatter Archive</a></li>
                    </ul>
                </div>

                <!-- sitewide footer -->
                <hr />
                <div id="sitewide-footer">
                    <p>Page modified <xsl:value-of select="$this-issue/@date" />.</p>
                    <p>Published biweekly by the Marketing and Public Information Office. Previous issues of the Courtyard Chatter are available in the <a href="/chatter/">Chatter Archive</a>.</p>
                    <p>E-mail your comments, suggestions, story ideas, news tips and other submissions for the <i>Courtyard Chatter</i> to the Marketing and Public Information Office:</p>            
                    <ul>
                        <li>editor, <i>Courtyard Chatter</i>, <a href="mailto:bhcChatter@dcccd.edu">bhcChatter@dcccd.edu</a>, or</li>
                        <li>director, Marketing and Public Information, <a href="mailto:bhcInfo@dcccd.edu">bhcInfo@dcccd.edu</a>.</li>
                    </ul>
                    <p>Deadline for submissions is 3 p.m. the Thursday before publication.</p>
                    <p>Please report technical difficulties to <a href="mailto:bhcWebmaster@dcccd.edu">bhcWebmaster@dcccd.edu</a>.</p>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="article | feature" mode="sidebar">
        <xsl:param name="url-prefix" select="'yyy'" as="xs:string" tunnel="yes" />
        <li><a href="{$url-prefix}{@id}{$output-extension}"><xsl:value-of select="title" /></a></li>
    </xsl:template>

    <xsl:template match="feature[@id='announcements']" mode="sidebar">
        <xsl:param name="url-prefix" as="xs:string" tunnel="yes" />
        <li><a href="{$url-prefix}{@id}{$output-extension}"><xsl:value-of select="title" /></a>
            <ul>
                <xsl:for-each select="announcement">
                    <li><a href="{$url-prefix}{parent::feature/@id}{$output-extension}#{@id}"><xsl:value-of select="title" /></a></li>
                </xsl:for-each>
            </ul>
        </li>
    </xsl:template>
</xsl:stylesheet>
