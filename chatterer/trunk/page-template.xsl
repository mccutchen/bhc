<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:template name="page-template">
        <xsl:param    name="page-title" select="$default-page-title"     as="xs:string" />
        <xsl:variable name="this-issue" select="ancestor-or-self::issue" as="element()" />
        
        <div class="asp">%@ Register tagprefix="bhc" Tagname="meta" src="~/includes/meta.ascx"                 </div>
        <xsl:choose>
        <xsl:when test="self::issue">
        <div class="asp">%@ Register tagprefix="bhc" Tagname="header" src="/chatter/includes/header_index.ascx"</div>
        </xsl:when>
        <xsl:otherwise>
        <div class="asp">%@ Register tagprefix="bhc" Tagname="header" src="/chatter/includes/header_story.ascx"</div>
        </xsl:otherwise>
        </xsl:choose>
        <div class="asp">%@ Register tagprefix="bhc" Tagname="sidebar" src="sidebar.ascx"</div>
        <div class="asp">%@ Register tagprefix="bhc" Tagname="footer"  src="footer.ascx" </div>

        <html>
            <head>
                <xsl:choose>
                <xsl:when test="$page-title">
                <div class="asp-bhc">:meta title="Courtyard Chatter: <xsl:value-of select="$page-title" />" runat="server"</div>
                </xsl:when>
                <xsl:otherwise>
                <div class="asp-bhc">:meta title="Courtyard Chatter" runat="server"</div>
                </xsl:otherwise>
                </xsl:choose>
                <link rel="stylesheet" type="text/css" href="/chatter/css/base.css"          />
                <link rel="stylesheet" type="text/css" href="/chatter/css/header-footer.css" />
                <link rel="stylesheet" type="text/css" href="/chatter/css/chatter.css"       />
                <script language="c#" src="/chatter/includes/chatter.cs" runat="server" type="text/cs"></script>
            </head>

            <body class="with-sidebar">
				<!-- for tables and other iteration tasks -->
				<div class="asp">% int i = 0;</div>
			
                <!-- the sitewide header -->
                <div class="asp-bhc">:header runat="server"</div>
                
               
                <!-- the dateline -->
                <div id="sitewide-subnav">
                    Brookhaven College employee newsletter: <xsl:value-of select="if ($this-issue/@day) then $this-issue/@day else $default-day" />, <xsl:value-of select="$this-issue/@date" />
                </div>
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
                
                <!-- the sitewide sidebar -->
                <div class="asp-bhc">:sidebar runat="server" </div>
                
                <!-- the sitewide footer -->
                <div class="asp-bhc">:footer runat="server" </div>
                
            </body>
        </html>
    </xsl:template>

    <xsl:template match="article | feature" mode="sidebar">
        <li><a href="{@id}{$output-extension}"><xsl:value-of select="title" /></a></li>
    </xsl:template>

    <xsl:template match="feature[@id='announcements']" mode="sidebar">
        <li><a href="{@id}{$output-extension}"><xsl:value-of select="title" /></a>
            <ul>
                <xsl:for-each select="announcement">
                    <li><a href="{parent::feature/@id}{$output-extension}#{@id}"><xsl:value-of select="title" /></a></li>
                </xsl:for-each>
            </ul>
        </li>
    </xsl:template>
</xsl:stylesheet>