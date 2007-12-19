<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:utils="http://www.brookhavencollege.edu/xml/utils">

	<!--=====================================================================
		General Utilities
		======================================================================-->
	<!-- strip-semester
		takes the repetative and also redundant 2007FA/SP/S1/S2 (year is included as a seperate attribute)
		returns a user-friendly Fall/Spring/Summer I/II text string -->
	<xsl:function name="utils:strip-semester" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="sm_abbr" select="upper-case(substring($str_in, 5))" as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="compare($sm_abbr,'FA') = 0">
				<xsl:value-of select="'Fall'" />
			</xsl:when>
			<xsl:when test="compare($sm_abbr,'SP') = 0">
				<xsl:value-of select="'Spring'" />
			</xsl:when>
			<xsl:when test="compare($sm_abbr, 'S1') = 0">
				<xsl:value-of select="'Summer I'" />
			</xsl:when>
			<xsl:when test="compare($sm_abbr, 'S2') = 0">
				<xsl:value-of select="'Summer II'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'invalid semester'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- check-file
		verifies that the url exists and returns a node. prints error if it doesn't -->
	<xsl:function name="utils:check-file" as="xs:boolean">
		<xsl:param name="filename" as="xs:string" />
		
		<xsl:variable name="f" select="replace($filename, '\\', '/')" />
		<xsl:choose>
			<xsl:when test="$f = ''">
				<xsl:value-of select="false()" />
			</xsl:when>
			<xsl:when test="doc-available($f)">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>Invalid file entered: </xsl:text>
					<xsl:value-of select="$f" />
				</xsl:message>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
		
	
	<!--=====================================================================
		Date/Time Conversion Utilities
		
		ok, so dates and times in DSC XML are all over the place. Unfortunately,
		the xs:date doesn't help at all, because it expects the innitialization
		string to be in yyyy-mm-dd format. Which is dumb. If I know the format,
		it's easier for me to pull the data out myself! What good is it having
		a date data type that doesn't do anything? So I don't use it.
		======================================================================-->
	<!-- convert-date-std
		converts dates to a standard mm/dd/yyyy. not sure why it's the standard, yyyy-mm-dd makes a lot more sense, but oh well.
		All the other dates convert to standard before doing their own ops, so I guess this one is the most important function in this
		section -->
	<xsl:function name="utils:convert-date-std" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="step1" select="replace($str_in, '/', '-')" />
		<xsl:variable name="step2" select="replace($step1, '\.', '-')" />
		<xsl:variable name="date"  select="tokenize($step2, '-')"      />
		
		<xsl:value-of select="if (count($date) = 3) then (string-join((utils:format-mmdd($date[1]), utils:format-mmdd($date[2]), utils:format-yyyy($date[3])), '/')) else ('')" />
	</xsl:function>
	
	<!-- convert-date-ap
		 converts dates to the wonky and arbitrary ap style. I'm still trying to figure out what the benefits of this format are, if any. -->
	<xsl:function name="utils:convert-date-ap" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="date"  select="tokenize(utils:convert-date-std($str_in), '/')" as="xs:string" />
		
		<xsl:value-of select="concat(utils:month-abbr(utils:format-mmdd($date[1])), ' ', utils:format-md($date[2]), ', ', utils:format-yyyy($date[3]))" />
	</xsl:function>
	
	<!-- convert-date-mdyy
		 converts dates to a semi-standard m/d/yy 'cause most people don't like leading zeros. I guess that's more work for their poor eyes.
		 and who needs to know what century and milinium we're referencing, anyway. They're all the same, right? :sigh: -->
	<xsl:function name="utils:convert-date-mdyy" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="date"  select="tokenize(utils:convert-date-std($str_in), '/')" as="xs:string" />
		
		<xsl:value-of select="string-join((utils:format-md($date[1]), utils:format-md($date[2]), utils:format-yy($date[3])), '/')" />
	</xsl:function>
	
	<!-- convert-date-md
		 converts dates to a semi-standard m/d when vagueness is the watchword, you can't go wrong by stripping off the whole year. Even better
		 than just removing the first two digits, because it increases the ambiguity even more dramatically! -->
	<xsl:function name="utils:convert-date-md" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="date"  select="tokenize(utils:convert-date-std($str_in), '/')" as="xs:string" />
		
		<xsl:value-of select="string-join((utils:format-md($date[1]), utils:format-md($date[2])), '/')" />
	</xsl:function>
	
	<!-- convert-date-ord
		 converts dates into an ordinal (yyyymmdd format) -->
	<xsl:function name="utils:convert-date-ord" as="xs:string">
		<xsl:param name="date" as="xs:string" />
		
		<xsl:variable name="parts" select="tokenize(utils:convert-date-std($date), '/')" as="xs:string*" />
		<xsl:choose>
			<xsl:when test="count($parts) != 3 or not(matches(string-join($parts, ''), '[0-9]+'))">
				<xsl:value-of select="0" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="xs:integer(concat($parts[3], $parts[1], $parts[2]))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="utils:convert-date-list-ord" as="xs:string*">
		<xsl:param name="date" as="xs:string*" />
		
		<xsl:for-each select="$date">
			<xsl:value-of select="utils:convert-date-ord(.)" />
		</xsl:for-each>
	</xsl:function>
	
	
	<!-- convert-time-std
		 converts times to a standard h:mm a/p.m. -->
	<xsl:function name="utils:convert-time-std" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="step1" select="replace($str_in, ':', '-')" />
		<xsl:variable name="step2" select="replace($step1, '\s', '-')" />
		<xsl:variable name="time" select="tokenize($step2, '-')" />
		
		<xsl:choose>
			<xsl:when test="upper-case($str_in) = 'TBA'">
				<xsl:value-of select="'TBA'" />
			</xsl:when>
			<xsl:when test="contains(lower-case($time[3]), 'a')">
				<xsl:value-of select="concat(utils:format-md($time[1]), ':', utils:format-mmdd($time[2]), ' a.m.')" />
			</xsl:when>
			<xsl:when test="contains(lower-case($time[3]), 'p')">
				<xsl:value-of select="concat(utils:format-md($time[1]), ':', utils:format-mmdd($time[2]), ' p.m.')" />
			</xsl:when>
			<xsl:when test="string-length(normalize-space($str_in)) = 0">
				<xsl:value-of select="''" />
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<!-- convert-time-24h
		 converts times into unambiguous 24-hour format -->
	<xsl:function name="utils:convert-time-24h" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		<xsl:variable name="str_std" select="utils:convert-time-std($str_in)" as="xs:string" />
		
		<xsl:variable name="h0"  select="xs:integer(tokenize($str_std, ':')[1])" as="xs:integer" />
		<xsl:variable name="h1" select="if (matches($str_std, 'p.m.')) then xs:string($h0 + 12) else xs:string($h0)" as="xs:string" />
		<xsl:variable name="hh" select="if (string-length($h1) = 1) then concat('0',$h1) else $h1" as="xs:string" />
		<xsl:variable name="mm" select="tokenize(tokenize($str_std, ':')[2], ' ')[1]" as="xs:string" />
		
		<xsl:value-of select="concat($hh, $mm)" />
	</xsl:function>
	
	<!-- convert-time-ord
	this is really just 24-hour format, but returned as an integer (or 0, if string does not convert) -->
	<xsl:function name="utils:convert-time-ord" as="xs:string">
		<xsl:param name="time" as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="matches($time, '[0-9]+')">
				<xsl:value-of select="utils:convert-time-24h($time)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="0" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	<xsl:function name="utils:convert-time-list-ord" as="xs:string*">
		<xsl:param name="time" as="xs:string*" />
		
		<xsl:for-each select="$time">
			<xsl:value-of select="utils:convert-time-ord(.)" />
		</xsl:for-each>
	</xsl:function>
	
	
	<!-- general date utility utilities ;oP I'm not going to document these, they're just to help
	     the time/date utilities work with screwed up data and no real date-formatting support from xs or xsl -->
	<xsl:function name="utils:format-mmdd" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		
		<xsl:value-of select="if (string-length($str_in) = 1) then concat('0', $str_in) else $str_in" />
	</xsl:function>
	
	<xsl:function name="utils:format-md" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		
		<xsl:value-of select="if ((string-length($str_in) = 2) and (substring($str_in,1,1) = '0')) then substring($str_in,2,1) else $str_in" />
	</xsl:function>

	<xsl:function name="utils:format-yyyy" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		
		<xsl:value-of select="if (string-length($str_in) = 2) then concat('20',$str_in) else $str_in" />
	</xsl:function>

	<xsl:function name="utils:format-yy" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		
		<xsl:value-of select="if (string-length($str_in) = 4) then substring($str_in,3,2) else $str_in" />
	</xsl:function>
	
	<xsl:function name="utils:month-abbr" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="$str_in = '01'"><xsl:value-of select="'Jan.'" /></xsl:when>
			<xsl:when test="$str_in = '02'"><xsl:value-of select="'Feb.'" /></xsl:when>
			<xsl:when test="$str_in = '03'"><xsl:value-of select="'March'" /></xsl:when>
			<xsl:when test="$str_in = '04'"><xsl:value-of select="'April'" /></xsl:when>
			<xsl:when test="$str_in = '05'"><xsl:value-of select="'May'" /></xsl:when>
			<xsl:when test="$str_in = '06'"><xsl:value-of select="'June'" /></xsl:when>
			<xsl:when test="$str_in = '07'"><xsl:value-of select="'July'" /></xsl:when>
			<xsl:when test="$str_in = '08'"><xsl:value-of select="'Aug.'" /></xsl:when>
			<xsl:when test="$str_in = '09'"><xsl:value-of select="'Sept.'" /></xsl:when>
			<xsl:when test="$str_in = '10'"><xsl:value-of select="'Oct.'" /></xsl:when>
			<xsl:when test="$str_in = '11'"><xsl:value-of select="'Nov.'" /></xsl:when>
			<xsl:when test="$str_in = '12'"><xsl:value-of select="'Dec.'" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="''" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="utils:month-name" as="xs:string">
		<xsl:param name="str_in" as="xs:string" />
		
		<xsl:choose>
			<xsl:when test="$str_in = '01'"><xsl:value-of select="'January'" /></xsl:when>
			<xsl:when test="$str_in = '02'"><xsl:value-of select="'February'" /></xsl:when>
			<xsl:when test="$str_in = '03'"><xsl:value-of select="'March'" /></xsl:when>
			<xsl:when test="$str_in = '04'"><xsl:value-of select="'April'" /></xsl:when>
			<xsl:when test="$str_in = '05'"><xsl:value-of select="'May'" /></xsl:when>
			<xsl:when test="$str_in = '06'"><xsl:value-of select="'June'" /></xsl:when>
			<xsl:when test="$str_in = '07'"><xsl:value-of select="'July'" /></xsl:when>
			<xsl:when test="$str_in = '08'"><xsl:value-of select="'August'" /></xsl:when>
			<xsl:when test="$str_in = '09'"><xsl:value-of select="'September'" /></xsl:when>
			<xsl:when test="$str_in = '10'"><xsl:value-of select="'October'" /></xsl:when>
			<xsl:when test="$str_in = '11'"><xsl:value-of select="'November'" /></xsl:when>
			<xsl:when test="$str_in = '12'"><xsl:value-of select="'December'" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="''" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!--=====================================================================
		Date/Time Comparison Utilities
		
		these are fairly simple - just combinations of the above conversions
		and the compare() function
		======================================================================-->
	<!-- compare-dates
		returns 0 if equal, 1 if date1 is greater than date2 or -1 if less than -->
	<xsl:function name="utils:compare-dates" as="xs:integer">
		<xsl:param name="date1" as="xs:string" />
		<xsl:param name="date2" as="xs:string" />
		
		<xsl:variable name="d1" select="utils:convert-date-ord($date1)" as="xs:string" />
		<xsl:variable name="d2" select="utils:convert-date-ord($date2)" as="xs:string" />
		
		<xsl:value-of select="compare($d1, $d2)" />
	</xsl:function>
	
	<!-- compare-dates-between
		returns true if the first date is after the second, but before the third
		the fourth and fifth parameter specify inclusiveness for the second and third
		  dates, respectively -->
	<xsl:function name="utils:compare-dates-between" as="xs:boolean">
		<xsl:param name="date-curr" as="xs:string" />
		<xsl:param name="date-min"  as="xs:string" />
		<xsl:param name="date-max"  as="xs:string" />
		<xsl:param name="inc-min"   as="xs:boolean" />
		<xsl:param name="inc-max"   as="xs:boolean" />
		
		<xsl:choose>
			<xsl:when test="$inc-min and $inc-max">
				<xsl:value-of select="(utils:compare-dates($date-curr, $date-min) != -1) and (utils:compare-dates($date-curr, $date-max) != 1)" />
			</xsl:when>
			<xsl:when test="$inc-min">
				<xsl:value-of select="(utils:compare-dates($date-curr, $date-min) != -1) and (utils:compare-dates($date-curr, $date-max) = -1)" />
			</xsl:when>
			<xsl:when test="$inc-max">
				<xsl:value-of select="(utils:compare-dates($date-curr, $date-min) = 1) and (utils:compare-dates($date-curr, $date-max) != 1)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="(utils:compare-dates($date-curr, $date-min) = 1) and (utils:compare-dates($date-curr, $date-max) = -1)" />
			</xsl:otherwise>
		</xsl:choose>
		
		
	</xsl:function>
	
	<!-- compare-times
		returns 0 if equal, 1 if date1 is greater than date2 or -1 if less than -->
	<xsl:function name="utils:compare-times" as="xs:integer">
		<xsl:param name="time1" as="xs:string" />
		<xsl:param name="time2" as="xs:string" />
		
		<xsl:variable name="t1" select="utils:convert-time-ord($time1)" as="xs:string" />
		<xsl:variable name="t2" select="utils:convert-time-ord($time2)" as="xs:string" />
		
		<xsl:value-of select="compare($t1, $t2)" />
	</xsl:function>
	
	
	<!--=====================================================================
		Date/Time Selection Utilities
		
		these are fairly simple - just combinations of the above conversions
		and the compare() function
		======================================================================-->
	<!-- select-date-oldest
		returns the older of two passed dates -->
	<xsl:function name="utils:select-date-oldest" as="xs:string">
		<xsl:param name="date" as="xs:string*" />
		
		<xsl:for-each select="$date">
			<xsl:sort select="utils:convert-date-ord(.)" order="descending" />
			
			<xsl:if test="position() = last()">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	<!-- select-date-newest
		returns the newer of two passed dates -->
	<xsl:function name="utils:select-date-newest" as="xs:string">
		<xsl:param name="date" as="xs:string*" />
		
		<xsl:for-each select="$date">
			<xsl:sort select="utils:convert-date-ord(.)" order="ascending" />
			
			<xsl:if test="position() = last()">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	<!-- select-time-oldest
		returns the older of two passed times -->
	<xsl:function name="utils:select-time-oldest" as="xs:string">
		<xsl:param name="time" as="xs:string*" />
		
		<xsl:for-each select="$time">
			<xsl:sort select="utils:convert-time-ord(.)" order="descending" />
			
			<xsl:if test="position() = last()">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	<!-- select-time-oldest
		returns the newer of two passed times -->
	<xsl:function name="utils:select-time-newest" as="xs:string">
		<xsl:param name="time" as="xs:string*" />
		
		<xsl:for-each select="$time">
			<xsl:sort select="utils:convert-time-ord(.)" order="ascending" />
			
			<xsl:if test="position() = last()">
				<xsl:value-of select="." />
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
</xsl:stylesheet>