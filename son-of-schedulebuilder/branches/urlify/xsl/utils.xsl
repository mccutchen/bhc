<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="xs utils">
	
    <xsl:function name="utils:sort-order" as="xs:integer">
        <xsl:param name="needle" />
        <xsl:param name="haystack" />
        <xsl:number value="index-of($haystack, $needle)[1]" />
    </xsl:function>

    <xsl:function name="utils:xtag" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:value-of select="concat('@', normalize-space($style-name), ':')" />
    </xsl:function>

    <xsl:function name="utils:xtag-inline" as="xs:string">
        <xsl:param name="style-name" as="xs:string" />
        <xsl:param name="content" as="xs:string" />
        <!-- inline styles in Quark Xpress Tags look like <@stylename>content<@$p> -->
        <xsl:value-of select="concat('&lt;@', $style-name, '&gt;', $content, '&lt;@$p&gt;')" />
    </xsl:function>

	<xsl:function name="utils:urlify" as="xs:string">
		<!-- translates an input string into something suitable for URLs or
			 filenames, mostly by replacing spaces with underscores, etc. -->
		<xsl:param name="s" as="xs:string" />
		
		<xsl:variable name="replacements">
			<!-- chars which should be replaced with an underscore -->
			<rule pattern="[\s\\/&amp;\-]" replacement="_" />
			<!-- n with tilde -->
			<rule pattern="&#241;" replacement="n" />
			<!-- blacklisted chars, which must be replaced after all the other
				 patterns -->
			<rule pattern="[^A-z0-9_]" replacement="" />
		</xsl:variable>
		
		<xsl:variable name="result" select="utils:urlify-helper(lower-case($s), $replacements/rule)" />
		<!-- <xsl:message>urlify(<xsl:value-of select="$s" />) = <xsl:value-of select="$result" /></xsl:message> -->
		<xsl:value-of select="$result" />
	</xsl:function>
	
	<xsl:function name="utils:urlify-helper" as="xs:string">
		<xsl:param name="s" as="xs:string" />
		<xsl:param name="rules" />
		
		<xsl:variable name="rule" select="$rules[1]" />
		<xsl:variable name="pattern" select="$rule/@pattern" />
		<xsl:variable name="replacement" select="$rule/@replacement" />
		
		<xsl:choose>
			<!-- no rules left (this shouldn't happen) -->
			<xsl:when test="count($rules) = 0">
				<xsl:value-of select="$s" />
			</xsl:when>
			<!-- one rule left, so we just apply it and return the results -->
			<xsl:when test="count($rules) = 1">
				<xsl:value-of select="replace($s, $pattern, $replacement)" />
			</xsl:when>
			<!-- apply the first rule and then recursively apply the rest of
				 the rules -->
			<xsl:otherwise>
				<xsl:value-of select="utils:urlify-helper(replace($s, $pattern, $replacement), subsequence($rules, 2))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

    <xsl:function name="utils:senior-adult-days" as="xs:string">
        <xsl:param name="input" as="xs:string" />
        <xsl:value-of select="utils:senior-adult-days-helper($input, '', ' &amp; ')" />
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
