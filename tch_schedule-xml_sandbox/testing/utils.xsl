<?xml version="1.0" encoding="iso-8859-1"?>

<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:utils="http://www.brookhavencollege.edu/xml/utils"> <!-- for functions -->

	<!-- utility functions -->
	
	<!-- strip-semester
		 takes the repetative and also redundant 2007FA/SP/S1/S2 (year is included as a seperate attribute)
		 returns a user-friendly Fall/Spring/Summer text string -->
	<xsl:function name="utils:strip-semester">
		<xsl:param name="str_in" />
		<xsl:variable name="sm_abbr" select="upper-case(substring($str_in, 5))" />
		
		<xsl:choose>
			<xsl:when test="compare($sm_abbr,'FA') = 0">
				<xsl:value-of select="'Fall'" />
			</xsl:when>
			<xsl:when test="compare($sm_abbr,'SP') = 0">
				<xsl:value-of select="'Spring'" />
			</xsl:when>
			<xsl:when test="(compare($sm_abbr, 'S1') = 0) or (compare($sm_abbr, 'S2') = 0)">
				<xsl:value-of select="'Summer'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'invalid semester'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<!-- ok, so dates and times in DSC XML are all over the place. Unfortunately, the xs:date doesn't help at all, because it expects the
	     innitialization string to be in yyyy-mm-dd format. Which is dumb. If I know the format, it's easier for me to pull the data out
		 myself! What good is it having a date data type that doesn't do anything? So I don't use it. It's also lovely how xsl will gladly
		 spit out a string list, but then collapses it into a flat string when returning the value. Lovely. It may *technically* be a real
		 programming language, but it's hell to work with. -->
		 
	<!-- convert-date-std
		 converts dates to a standard mm/dd/yyyy. not sure why it's the standard, yyyy-mm-dd makes a lot more sense, but oh well.
		 All the other dates convert to standard before doing their own ops, so I guess this one is the most important function in this
		 section -->
	<xsl:function name="utils:convert-date-std">
		<xsl:param name="str_in" />
		<xsl:variable name="step1" select="replace($str_in, '/', '-')" />
		<xsl:variable name="step2" select="replace($step1, '\.', '-')"  />
		<xsl:variable name="date"  select="tokenize($step2, '-')" />
		
		<xsl:value-of select="string-join((utils:format-mmdd($date[1]), utils:format-mmdd($date[2]), utils:format-yyyy($date[3])), '/')" />
	</xsl:function>
	
	<!-- convert-date-ap
		 converts dates to the wonky and arbitrary ap style. I'm still trying to figure out what the benefits of this format are, if any. -->
	<xsl:function name="utils:convert-date-ap">
		<xsl:param name="str_in" />
		<xsl:variable name="date"  select="tokenize(utils:convert-date-std($str_in), '/')" />
		
		<xsl:value-of select="concat(utils:month-name(utils:format-mmdd($date[1])), ' ', utils:format-md($date[2]), ', ', utils:format-yyyy($date[3]))" />
	</xsl:function>
	
	<!-- convert-date-mdyy
		 converts dates to a semi-standard m/d/yy 'cause most people don't like leading zeros. I guess that's more work for their poor eyes.
		 and who needs to know what century and milinium we're referencing, anyway. They're all the same, right? :sigh: -->
	<xsl:function name="utils:convert-date-mdyy">
		<xsl:param name="str_in" />
		<xsl:variable name="date"  select="tokenize(utils:convert-date-std($str_in), '/')" />
		
		<xsl:value-of select="string-join((utils:format-md($date[1]), utils:format-md($date[2]), utils:format-yy($date[3])), '/')" />
	</xsl:function>
	
	<!-- convert-date-md
		 converts dates to a semi-standard m/d when vagueness is the watchword, you can't go wrong by stripping off the whole year. Even better
		 than just removing the first two digits, because it increases the ambiguity much more dramatically! -->
	<xsl:function name="utils:convert-date-md">
		<xsl:param name="str_in" />
		<xsl:variable name="date"  select="tokenize(utils:convert-date-std($str_in), '/')" />
		
		<xsl:value-of select="string-join((utils:format-md($date[1]), utils:format-md($date[2])), '/')" />
	</xsl:function>
	
	<!-- convert-time-std
		 converts times to a standard h:mm ap.m. -->
	<xsl:function name="utils:convert-time-std">
		<xsl:param name="str_in" />
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
			<xsl:when test="string-length(normalize-space($str_in)) = 0" />
		</xsl:choose>
	</xsl:function>
	
	<!-- general date utility utilities ;oP I'm not going to document these, they're just to help
	     the time/date utilities work with screwed up data and no real date-formatting support from xs or xsl -->
	<xsl:function name="utils:format-mmdd">
		<xsl:param name="str_in" />
		
		<xsl:value-of select="if (string-length($str_in) = 1) then concat('0', $str_in) else $str_in" />
	</xsl:function>
	
	<xsl:function name="utils:format-md">
		<xsl:param name="str_in" />
		
		<xsl:value-of select="if ((string-length($str_in) = 2) and (substring($str_in,1,1) = '0')) then substring($str_in,2,1) else $str_in" />
	</xsl:function>

	<xsl:function name="utils:format-yyyy">
		<xsl:param name="str_in" />
		
		<xsl:value-of select="if (string-length($str_in) = 2) then concat('20',$str_in) else $str_in" />
	</xsl:function>

	<xsl:function name="utils:format-yy">
		<xsl:param name="str_in" />
		
		<xsl:value-of select="if (string-length($str_in) = 4) then substring($str_in,3,2) else $str_in" />
	</xsl:function>
	
	<xsl:function name="utils:month-name">
		<xsl:param name="str_in" />
		
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
		</xsl:choose>
	</xsl:function>

</xsl:stylesheet>