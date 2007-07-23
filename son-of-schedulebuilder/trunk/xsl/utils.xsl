<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="xs utils">


    <!-- =====================================================================
         Quark XPress Tags functions
         
         These functions are useful for inserting special Quark XPress Tags
         markers into the output.
    ====================================================================== -->
    <xsl:function name="utils:xtag" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:value-of select="concat('@', normalize-space($style-name), ':')" />
    </xsl:function>

    <xsl:function name="utils:xtag-inline" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:param name="content" as="xs:string" />
        <!-- Quark Xpress Tags for inline or "character" styles look like so:
             <@stylename>content<@$p> -->
        <xsl:value-of select="concat('&lt;@', normalize-space($style-name), '&gt;', $content, '&lt;@$p&gt;')" />
    </xsl:function>


    <!-- =====================================================================
         senior-adult-days(days)
         
         Takes input string 'days' as a sequence of one letter abbreviations
         for the meeting days of a class (e.g. 'MWF' for a class meeting on
         Monday, Wednesday and Friday) and returns a more human-friendly
         representation of the days of the week.
         
         If only one day is given as input, that day's full name is returned.  
         If more than one day is given as input, abbreviated versions of the
         days are returned.
          
         Examples:
          - utils:senior-adult-days('M') => 'Monday'
          - utils:senior-adult-days('TR') => 'Tues. & Thurs.'
          - utils:senior-adult-days('MWF') => 'Mon., Wed., Fri.'
    ====================================================================== -->
    <xsl:function name="utils:senior-adult-days" as="xs:string">
        <xsl:param name="days" as="xs:string" />
        <xsl:value-of select="utils:senior-adult-days-helper($days, '', ' &amp; ')" />
    </xsl:function>

    <xsl:function name="utils:senior-adult-days-helper" as="xs:string">
        <xsl:param name="input" as="xs:string" />
        <xsl:param name="output" as="xs:string" />
        <xsl:param name="separator" as="xs:string" />

        <!-- a map of day characters to their full names and abbreviations -->
        <xsl:variable name="day-map">
            <day char="U" full="Sunday" abbrev="Sun." />
            <day char="M" full="Monday" abbrev="Mon." />
            <day char="T" full="Tuesday" abbrev="Tues." />
            <day char="W" full="Wednesday" abbrev="Wed." />
            <day char="R" full="Thursday" abbrev="Thurs." />
            <day char="F" full="Friday" abbrev="Fri." />
            <day char="S" full="Saturday" abbrev="Sat." />
        </xsl:variable>

        <!-- the data that we're dealing with -->
        <xsl:variable name="first" select="substring($input,1,1)" />
        <xsl:variable name="rest" select="substring($input,2)" />

        <!-- store the current day we were given -->
        <xsl:variable name="this-day-abbrev" select="$day-map/day[@char=$first]/@abbrev" as="xs:string" />
        <xsl:variable name="this-day-full" select="$day-map/day[@char=$first]/@full" as="xs:string" />

        <xsl:choose>
            <!-- only one day given, so output the full day name -->
            <xsl:when test="string-length($input) = 1 and string-length($output) = 0">
                <xsl:value-of select="$this-day-full" />
            </xsl:when>

            <!-- only one day left in the input, so append it to the output and return -->
            <xsl:when test="string-length($input) = 1 and string-length($output) &gt; 0">
                <xsl:value-of select="concat($output, $separator, $this-day-abbrev)" />
            </xsl:when>

            <!-- if there are exactly two days given, output their abbreviations
                 separated by ampersands -->
            <xsl:when test="string-length($input) = 2 and string-length($output) = 0">
                <xsl:value-of select="utils:senior-adult-days-helper($rest, $this-day-abbrev, ' &amp; ')" />
            </xsl:when>

            <!-- if there are more than two days given, output their abbreviations
                 separated by commas -->
            <xsl:when test="string-length($input) &gt; 2 and string-length($output) = 0">
                <xsl:value-of select="utils:senior-adult-days-helper($rest, $this-day-abbrev, ', ')" />
            </xsl:when>

            <!-- by default, just keep on calling recursively with the given separator -->
            <xsl:otherwise>
                <xsl:value-of select="utils:senior-adult-days-helper($rest, concat($output, $separator, $this-day-abbrev), $separator)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
