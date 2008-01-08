<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Output parameters -->
<xsl:output method="html"
	encoding="utf-8"
	indent="yes"
	omit-xml-declaration="yes"
	doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
	doctype-system="http://www.w3.org/TR/html4/loose.dtd" />
<!-- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> -->
<!-- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"> -->

<!-- date modified, formatted appropriately -->
<xsl:param name="date" />

<!-- which letter we're dealing with -->
<xsl:param name="letter">
	<xsl:value-of select="/alphagroup/@letter" />
</xsl:param>

    <xsl:template match="/">
        <xsl:apply-templates select="alphagroup" mode="init" />
    </xsl:template>
    
    <xsl:template match="alphagroup" mode="init">
        <xsl:call-template name="page-template" />
    </xsl:template>
    

    <xsl:template match="alphagroup">
        <xsl:choose>
            <xsl:when test="employee">
                <xsl:apply-templates select="employee">
                    <xsl:sort select="LastName" order="ascending" />
                    <xsl:sort select="FirstName" order="ascending" />
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <p>There are no employees with last names beginning with <xsl:value-of select="$letter"/></p>
            </xsl:otherwise>
        </xsl:choose>
        
        <xsl:call-template name="navigation" />
    </xsl:template>


    <xsl:template match="employee">
        <div class="employee">
            <table border="0" cellpadding="0" cellspacing="0">
            <tr>
                <td valign="top">
                    <xsl:choose>
                        <xsl:when test="@PhotoPath">
                            <div class="portrait">
                            <xsl:element name="img">
                                <xsl:attribute name="src"><xsl:value-of select="@PhotoPath" /></xsl:attribute>
                                <xsl:attribute name="width">80</xsl:attribute>
                                <xsl:attribute name="height">108</xsl:attribute>
                            </xsl:element>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="no-portrait">&#160;</div>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
    
                <td valign="top">
                <dl>
                    <dt><xsl:value-of select="FirstName" /><xsl:text> </xsl:text><xsl:value-of select="LastName" /></dt>
                    <dd class="division"><xsl:value-of select="Division" /></dd>
                    <dd class="title"><xsl:value-of select="Title" /></dd>
                    <dd class="contact">Ext. <xsl:value-of select="Extension"/>, <xsl:value-of select="Room"/></dd>
                    <dd class="email"><a href="mailto:{EmailNickname}"><xsl:value-of select="EmailNickname" /></a></dd>
                </dl>
                </td>
            </tr>
            </table>
        </div>
    </xsl:template>


    
    <xsl:template name="navigation">
        <div class="navigation">
            <xsl:if test="@previous">
                <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:value-of select="@previous" /></xsl:attribute>
                    &#171; Previous Page
                </xsl:element>
                &#160;&#160;|&#160;
            </xsl:if>
            <a href="#top">Top of Page</a>
            <xsl:if test="@next">
                &#160;&#160;|&#160;
                <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:value-of select="@next" /></xsl:attribute>
                    Next Page &#187;
                </xsl:element>
            </xsl:if>
        </div>
    </xsl:template>
    
    
    <xsl:template name="page-template">
        <html>
            <head>
                <title>Employee Directory: Letter <xsl:value-of select="@letter" /> - Brookhaven College Employee Intranet</title>
                
                <!-- sitewide stylesheets -->
                <link rel="stylesheet" type="text/css" href="/intranet/dcccd/bhc/chatter/css/base.css" />
                <link rel="stylesheet" type="text/css" href="/intranet/dcccd/bhc/chatter/css/header-footer.css" />
                
                <!-- staff directory stylesheet -->
                <link rel="stylesheet" type="text/css" href="css/staff-directory.css" />
                
                <meta http-equiv="imagetoolbar" content="no" />
                <meta http-equiv="Pragma" content="no-cache" />
            </head>
            <body class="with-sidebar">
                <div id="sitewide-header"><a name="top" id="top"></a><h1><a href="http://www.BrookhavenCollege.edu/"><img src="/images/bhc/sitewide/logo+wordmks/bhcwdmrk04.gif" alt="Brookhaven College" border="0" width="227" height="37" /></a></h1>
                </div>
                <hr />
                
                <div id="sitewide-nav">
                    <a href="/intranet/dcccd/bhc/">Intranet Home Page</a>&#160;&#160;|&#160;
                    <a href="/intranet/dcccd/bhc/mission.html">Mission</a>&#160;&#160;|&#160;
                    <a href="/intranet/dcccd/bhc/cal.html">Calendars</a>&#160;&#160;|&#160;
                    <a href="/intranet/dcccd/bhc/onepg04intro.html">Planning</a>&#160;&#160;|&#160;
                    <a href="/intranet/dcccd/bhc/chatter/chat.html">Courtyard&#160;Chatter</a>&#160;&#160;|&#160;
                    <a href="/intranet/dcccd/bhc/resource/reso.html">Resources</a>&#160;&#160;|&#160;
                    <a href="/intranet/bhc/sdir/sdir.html">Directories</a>&#160;&#160;|&#160;
                    <a href="/intranet/dcccd/bhc/emp_inclementweather.html">Emergencies&#160;&amp;&#160;Bad&#160;Weather</a>&#160;&#160;|&#160;
                    <a href="http://dsc3.dcccd.edu/intranet/dcccd/" target="_blank">DCCCD&#160;Intranet</a></div>
                <hr />
                
                <!-- include the subnavigation -->
                <div id="sitewide-subnav">
                    <a href="/intranet/dcccd/bhc/resource/emergenc.html">Medical Emergency Procedures</a>&#160;&#160;|&#160; 
                    <a href="/intranet/dcccd/bhc/ferpa/">FERPA Training</a>&#160;&#160;|&#160; 
                    <a href="/intranet/dcccd/bhc/hazmat/sld001.htm">HazMat Training</a>&#160;&#160;|&#160; 
                    <a href="http://www.BrookhavenCollege.edu/profdev/">Professional Development</a>&#160;&#160;|&#160; 
                    <a href="/intranet/dcccd/bhc/#planning">Calendars</a>&#160;&#160;|&#160; 
                    <a href="http://www.BrookhavenCollege.edu/sacs/sacs.html">SACS Self-Study</a></div>
                <hr />
                
                <div id="channel-header">
                    <h1>Employee Directory</h1>
                </div>
                
                <div id="page-container">
                    <div id="page-header">
                        <div id="breadcrumbs">
                            <a href="/intranet/dcccd/bhc/">Home</a>&#160;&#160;&#187;&#160;
                            <a href="sdir.html">Employee Directory</a>&#160;&#160;&#187;&#160;
                            <a class="selected">Letter <xsl:value-of select="@letter" /></a>
                        </div>
                        <h1>Letter <xsl:value-of select="@letter" /></h1>
                    </div>
                    
                    <div id="page-content">
                        <div class="alphabetical-index">
                            <a href="sdir_a.html">A</a>&#160;
                            <a href="sdir_b.html">B</a>&#160;
                            <a href="sdir_c.html">C</a>&#160;
                            <a href="sdir_d.html">D</a>&#160;
                            <a href="sdir_e.html">E</a>&#160;
                            <a href="sdir_f.html">F</a>&#160;
                            <a href="sdir_g.html">G</a>&#160;
                            <a href="sdir_h.html">H</a>&#160;
                            <a href="sdir_i.html">I</a>&#160;
                            <a href="sdir_j.html">J</a>&#160;
                            <a href="sdir_k.html">K</a>&#160;
                            <a href="sdir_l.html">L</a>&#160;
                            <a href="sdir_m.html">M</a>&#160;
                            <a href="sdir_n.html">N</a>&#160;
                            <a href="sdir_o.html">O</a>&#160;
                            <a href="sdir_p.html">P</a>&#160;
                            <a href="sdir_q.html">Q</a>&#160;
                            <a href="sdir_r.html">R</a>&#160;
                            <a href="sdir_s.html">S</a>&#160;
                            <a href="sdir_t.html">T</a>&#160;
                            <a href="sdir_u.html">U</a>&#160;
                            <a href="sdir_v.html">V</a>&#160;
                            <a href="sdir_w.html">W</a>&#160;
                            <a href="sdir_x.html">X</a>&#160;
                            <a href="sdir_y.html">Y</a>&#160;
                            <a href="sdir_z.html">Z</a>&#160;
                        </div>
                        
                        
                        <!-- insert the page content -->
                        <xsl:apply-templates select="." />
                        
                        
                        <div class="alphabetical-index">
                            <a href="sdir_a.html">A</a>&#160;
                            <a href="sdir_b.html">B</a>&#160;
                            <a href="sdir_c.html">C</a>&#160;
                            <a href="sdir_d.html">D</a>&#160;
                            <a href="sdir_e.html">E</a>&#160;
                            <a href="sdir_f.html">F</a>&#160;
                            <a href="sdir_g.html">G</a>&#160;
                            <a href="sdir_h.html">H</a>&#160;
                            <a href="sdir_i.html">I</a>&#160;
                            <a href="sdir_j.html">J</a>&#160;
                            <a href="sdir_k.html">K</a>&#160;
                            <a href="sdir_l.html">L</a>&#160;
                            <a href="sdir_m.html">M</a>&#160;
                            <a href="sdir_n.html">N</a>&#160;
                            <a href="sdir_o.html">O</a>&#160;
                            <a href="sdir_p.html">P</a>&#160;
                            <a href="sdir_q.html">Q</a>&#160;
                            <a href="sdir_r.html">R</a>&#160;
                            <a href="sdir_s.html">S</a>&#160;
                            <a href="sdir_t.html">T</a>&#160;
                            <a href="sdir_u.html">U</a>&#160;
                            <a href="sdir_v.html">V</a>&#160;
                            <a href="sdir_w.html">W</a>&#160;
                            <a href="sdir_x.html">X</a>&#160;
                            <a href="sdir_y.html">Y</a>&#160;
                            <a href="sdir_z.html">Z</a>&#160;
                        </div>
                    </div>
                </div>
                <hr />
                
                
                <div id="sidebar">
                    <ul>
                        <li><a href="/intranet/dcccd/bhc/">Brookhaven College Employee Intranet</a></li>
                        <li><a href="/intranet/dcccd/bhc/#planning">Calendars</a></li>
                        <li><a href="/intranet/dcccd/bhc/mission.html">College Mission</a></li>
                        <li><a href="/intranet/dcccd/bhc/chatter/chat.html"><i>Courtyard Chatter</i></a></li>
                        <li><a href="/intranet/bhc/sdir/sdir.html">Employee Directory</a></li>
                        <li><a href="/intranet/dcccd/bhc/ferpa/">FERPA Training</a></li>
                        <li><a href="/intranet/dcccd/bhc/hazmat/sld001.htm">HazMat Training</a></li>
                        <li><a href="/intranet/dcccd/bhc/emp_inclementweather.html">Inclement Weather Hotline Procedures</a></li>
                        <li><a href="/intranet/dcccd/bhc/resource/emergenc.html">Medical Emergency Procedures</a></li>
                        <li><a href="/intranet/dcccd/bhc/onepg04intro.html">One-page Plan</a></li>
                        <li><a href="http://www.BrookhavenCollege.edu/profdev/">Professional Development</a></li>
                        <li><a href="https://www1.dcccd.edu/bhc/bhc_quickcall/index.cfm" target="_blank">Quick Call Roster</a></li>
                        <li><a href="/intranet/dcccd/bhc/">Resources</a></li>
                        <li><a href="http://www.BrookhavenCollege.edu/sacs/sacs.html">SACS Self-Study</a></li>
                        <li><a href="http://www.brookhavencollege.edu/" target="_blank">Brookhaven College Home Page</a></li>
                        <li><a href="http://dsc3.dcccd.edu/intranet/dcccd/" target="_blank">DCCCD Employee Intranet</a></li>
                        <li><a href="http://www.dcccd.edu/Employees/" target="_blank">DCCCD Employee Channel</a></li>
                    </ul>
                </div>
                
                
                <hr />
                <div id="sitewide-footer">
                    <p>
                        <a href="http://www.dcccd.edu/" target="_blank">Dallas County Community College District</a>&#160;&#160;|&#160;
                        <a href="http://www.brookhavencollege.edu/" target="_blank">Brookhaven College Home Page</a>&#160;&#160;|&#160;
                        <a href="http://www.brookhavencollege.edu/AtoZ/" target="_blank">A-Z Index</a>
                    </p>
                    <p>Comments/questions about this site, e-mail the Brookhaven College <a href="mailto:MonicaT@dcccd.edu">Marketing and Public Information Office</a>
                        or call 972-860-4700.</p>
                    <p>Brookhaven College main campus: 3939 Valley View Lane, Farmers Branch, Dallas, TX 75244-4997 | Telephone: 972-860-4700</p>
                    <p>Page modified <xsl:value-of select="$date" />.</p>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>