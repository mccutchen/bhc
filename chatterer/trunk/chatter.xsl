<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
	version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs">

	<xsl:output
		method="xhtml"
		encoding="us-ascii"
		indent="yes"
		omit-xml-declaration="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />

	<xsl:include href="page-template.xsl"    />
	<xsl:include href="sidebar-template.xsl" />
	<xsl:include href="footer-template.xsl"  />

	<xsl:param name="output-extension">.aspx</xsl:param>
	<xsl:param name="output-directory">chatter-output</xsl:param>
	<xsl:param name="chatter-image-url-prefix">/images/bhc/chatter/07/</xsl:param>
	<xsl:param name="default-page-title" select="''" />
	<xsl:param name="default-url-prefix" select="''" />
	
	<!-- DEV NOTE: Replace these! -->
	<xsl:param name="default-day">Wednesday</xsl:param>
	<xsl:param name="year">07</xsl:param>


	<!-- set up the different output documents -->
	<xsl:template match="/">
		<xsl:apply-templates select="chatter/issue | chatter/issue/articles/article | chatter/issue/features/feature" mode="init" />
	</xsl:template>

	<xsl:template match="issue" mode="init">
		<xsl:message>Creating <xsl:value-of select="@date" /> issue</xsl:message>
		
		<!-- index -->
		<xsl:result-document href="{$output-directory}/{@url}/index{$output-extension}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="'Front Page'" as="xs:string" />
			</xsl:call-template>
		</xsl:result-document>

		<!-- sidebar -->
		<xsl:result-document href="{$output-directory}/{@url}/sidebar.ascx">
			<xsl:call-template name="sidebar-template" />
		</xsl:result-document>
		<!-- footer -->
		<xsl:result-document href="{$output-directory}/{@url}/footer.ascx">
			<xsl:call-template name="footer-template">
				<xsl:with-param name="issue-date" select="@date" as="xs:string" />
			</xsl:call-template>
		</xsl:result-document>
	</xsl:template>

	<!-- story pages -->
	<xsl:template match="article[not(@id = //feature/@id)] | feature" mode="init">
		<xsl:message>Creating <xsl:value-of select="local-name()" /><xsl:text> </xsl:text><xsl:value-of select="@id" /></xsl:message>
		<xsl:result-document href="{$output-directory}/{ancestor::issue/@url}/{@id}{$output-extension}">
			<xsl:call-template name="page-template">
				<xsl:with-param name="page-title" select="title" as="xs:string"  />
			</xsl:call-template>
		</xsl:result-document>
	</xsl:template>


	<!-- ===================== -->
	<!-- Create an issue index -->
	<!-- ===================== -->
	<xsl:template match="issue">
		<!-- generate the entire index as one list of articles and store it in $entire-list -->
		<xsl:variable name="entire-index">
			<xsl:apply-templates select="articles/article | articles/standalone-article" mode="index" />
		</xsl:variable>

		<xsl:variable name="all-articles" select="$entire-index/div[contains(@class, 'article')]" />

		<!-- find the middle element, used to split the index generated above -->
		<xsl:variable name="midpoint-offset" select="0" /><!-- for hand-tweaking the columns, if necessary -->
		<xsl:variable name="midpoint-index" select="round(count($all-articles) div 2) + $midpoint-offset" />
		<xsl:variable name="midpoint-element" select="$all-articles[$midpoint-index]" />

		<!-- produce the actual column'd structure, putting each part of the index in $entire-index on its own side -->
		<div class="sixty-forty columns">
			<div class="left column">
				<xsl:copy-of select="$midpoint-element | $midpoint-element/preceding-sibling::div[contains(@class, 'article')]" />
			</div>
			<div class="right column">
				<xsl:copy-of select="$midpoint-element/following-sibling::div[contains(@class, 'article')]" />
			</div>
		</div>
	</xsl:template>

	<xsl:template match="article" mode="index">
		<!-- the first article gets a $classname of "lead article" instead of "article" -->
		<xsl:variable name="classname" as="xs:string">
			<xsl:choose>
				<xsl:when test="position() = 1"><xsl:text>lead article</xsl:text></xsl:when>
				<xsl:otherwise><xsl:text>article</xsl:text></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<div class="{$classname}">
			<xsl:apply-templates select="title" mode="index" />
			<xsl:apply-templates select="byline" mode="index" />
			<xsl:apply-templates select="img[1]" mode="index" />

			<!-- use either the provided intro or the first paragraph of the body as the intro text -->
			<xsl:choose>
				<xsl:when test="intro">
					<xsl:apply-templates select="intro" mode="index" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="body/p[1]" mode="index" />
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<!-- standalone articles are boxed on the index page and don't get their own pages generated -->
	<xsl:template match="standalone-article" mode="index">
		<div class="standalone-article">
			<xsl:apply-templates select="body" />
		</div>
	</xsl:template>

	<!-- by default, templates with mode="index" just call their modeless counterparts -->
	<xsl:template match="*" mode="index">
		<xsl:apply-templates select="." />
	</xsl:template>

	<xsl:template match="title" mode="index">
		<h2><a href="{ancestor::article/@id}{$output-extension}"><xsl:value-of select="." /></a></h2>
	</xsl:template>

	<xsl:template match="intro | body/p[1]" mode="index">
		<xsl:choose>
			<xsl:when test="not(p)">
				<p>
					<!-- <xsl:apply-templates select="ancestor-or-self::article/body//img[1]" /> -->
					<xsl:apply-templates />
					<xsl:call-template name="read-more-link" />
				</p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
				<xsl:call-template name="read-more-link" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- template to add a "read more" link to the articles on the index -->
	<xsl:template name="read-more-link">
		<xsl:text>&#160; </xsl:text><a href="{ancestor::article/@id}{$output-extension}">Read&#160;More&#160;»</a>
	</xsl:template>




	<!-- ======================= -->
	<!-- Build each article page -->
	<!-- ======================= -->
	<xsl:template match="article">
		<xsl:apply-templates select="title" />
		<xsl:apply-templates select="byline" />
		<xsl:apply-templates select="img" />
		<xsl:apply-templates select="body" />
	</xsl:template>




	<!-- ============================== -->
	<!-- Basic building-block templates -->
	<!-- ============================== -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" />
		</xsl:copy>
	</xsl:template>

	<xsl:template match="title">
		<h2><xsl:value-of select="." /></h2>
	</xsl:template>

	<xsl:template match="byline">
		<h3 class="byline"><xsl:value-of select="." /></h3>
	</xsl:template>

	<!-- ensures these elements contain at least one <p> -->
	<xsl:template match="body | description">
		<xsl:choose>
			<xsl:when test="not(element())">
				<p><xsl:value-of select="." /></p>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- images are output inside of <div class="photo"> elements, with their @src attributes automatically adjusted -->
	<xsl:template match="img">
		<span class="photo float-right">
			<xsl:copy>
				<xsl:apply-templates select="node()|@*" />
			</xsl:copy>
			<span><xsl:value-of select="@alt" /></span>
		</span>
	</xsl:template>

	<!-- automatically adjust each img's @src -->
	<xsl:template match="img/@src">
		<xsl:variable name="src-prefix" select="concat($chatter-image-url-prefix, ancestor::issue/@url, '/')" />
		<xsl:attribute name="src"><xsl:value-of select="concat($src-prefix, .)" /></xsl:attribute>
	</xsl:template>




	<!-- ======== -->
	<!-- Features -->
	<!-- ======== -->
	<xsl:template match="feature">
		<xsl:apply-templates />
	</xsl:template>

	<!-- events -->
	<xsl:template match="feature[@id='campus-events']/date-group">
		<div class="item">
			<h3><xsl:value-of select="@date" /></h3>
			<ul>
				<xsl:apply-templates select="event" />
			</ul>
		</div>
	</xsl:template>

	<xsl:template match="feature[@id='campus-events']/date-group/event">
		<li>
			<xsl:apply-templates /><xsl:call-template name="br" />
		</li>
	</xsl:template>

	<xsl:template match="feature[@id='campus-events']/date-group/event/element()">
		<xsl:apply-templates />
		<xsl:call-template name="br" />
	</xsl:template>


	<!-- around town -->
	<xsl:template match="feature[@id='around-town']/event">
		<div class="item">
			<xsl:apply-templates select="title" />
			<xsl:apply-templates select="location" />
			<xsl:apply-templates select="date" />
			<xsl:apply-templates select="description" />
		</div>
	</xsl:template>

	<xsl:template match="feature[@id='around-town']/event/title">
		<h3><xsl:apply-templates /></h3>
	</xsl:template>

	<xsl:template match="feature[@id='around-town']/event/location">
		<h4><xsl:apply-templates /></h4>
	</xsl:template>

	<xsl:template match="feature[@id='around-town']/event/date">
		<p class="date"><xsl:apply-templates /></p>
	</xsl:template>

	<xsl:template match="feature[@id='around-town']/event/description">
		<xsl:choose>
			<xsl:when test="p">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<p><xsl:apply-templates /></p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- birthdays -->
	<xsl:template match="feature[@id='birthdays']">
		<xsl:apply-templates select="title" />
			<xsl:if test="@month">
				<p>
					If you have a <xsl:value-of select="@month" /> birthday and are not included in the list below, 
					your employee information in Colleague is marked for privacy. If you would like to make sure that 
					your name is on the birthday listings, please check with the Human Resources Office to change the 
					status on your Colleague information.
				</p>
			</xsl:if>
		<xsl:apply-templates select="*[not(self::title)]" />
	</xsl:template>

	<xsl:template match="birthday-list">
		<div class="asp">% i = 0;</div>
		<table id="birthdays" border="0" cellpadding="10" cellspacing="1">
			<xsl:apply-templates select="birthday" />
		</table>
	</xsl:template>

	<xsl:template match="birthday">
		<tr class="asp:%=GetEO(i++)%">
			<th><xsl:value-of select="@date" /></th>
			<td><xsl:value-of select="@names" /></td>
		</tr>
	</xsl:template>


	<!-- hail and farewell -->
	<xsl:template match="feature[@id='hail-and-farewell']">
		<xsl:apply-templates select="title" />
		<table class="hail-and-farewell" border="0" cellpadding="0" cellspacing="0">
			<xsl:apply-templates select="people" />
		</table>
	</xsl:template>

	<xsl:template match="people">
			<tr>
				<th colspan="3">
					<h3><xsl:value-of select="@for" /></h3>
					<div class="asp">% i = 0;</div>
				</th>
			</tr>
			<xsl:apply-templates select="person" />
			<tr>
				<th colspan="3">asp-char:%nbsp%</th>
			</tr>
	</xsl:template>

	<xsl:template match="person">
		<tr class="asp:%=GetEO(i++)%">
			<th class="name"><xsl:value-of select="@name" /></th>
			<td class="dept"><xsl:value-of select="@department" /></td>
			<td class="pos"><xsl:value-of select="@position" /></td>
		</tr>
	</xsl:template>

	<!-- thought -->
	<xsl:template match="feature[@id='thought']/quote">
		<p class="thought">&#8220;<xsl:apply-templates />&#8221;</p>
	</xsl:template>

	<xsl:template match="feature[@id='thought']/source">
		<p class="who">&#8212;<xsl:apply-templates /></p>
	</xsl:template>
    
	<!-- Thank you notes -->
	<xsl:template match="feature[@id='thanks']/note">
		<div class="note">
			<p class="description"><xsl:value-of select="description" /></p>
			<blockquote class="letter">
				<p class="salutation"><xsl:value-of select="salutation" /></p>
				<xsl:apply-templates select="body" />
				<p class="signature"><xsl:value-of select="signature" /></p>
				<p class="subsig"><xsl:value-of select="subsig" /></p>
			</blockquote>
		</div>
	</xsl:template>
    
	<!-- Word this Week -->
	<xsl:template match="feature[@id='word']">
		<h2>Word this Week</h2>
		<xsl:apply-templates select="body" />
	</xsl:template>

	<xsl:template match="word | definition">
		<xsl:apply-templates />
	</xsl:template>

	<!-- announcements -->
	<xsl:template match="announcement">
		<div class="item">
			<h3>
				<a name="{@id}" id="{@id}" />
				<xsl:value-of select="title" />
			</h3>
			<xsl:apply-templates select="body" />
		</div>
	</xsl:template>
	
	
	<!-- formatting templates -->
	<xsl:template name="br">
		<xsl:text disable-output-escaping="yes">&lt;br /&gt;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>