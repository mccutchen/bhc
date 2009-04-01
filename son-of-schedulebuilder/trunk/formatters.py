import datetime, re

from wrm.formatter import Formatter
from wrm.decorators import cached, excepting
from wrm import utils
from wrm import xmlutils

import mappings
from mappings import FULL_MAPPING_CACHE, RUBRIK_MAPPING_CACHE
from profiles import profile


class BaseFormatter(Formatter):
    """BaseFormatter is used to define a post_formatter fuction
    that can be shared between the CreditFormatter and the
    SessionFormatter."""

    def post_formatter(self, value):
        """Attempts to intelligently do some post-processing on
        the values emitted by the formatters.  If the value is a
        dict, list, tuple or None, it is returned unchanged.

        If the value is a bool, it is converted into either 'true'
        or None, depending on its boolean value.

        Otherwise, the value is converted into a unicode string
        and strip()ped."""
        if type(value) in (dict, list, tuple) or value is None:
            return value
        elif isinstance(value, bool):
            return value and 'true' or None
        else:
            value = unicode(value)
            return value.strip()


class CreditFormatter(BaseFormatter):
    def format_class_number(self, value):
        """Formats a class number like so: XXXX 1234-1234"""
        return '%(rubrik)s %(number)s-%(section)s' % self.input

    def format_class_sortkey(self, value):
        """A class will only have a sortkey if it is being regrouped.  If
        not, the empty string is returned."""
        subject = mappings.get(FormatUtils.get_class_number(self.input), 'subject')
        if subject and hasattr(subject, 'sortkey'):
            return subject.sortkey
        else:
            return ''

    def format_course_sortkey(self, value):
        """Lets courses be sorted by their number.  HIST 1301 is sorted as 1301,
        for example."""
        return self.input['number']
        
    def format_type(self, value):
        """If the current course does not have its 'schedule type' set in
        Colleague, it is noted in the errors for this run.  The input value is
        returned unchanged."""
        if not value.strip():
            profile.errors.add(DataError(self.input, 'Unknown course type'))
        return value

    def format_comments(self, value):
        """Comments are given as 10 separate fields.  The algorithm for constructing
        the final comments value is this:
            1.  Join the fields, inserting a space between each field.
            2.  Replace multiple spaces with one space.
            3.  Collapse hyphenated words, since some of the Colleague data-entry folks
                will hyphenate words to break them across comments fields."""
        assert type(value) in (list, tuple)

        comments = ' '.join(value) # join the separate comments fields into a single string
        comments = re.sub('\s{2,}', ' ', comments) # replace multiple spaces with one space
        comments = re.sub('([a-zA-Z]{1})(- )','\\1', comments) # collapse hyphenated words
        
        return FormatUtils.post_process_comments(comments)

    @excepting(ValueError, '9999')
    def format_class_sortkey_date(self, value):
        """Returns the ordinal value of the given class's start date."""
        return utils.parsedate(self.input['start-date']).toordinal()
    
    def format_class_sortkey_time(self, value):
        """Returns the 24-hour time value of the given class's start time."""
        start_time = self.input.get('session', {}).get('start-time')
        try:
            (hours, minutes), ampm = start_time[:-2].split(':'), start_time[-2:]
            nhours = int(hours)
            if ampm == 'PM' and nhours != 12:
                hours = nhours + 12
            return '%s%s' % (hours, minutes)
        except ValueError:
            return '2400'

    @cached
    def format_date(self, value):
        """Returns a string representing the same date with any
        leading zeros and the year removed.

        For example: MM/DD/YYYY -> M/D"""
        return '/'.join(map(lambda s: s.lstrip('0'), value.split('/'))[:2])

    def format_formatted_dates(self, value):
        """Return a pair of nicely-formatted dates."""
        start = self.input.get('start-date','')
        end = self.input.get('end-date','')
        return '%s-%s' % (self.format_date(start), self.format_date(end))
    
    def format_weeks(self, value):
        """Ensures that a valid value for weeks was given.  If not, an
        error is reported."""
        try:
            return int(value)
        except ValueError:
            error = DataError(self.input, 'No weeks given')
            profile.errors.add(error)
            return ''

    def format_credit_hours(self, value):
        """Remove trailing zeros and decimals."""
        return value.rstrip('0').rstrip('.')

    def format_division(self, value):
        """Returns the name of the instructional division of the current
        class.  Searches the mappings first based on the current rubrik and
        then based on the current division code.  This search order allows
        the division to be overridden on a rubrik-by-rubrik basis, which lets
        us put PE and Nutrition courses in their proper division.

        UGLY HACK: Since there isn't an actual Students 50+ Education division
        defined, we put any classes with a topic-code of 'E' (for 'Emeritus')
        in the Students 50+ Education Office pseudo-division."""

        # UGLY HACK:  The should be a more elegant way to accomplish this
        if self.input.get('topic-code','').strip() == 'E':
            return 'Students 50+ Education Office'
        else:
            try:
                # First, check using the rubrik, then fall back to the division code,
                # which is what will be used in most cases.
                division, comments, sortkey = \
                    mappings.get(self.input.get('rubrik',''), 'division', 'division') or \
                    mappings.get(value.strip(), 'division', 'division')
                return division
            except TypeError:
                pass

        # if no division was found, just return the given division code
        return value

    def format_term(self, value):
        """Returns the name of the term for this class, based on this class's
        start date and the terms in the current profile.  Uses
        FormatUtils.get_term to do the actual work."""
        return FormatUtils.get_term(value.strip(), self.input['start-date'])

    def format_term_sortkey(self, value):
        """Finds the term containing this class and uses its start date to
        create a sortkey."""
        term = FormatUtils.get_term(self.input['term'], self.input['start-date'])
        term_start, term_end = FormatUtils.get_term_dates(term)
        return str(term_start.toordinal())

    def format_term_dates(self, value):
        """Returns the AP-formatted versions of the term's start and end
        dates."""
        term = FormatUtils.get_term(self.input['term'], self.input['start-date'])
        # The formatted term dates are the third element in the 3-tuple in
        # each value in the profile.terms dict
        return profile.terms[term][2]

    def format_cross_listings(self, value):
        """Returns a list of cross-listings for the current class.  In some
        cases, returns an empty list, even if the class is cross-listed in
        Colleague."""
        
        # If the current profile wants us to skip the cross-listings for this
        # class, return an empty list.
        for key, patterns in profile.skip_cross_listings.items():
            assert key in self.input, 'Invalid key in profile.skip_cross_listings: %s (%s)' % (key, repr(profile.skip_cross_listings))
            for pattern in patterns:
                if re.match(pattern, self.input[key]):
                    return []

        # Make sure each cross-listing has the same rubrik as the current
        # class.  If not, return an empty list.  Otherwise, classes in one 
        # rubrik that are cross-listed with classes from another rubrik will
        # be needlessly separated and could appear out of order.
        rubrik = self.input.get('rubrik')
        for class_number in value:
            if class_number[:4] != rubrik:
                return []
        
        # Hopefully, we have a valid cross-listing
        return value

    def format_special_cross_listings(self, value):
        """Provides the ability to generate custom cross-listing values to
        include certain classes in <group> elements despite their lack of
        cross-listings in Colleague.  Returns a string.

        A special case is provided for certain ESOL courses which need to be
        specially-grouped together.  Luckily they follow a pattern and are
        easy to handle."""

        # Special case for ESOL courses, at the request of Joe Monroy.
        if self.input.get('rubrik') == 'ESOL':
            # Basically, ESOL-0051 goes with ESOL-0061, etc.  This is a list of
            # the pairs of course numbers that are to be grouped together.
            esolnumbers = [
                ('0051','0061'),
                ('0052','0062'),
                ('0053','0063'),
                ('0054','0064')
            ]
            number = self.input.get('number')
            for pairs in esolnumbers:
                if number in pairs:
                    # create the phony cross-listing for this pseudo-group
                    # based on the course and section numbers
                    section = self.input.get('section')
                    return 'ESOL-%s-%sESOL-%s-%s' % (pairs[0], section, pairs[1], section)

        # we should not group this course
        return None

    def format_minimester(self, value):
        """Generates a minimester name based on the month of the start-date
        of the given class."""
        if FormatUtils.is_minimester(self.input):
            # we've got a minimester!
            startdate = utils.parsedate(self.input['start-date'])
            # return the month in which this class starts
            return startdate.strftime('%B')
        return ''

    def format_minimester_sortkey(self, value):
        """The minimester sortkey is based on the ordinal value of the start date of
        a course in the minimester.  The start date is normalized by replacing its day
        of the month with a 1 (e.g. 08/03/2006 -> 08/01/2006).

        The ordinal value of the date makes them easily sortable, and automatically takes
        care of the "December needs to come first" problem in the Spring semester, for
        example.

        Without the normalization step, we end up with tons of minimester elements, one
        for each unique start date, which is bad."""
        if FormatUtils.is_minimester(self.input):
            # normalize the start date
            startdate = utils.parsedate(self.input['start-date']).replace(day=1)
            # return its ordinal value
            return str(startdate.toordinal())
        return ''

    def format_core_component(self, value):
        """Checks the rubrik and number of the given course against the
        Core Curriculum courses listed in the mappings."""
        key = '%s %s' % (self.input['rubrik'], self.input['number'])
        mapping = mappings.get(key, 'core', 'component')
        if mapping:
            return mapping[0] # the name of the component
        return None

    def format_session(self, value):
        """Some post-processing is required for the session field, which
        has already been processed by its SessionFormatter."""
        assert isinstance(value, dict)
        value = SessionFormatter.handle_new_topic_codes(value, self.input.get('topic-code',''))
        return SessionFormatter.add_defaults(value)

    def format_extra_sessions(self, value):
        """Some post-processing is required for the extra-sessions field,
        which has already been processed by its SessionFormatter."""
        assert type(value) in (list, tuple)
        return map(self.format_session, value)

    ############################################################################
    # Subject, topic and subtopic formatters
    ############################################################################
    def format_subject_name(self, value):
        # first, get the default name for this subject
        rubrik = self.input.get('rubrik','')

        rubrik_mapping = RUBRIK_MAPPING_CACHE.get(rubrik)
        if rubrik_mapping:
            default_name_mapping = rubrik_mapping.get('subject')
            default_name = default_name_mapping \
                           and default_name_mapping[0] \
                           or rubrik
        else:
            default_name = rubrik

        # then, try to see if there are regroupings that apply to this class
        name = FormatUtils.get_name_for(FormatUtils.get_class_number(self.input), 'subject')
        
        if not name:
            name = default_name
        
        # check for errors
        if 'unsorted' in name.lower():
            desc = 'Unsorted subject: "%s"' % name
            error = DataError(self.input, desc)
            profile.errors.add(error)
        
        if re.match(r'^[A-Z]{4}$', name):
            desc = 'Subject missing from mappings: "%s"' % name
            error = DataError(self.input, desc)
            profile.errors.add(error)
        
        return name

    def format_subject_comments(self, value):
        comments = FormatUtils.get_comments_for(FormatUtils.get_class_number(self.input), 'subject')
        return FormatUtils.post_process_comments(comments)
    def format_subject_sortkey(self, value):
        return FormatUtils.get_sortkey_for(FormatUtils.get_class_number(self.input), 'subject')

    def format_topic_name(self, value):
        return FormatUtils.get_name_for(FormatUtils.get_class_number(self.input), 'topic')
    def format_topic_comments(self, value):
        comments = FormatUtils.get_comments_for(FormatUtils.get_class_number(self.input), 'topic')
        return FormatUtils.post_process_comments(comments)
    def format_topic_sortkey(self, value):
        return FormatUtils.get_sortkey_for(FormatUtils.get_class_number(self.input), 'topic')

    def format_subtopic_name(self, value):
        return FormatUtils.get_name_for(FormatUtils.get_class_number(self.input), 'subtopic')
    def format_subtopic_comments(self, value):
        comments = FormatUtils.get_comments_for(FormatUtils.get_class_number(self.input), 'subtopic')
        return FormatUtils.post_process_comments(comments)
    def format_subtopic_sortkey(self, value):
        return FormatUtils.get_sortkey_for(FormatUtils.get_class_number(self.input), 'subtopic')



class SessionFormatter(BaseFormatter):
    """Formatter designed to handle the formatting of the "session"
    sub-schemas.  A lot of the actual formatting work is done by the
    session and extra-session formatters in the CreditFormatter, since
    extra information is needed to format some of the session fields."""

    def format_faculty_name(self, value):
        """If the last name of the input is in the profile.duplicate_names
        list, returns the last name and first initial.  Otherwise, returns
        just the last name (or an empty string, if no last name is given)."""
        last_name, initial = self.__get_faculty_names(value)
        if last_name and last_name in profile.duplicate_names:
            return value.strip()
        else:
            return last_name

    def format_faculty_last_name(self, value):
        last_name, initial = self.__get_faculty_names(self.input.get('faculty-name',''))
        return last_name

    def format_faculty_first_initial(self, value):
        last_name, initial = self.__get_faculty_names(self.input.get('faculty-name',''))
        return initial

    def __get_faculty_names(self, name):
        """Utility function to split the given name, in "Last Name, First Initial"
        format, into its constituent parts.  Will always return a two-tuple, which
        will contain the last name and first initial or two empty strings."""

        # if we have a faculty name and blank start or end times (not just TBA),
        # we are dealing with an extra session that should not be included
        if name.strip() and self.input.get('start-time','').strip() == '' and self.input.get('end-time','').strip() == '':
            return None, None

        # if we have a Lastname, Firstname kind of name, split it up
        if name.strip() and ',' in name:
            last_name, initial = name.split(',', 1)
            return last_name.strip(), initial.strip()

        # we don't have a name
        else:
            return '',''

    def format_days(self, value):
        """Collapses the spaces in the days of the week.  If necessary, moves
        Sunday ('U') to the end."""
        if value and value[0] == 'U':
            value = value[1:] + 'U'
        return value.replace(' ', '')

    def format_formatted_times(self, value):
        """Tries to convert the start-time and end-time of the given class into
        a nice AP-style string representation."""
        start = self.input.get('start-time', '')
        end = self.input.get('end-time', '')

        if not start.strip() or not end.strip():
            return ''

        def format_time(time):
            return time.lstrip('0').replace('AM',' a.m.').replace('PM',' p.m.').replace(':00','')

        try:
            # get the times into a known good state
            start = format_time(start)
            end = format_time(end)
            # if they are both AM or both PM, drop the first suffix
            suffixlen = len(' a.m.')
            if start[-suffixlen:] == end[-suffixlen:]:
                start = start[:-suffixlen]
            # return a nicely-formatted time string
            return '%s-%s' % (start, end)
        except IndexError:
            return ''
    
    @classmethod
    def handle_new_topic_codes(self, session_data, topic_code):
        """There are new topic codes defined for online and video-based
        classes that should supercede some of the teaching methods given in
        Colleague.  This is an UGLY HACK on the Colleague side and in this
        software.  Rules:
        
            * If a class has a teaching method of INET:
                a) If its topic code is one of OL, OLC or OLP:
                    replace the teaching method with the topic code
                b) Else:
                    replace the teaching method with a default of OL
            
            * If a class has a teaching method of TV, TVP or IDL:
                replace its teaching method with VB
        """
        method = session_data.get('method','')
        
        if method == 'INET':
            if topic_code in ('OL','OLC','OLP'):
                # If we have a valid replacement topic code, use it.
                session_data['method'] = topic_code
            else:
                # Otherwise, default to 'OL'
                session_data['method'] = 'OL'
        
        elif method in ('TV', 'TVP', 'IDL'):
            # All TV courses are given a teaching method of 'VB'
            session_data['method'] = 'VB'

        return session_data
    
    @classmethod
    def add_defaults(self, session_data):
        """Adds default values to the given session_data dict.  Has special-case
        logic for certain fields that the normal SessionFormatter formatting
        functions cannot implement.  Always returns a dict."""
        assert isinstance(session_data, dict)

        # special case for certain values of 'days'
        if session_data.get('days','') in ('UMTWRFS','MTWRFSU',):
            session_data['days'] = profile.defaults['days']

        # special case for formatted-times
        if session_data.get('start-time') in ('TBA',) or session_data.get('end-time') in ('TBA',):
            session_data['formatted-times'] = profile.defaults['time']

        def add_default(session, session_key, defaults_key=None):
            """Intelligently adds a value from the profile.defaults dict to
            the given session dict if that value is not already present."""
            defaults_key = defaults_key or session_key
            if not session.get(session_key):
                session[session_key] = profile.defaults[defaults_key]

        # intelligently add default values
        add_default(session_data, 'faculty-name', 'faculty')
        add_default(session_data, 'start-time', 'time')
        add_default(session_data, 'end-time', 'time')
        add_default(session_data, 'formatted-times', 'time')
        add_default(session_data, 'days')
        add_default(session_data, 'room')

        # Special case for non-lecture and non-lab courses:  The formatted-times and
        # room should be 'NA' rather than 'TBA', which is the default for other
        # course types.
        if session_data.get('method', '') not in ('LEC', 'LAB'):
            defaults = ['TBA', '', None]
            default_times = defaults + [profile.defaults.get('time')]
            default_days = defaults + [profile.defaults.get('days')]
            default_rooms = defaults + [profile.defaults.get('room')]

            if session_data.get('start-time') in default_times and session_data.get('end-time') in default_times:
                session_data['start-time'] = 'NA'
                session_data['end-time'] = 'NA'
                session_data['formatted-times'] = 'NA'

            if session_data.get('days') in default_days:
                session_data['days'] = 'NA'

            if session_data.get('room') in default_rooms:
                session_data['room'] = 'NA'
        
        # See if we need to map the given room to a different value, according
        # to profile.room_map
        if session_data['room'] in profile.room_map:
            session_data['room'] = profile.room_map[session_data['room']]

        return session_data


class FormatUtils:
    """FormatUtils is a class that acts as a namespace for utility
    functions used by the formatting functions in the Formatter
    classes above.  Each of the methods defined in FormatUtils needs
    to made into a static classmethod with the @classmethod decorator."""

    @classmethod
    def is_minimester(self, classdata):
        """A course counts as a "minimester" course if either of the following
        conditions are met:
            - The class is a "Flex Day" or "Flex Night" class OR
            - The class lasts less than profile.minimester_threshold weeks AND
              the class does not match any of the patterns in
              profile.skip_minimesters"""
        try:
            # collect the data we need to determine whether this is a
            # minimester class
            classtype = classdata['type']
            weeks = int(classdata['weeks'].strip())
            start_date = classdata['start-date']
            end_date = classdata['end-date']
            term = FormatUtils.get_term(classdata['term'], start_date)
            
            # does this class meet the minimum criteria?
            if classtype in ('FD', 'FN') or \
                weeks < profile.minimester_threshold or \
                FormatUtils.is_flex_hack(start_date, end_date, term): # UGLY, TEMPORARY HACK!

                # if this class matches any of the patterns in
                # profile.skip_minimesters, return False
                for key, patterns in profile.skip_minimesters.items():
                    if key in classdata and utils.any(patterns, lambda p: re.match(p, classdata[key])):
                        return False
                    elif key not in classdata:
                        print 'Inavlid key in skip_minimesters: %s' % repr(key)

                # all tests passed, so this class qualifies as a
                # minimester class
                return True

        except ValueError:
            # error converting the number of weeks to an int
            pass

        # some test along the way failed, so return False
        return False

    @classmethod
    @cached
    def is_flex_hack(self, start_date, end_date, term):
        """UGLY HACK!  A hack to include more classes in the Flex
        section of the Spring schedule.  Here is the crux of the
        problem:

        We need to include more classes in the special minimester or
        flex section of the schedule, which do not meet the criteria
        outlined above in is_minimester.  To do this, we need to
        know the exact start date and time for the term this class is
        in, which is complicated in the Summer schedule, since
        Colleague sees the May semester as just a part of Summer I,
        but we treat them separately."""

        start_date = utils.parsedate(start_date)
        end_date = utils.parsedate(end_date)

        term_start, term_end = FormatUtils.get_term_dates(term)
        one_week = datetime.timedelta(7)

        if term_start <= start_date <= (term_start + one_week) and \
           term_end >= end_date >= (term_end - one_week):
            # we are dealing with a "standard-length" course, which does not
            # belong in the "flex" section
            return False

        # we are dealing with a class that does not start or end on the
        # standard start and end dates for this term, so it belongs in
        # the "flex" section
        return True
    
    @classmethod
    @cached
    def get_term(self, term_id, class_start):
        """Determines the term for a class that starts on the given start
        date.  This method is in FormatUtils because it needs to be used
        in multiple formatters and thus should have its results cached.

        If more than one term is given in the current profile's terms dict,
        we loop through each term to see if one has start and end dates which
        contain the given class start date.  If we find a match, we return
        that term.  If we do not find a match, we return the given term_id.
        
        Otherwise, we just use the one term named in the current profile's
        terms dict."""

        # If we have more than one term in this profile, we have to check each
        # term's start and end dates to see which term contains this class.
        if len(profile.terms) > 1:
            # make sure we have a date
            if not isinstance(class_start, datetime.date):
                class_start = utils.parsedate(class_start)

            earliest = None
            latest = None
            
            # Loop through the terms in this profile, checking their start
            # and end dates with the start date of this class.
            for term, (term_start, term_end, _) in profile.terms.items():
                
                # keep track of the earliest and latest term dates, in case
                # we don't find a term to match this class
                if earliest is None or term_start < earliest:
                    earliest = term_start
                if latest is None or term_end > latest:
                    latest = term_end
                
                # if this class starts between the start and end date of the
                # term we're looking at, return that term
                if term_start <= class_start < term_end:
                    return term

            # We didn't find a matching term, so we stuff this class in the
            # earliest or latest term we can find.
            else:
                print 'Class start date %s is not in any of the terms in this profile.' % class_start

                def find_term(start_or_end, target_date):
                    """Search through the profile's terms to find one that
                    contains the given target date as either its start or end
                    date.  Parameter start_or_end must be either 0 or 1."""
                    for term, dates in profile.terms.items():
                        if dates[start_or_end] == target_date:
                            return term
                    raise AssertionError('Target date %s not found in the current profile\'s terms.' % target_date)
                
                # Figure out if we should put this class in the earliest or
                # latest term.
                if class_start < earliest:
                    return find_term(0, earliest)
                elif class_start > latest:
                    return find_term(1, latest)
                
                # Something is wrong here.
                else:
                    raise AssertionError(
                        'Class starting on %s falls between the earliest ' +
                        'and latest term dates but is not contained in any ' +
                        'the current profile\'s terms.  This is probably a ' +
                        'problem in the current profile\'s term dates.'
                    )
        
        # Otherwise, we only have one term in the profile, so we just return
        # its name, regardless of any dates.
        else:
            return profile.terms.keys()[0]

    @classmethod
    @cached
    def get_term_dates(self, term):
        """Gets the start and end dates for the given term from the current
        profile's terms dict.  If the given term is not a key in the
        terms dict, the term name is looked up in the term_names dict
        first."""
        assert term in profile.terms, \
            'Term %s not found in current profile\'s term dict.  Valid term names: %s' % (term, ', '.join(profile.terms.keys()))
        start, end, _ = profile.terms[term]
        return start, end

    @classmethod
    def get_name_for(self, search_key, regrouping_type):
        return FormatUtils.get_regroupings_for(search_key, regrouping_type)[0]
    @classmethod
    def get_comments_for(self, search_key, regrouping_type):
        return FormatUtils.get_regroupings_for(search_key, regrouping_type)[1]
    @classmethod
    def get_sortkey_for(self, search_key, regrouping_type):
        return FormatUtils.get_regroupings_for(search_key, regrouping_type)[2]
    @classmethod
    def get_regroupings_for(self, search_key, regrouping_type):
        """Utility function which searches the mappings/regroupings
        for a set of regroupings that matches the pattern defined by
        search_key with the given regrouping_type, which should be
        one of 'subject', 'topic' or 'subtopic'.

        Always returns a three-tuple of (name, comments, sortkey) or
        ('', '', '') if no regrouping is found.

        If profile.regroupings is not True, always returns a three-tuple
        of empty strings: ('', '', '').
        """

        # Do we even need to figure out regrouping information?
        if profile.regroupings:
            assert regrouping_type in ('subject', 'topic', 'subtopic')
            cached_regroupings = FULL_MAPPING_CACHE.get(search_key, {})

            regroupings = cached_regroupings \
                          and cached_regroupings.get(regrouping_type) \
                          or None

            if regroupings:
                assert len(regroupings) == 3
                return regroupings

        # Either no regroupings were found or profile.regroupings is False.
        return ('', '', '')

    @classmethod
    def get_class_number(self, record):
        """A utility function to generate a 'class number', which is
        a combination of the rubrik, number and section."""
        return '%(rubrik)s %(number)s-%(section)s' % record


    @classmethod
    def post_process_comments(self, value):
        """Runs a set of regular expression patterns and replacements over the
        input value to, e.g., wrap every URL in a <url> tag."""

        if value is None:
            return ''
        
        # regular expressions to apply
        regexes = [
            # urls
            (r'((http://|www\.)+(www\.)?[A-Za-z0-9\.\-]+\.{1}[A-Za-z]{3}[A-Za-z0-9\.\-\_/]*)\b',
             r'<url>\1</url>'),

            # emails
            (r'([A-Za-z0-9\.\_\-]+@[A-Za-z0-9\.\-]+\.{1}[A-Za-z]{3})\b',
             r'<email>\1</email>'),
        ]
        
        # UGLY HACK: A flag to tell whether we have already XML-escaped the value
        already_escaped = False

        # apply each regex
        for pattern, replace in regexes:
            # Check to see if we need to XML-escape the given value.  We only need to escape
            # the value if it matches one of the patterns, if it is not already escape and if
            # it is not already an XML fragment (from a "rich" comment in the mappings)
            if re.search(pattern, value) and not xmlutils.is_xml_fragment(value) and not already_escaped:
                value = xmlutils.xml_escape(value)
                already_escaped = True
            value = re.sub(pattern, replace, value)

        return value


class DataError(Exception):
    """An error encountered in the schedule data, to be reported to the
    user after the XML has been built."""
    def __init__(self, classdata, description):
        try:
            self.course = FormatUtils.get_class_number(classdata)
            self.regnum = classdata['synonym']
            # should we ignore this error?
            self.ignore = classdata['topic-code'] in profile.skip_topic_codes
        except KeyError:
            self.course = 'Unknown course'
            self.regnum = 'XXXXXX'
        self.description = description

    def __hash__(self):
        return hash(str(self))

    def __cmp__(self, other):
        return cmp((self.description, self.course), (other.description, other.course))

    def __str__(self):
        return '%s    #%s    %s' % (self.course, self.regnum, self.description)
