<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs">

    <xsl:template name="footer-template">
        <xsl:param name="this-issue" select="ancestor-or-self::issue" as="element()" />
		<xsl:param name="issue-date" select="@date"                   as="xs:string" />

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

    </xsl:template>
</xsl:stylesheet>