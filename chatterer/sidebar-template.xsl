<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:template name="sidebar-template">
        <xsl:param    name="url-prefix" select="$default-url-prefix"     as="xs:string" tunnel="yes" />
        <xsl:variable name="this-issue" select="ancestor-or-self::issue" as="element()"              />
        
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
				
    </xsl:template>
</xsl:stylesheet>