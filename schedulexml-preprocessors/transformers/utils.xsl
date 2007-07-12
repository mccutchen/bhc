<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
    version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:utils="http://www.brookhavencollege.edu/xml/utils"
    exclude-result-prefixes="xs utils">


    <!-- Defaults -->
    <xsl:variable name="default-time" as="xs:string">NA</xsl:variable>
    <xsl:variable name="default-date" as="xs:string">NA</xsl:variable>

    <!-- =====================================================================
         Basic utilities
    ====================================================================== -->
    <xsl:function name="utils:sort-order" as="xs:integer">
        <xsl:param name="needle" />
        <xsl:param name="haystack" />
        <xsl:number value="index-of($haystack, $needle)[1]" />
    </xsl:function>
    
    
    <!-- =====================================================================
         Quark XPress Tag functions
    ====================================================================== -->
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

    
    <!-- =====================================================================
         Urlify
    ====================================================================== -->
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
	

    <!-- =====================================================================
         Date formatters
    ====================================================================== -->
    <xsl:function name="utils:format-dates" as="xs:string">
        <xsl:param name="start-date" as="xs:string" />
        <xsl:param name="end-date" as="xs:string" />

        <xsl:variable name="date-pattern">0?(\d+)/0?(\d+)/\d+</xsl:variable>
        <xsl:variable name="date-replace">$1/$2</xsl:variable>

        <xsl:choose>
            <xsl:when test="matches($start-date, $date-pattern) and matches($end-date, $date-pattern)">
                <xsl:value-of select="concat(replace($start-date, $date-pattern, $date-replace), '-', replace($end-date, $date-pattern, $date-replace))" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Bad dates: <xsl:value-of select="($start-date, $end-date)" separator="," /></xsl:message>
                <xsl:value-of select="$default-date" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- =====================================================================
         Time formatters
    ====================================================================== -->
    <xsl:function name="utils:format-times" as="xs:string">
        <!-- Formats the given start time and end time according to AP
             style.  Uses the utils:format-time() function to format
             each individual time.  If both formatted times have the
             same suffix, the suffix is removed from the start time.
             If one of the given times is invalid, the $default-time
             is returned.  Otherwise, the two times are joined
             together with a '-' and returned as one string.
             Examples:
             
             utils:format-times('9:30 AM', '11:00 AM') => '9:30-11 a.m.'
             utils:format-times('9:00 AM', '12:00 PM') => '9 a.m.-noon'
             utils:format-times('11:00 AM', '12:30 PM') => '11 a.m.-12:30 p.m.'
             utils:format-times('1:00 PM', '3:00 PM') => '1-3 p.m.'
             utils:format-times('', '') => $default-time -->
        <xsl:param name="start-time" as="xs:string" />
        <xsl:param name="end-time" as="xs:string" />

        <!-- if the two time values have the same suffixe, we need to
             trim the suffix from the first value -->
        <xsl:variable name="same-suffix" select="substring-after($start-time, ' ') = substring-after($end-time, ' ')" />

        <!-- get the input times into a good AP format -->
        <xsl:variable name="ap-start-time" select="utils:format-time($start-time, $same-suffix)" />
        <xsl:variable name="ap-end-time" select="utils:format-time($end-time, false())" />

        <xsl:choose>
            <!-- Are both of our AP-style time values valid? (Which is
                 to say, neither of them are the $default-time.) -->
            <xsl:when test="$default-time != ($ap-start-time, $ap-end-time)">
                <!-- return the two AP-style values joined together
                     with a dash -->
                <xsl:value-of select="concat($ap-start-time, '-', $ap-end-time)" />
            </xsl:when>
            <!-- If either of our time values was invalid, just return
                 the $default-time by itself -->
            <xsl:otherwise>
                <xsl:value-of select="$default-time" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="utils:format-time" as="xs:string">
        <!-- Formats the given time value according to AP style, if
             the given time value matches the $time-pattern regular
             expression.  AP style dictates that any leading '0' or
             trailing ':00' should be removed, and the time suffix
             should be either 'a.m.' or 'p.m.'.  The second argument
             determines whethor or not the suffix is removed
             altogether. If the time value is invalid (i.e. doesn't
             match $time-pattern), $default-time is
             returned. Examples:
             
             utils:format-time('9:30 AM', false()) => '9:30 a.m.'
             utils:format-time('9:00 PM', false()) => '9 p.m.'
             utils:format-time('12:00 PM', false()) => 'noon'
             utils:format-time('12:30 PM', true()) => '12:30'
             utils:format-time('', true()) => $default-time -->
        <xsl:param name="time" as="xs:string" />
        <xsl:param name="trim-suffix" as="xs:boolean" />
        
        <!-- This pattern and replacement validate the given $time
             value to make sure it's in the expected format and also
             remove any unnecessary leading '0' or trailing ':00' to
             bring the time value closer to AP style -->
        <xsl:variable name="time-pattern">0?(\d+(:[1-9][0-9])?)(:00)? (AM|PM)</xsl:variable>
        <xsl:variable name="time-replace">$1 $4</xsl:variable>

        <!-- patterns to replace 'AM' with 'a.m.' and 'PM' with 'p.m.'
             according to AP style -->
        <xsl:variable name="am-pattern">(.*) AM$</xsl:variable>
        <xsl:variable name="am-replace">$1 a.m.</xsl:variable>
        <xsl:variable name="pm-pattern">(.*) PM$</xsl:variable>
        <xsl:variable name="pm-replace">$1 p.m.</xsl:variable>

        <!-- AP style calls for 12:00 p.m. to be replaced with the
             string 'noon' -->
        <xsl:variable name="noon-pattern">12:00 PM</xsl:variable>
        <xsl:variable name="noon-replace">noon</xsl:variable>

        <xsl:choose>
            <!-- Is it noon? If so, we can skip the rest of this. -->
            <xsl:when test="matches($time, $noon-pattern)">
                <xsl:value-of select="replace($time, $noon-pattern, $noon-replace)" />
            </xsl:when>
            
            <!-- Do we have a valid time value? -->
            <xsl:when test="matches($time, $time-pattern)">
                <!-- remove any leading 0s or any trailing :00 from
                     the start and end time, according to AP style
                     (09:00 => 9, 09:30 => 9:30) -->
                <xsl:variable name="time-fixed-zeros" select="replace($time, $time-pattern, $time-replace)" />

                <!-- return the time with or without an AP-formatted
                     suffix (a.m. or p.m.), depending on the value of
                     $trim-suffix -->
                <xsl:choose>
                    <xsl:when test="$trim-suffix">
                        <!-- we don't need the suffix -->
                        <xsl:value-of select="substring-before($time-fixed-zeros, ' ')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- convert the suffix, given as AM or PM,
                             into AP style (a.m. or p.m.) -->
                        <xsl:value-of select="replace(replace($time-fixed-zeros, $am-pattern, $am-replace), $pm-pattern, $pm-replace)" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!-- if the time value is invalid, return 'NA' -->
            <xsl:otherwise>
                <xsl:value-of select="$default-time" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    

    <!-- =====================================================================
         Senior Adults functions
    ====================================================================== -->
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
