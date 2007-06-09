from wrm.formatter import Formatter
from wrm.decorators import excepting, stripped, uppercased, trace
from profiles import profile

class CCEFormatter(Formatter):
    """Performs custom-formatting of schedule data as it is parsed
    from the database results, including date and time formatting and
    money formatting."""

    @excepting(AttributeError, u'')
    @stripped
    def default_formatter(self, data):
        """By default, all fields are simply stripped of leading and
        trailing whitespace."""
        return data

    @excepting(AttributeError, u'')
    @stripped
    @uppercased
    def format_title(self, data):
        """The course title is uppercased and stripped of whitespace."""
        return data
    
    @excepting(AttributeError, u'')
    @stripped
    @uppercased
    def format_division(self, data):
        """The division names are uppercased and stripped of
        whitespace."""
        return data

    # all of the division names are formatted identically, so they
    # share a generic formatting function
    format_major_division = format_division
    format_minor_division = format_division
    format_other_division = format_division

    @stripped
    def format_faculty(self, data):
        """If no faculty is given, the default faculty name, defined
        in the profile, is returned.  Otherwise, the given faculty
        name is stripped of whitespace."""
        if data is None or data.strip() is '':
            return profile.defaults['faculty']
        else:
            return data

    @excepting(AttributeError, None)
    def format_date(self, data):
        """If the date is given, it is a datetime.datetime object.  It
        is AP formatted and returned.  If the date is not given, None
        is returned."""
        day = data.strftime('%d')
        month = data.strftime('%m')

        # AP formatting says that any leading zeros should be removed.
        date = '%s/%s' % (month.lstrip('0'), day.lstrip('0'))
        return date
    format_start_date = format_date
    format_end_date = format_date

    def format_start_time(self, data):
        """Do not do any formatting on the input data.  It should be a
        datetime object, so we just leave it alone."""
        return data

    @excepting(TypeError, u'0')
    def format_int(self, data):
        """Converts an integer input into a string.  Returns the
        string '0' if an error occurs."""
        return u'%d' % data
    format_session = format_int
    format_hours = format_int
    format_catalog_sort_order = format_int
    format_cluster_sort_order = format_int

    @excepting(TypeError, None)
    def format_tuition(self, data):
        """Formats the tuition according to AP style.  If the tuition
        has no change (e.g. $25.00), the trailing '.00' is removed."""
        d = u'$%1.2f' % data
        return d.replace('.00','')

    @excepting(AttributeError, None)
    def format_field_with_flag(self, data):
        """In the input database, boolean sorts of fields just contain
        an asterisk to indicate truth and are empty to indicate false."""
        return (data.strip() == '*') and True or None
    format_Financial_Aid = format_field_with_flag
    format_Concurrent = format_field_with_flag
    
    
    # Virtual fields
    # These formatting functions don't correspond to fields in the database,
    # their return values are taken from other fields (using self.input)    
    def format_textbooks(self, data):
        """Joins any textbooks found in the three separate textbook fields
        into a comma-separated list of titles."""
        textbooks = ', '.join([self.input['textbook%s'%i] for i in range(1,4) if self.input.get('textbook%s'%i)])
        return textbooks
    
    @excepting(AttributeError, None)
    def format_spanish(self, data):
        """Attempts to guess whether or not this is a Spanish course based
        on the course title.  TODO:  This should be a dedicated field in the
        database, not this UGLY HACK."""
        if self.input['title'].lower().find(u'en espa\xf1ol') != -1:
            return 'true'
        else:
            return None
    
    @excepting(AttributeError, None)
    def format_evening(self, data):
        """Determine whether this is a night class."""
        start_time = self.input['start_time'] # should be a datetime.datetime object
        suffix = start_time.strftime('%p') # get the AM or PM suffix for the given time

        # if the class starts after the 'evening threshold' and has a PM suffix,
        # it's an evening class
        threshold = profile.evening_threshold
        if threshold < 12: threshold += 12
        if start_time.hour >= threshold and suffix == 'PM':
            return 'True'
    
    @excepting(AttributeError, None)
    def format_time_sortkey(self, data):
        """Create a sortkey based on the 24 hour version of this class's
        start time."""
        return self.input['start_time'].strftime('%H%M').lstrip('0')
    
    @excepting(AttributeError, u'')
    def format_date_sortkey(self, data):
        """Creates a sortkey based on this class's start date."""
        return self.input['start_date'].strftime('%Y%m%d')