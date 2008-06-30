import re

class Event(object):
    def __init__(self):
        self.times = '';
        self.rooms = '';
        self.text = '';

    def SetTimes(self, times):
        assert(type(times) == str), 'ERROR: times must be a string';

        # since any existing value of times will be overwritten,
        #   display warning if times not empty
        if (len(self.times) != 0): print 'Warning: times not empty\n  current value is:', self.times, '\n  replacing with:', times;
        
        # convert to ap standard
        times = times.split('-');
        self.times = toAP(times[0]) + '-' + toAP(times[1]);
        self.times.strip();

    def AddRoom(self, room):
        assert(type(room) == str), 'ERROR: room must be a string';

        if (self.rooms != ''):
            self.rooms += ', ';
        self.rooms += room;
        self.rooms.strip();

    def AddText(self, text):
        assert(type(text) == str), 'ERROR: text must be a string';

        if (self.text != ''):
            self.text += ' ';
        self.text += text;
        self.text.strip();

    def IsEmpty(self):
        return (self.times + self.rooms + self.text == '');

    def __str__(self):
        temp  = 'EventObject\n';
        temp += '  times:' + str(self.times) + '\n';
        temp += '  rooms:' + str(self.rooms) + '\n';
        temp += '  text:'  + str(self.text)  + '\n';
        return temp;

    def FormatASPX(self, level):
        assert(type(level) == int), 'ERROR: level must be an integer';
        
        aspx  = '\t'*level + '<li>' + str(self.times) + '<br />\n'; level+=1;
        aspx += '\t'*level + '<b>' + str(self.text) + '</b><br />\n';
        aspx += '\t'*level + 'Room ' + str(self.rooms) + '</li>\n'; level-=1;

        return aspx;


# helper function
def toAP(time):
    assert(type(time) == str), 'ERROR: time must be a string';

    match = re.search('([0-9]{1,2})(:[0-9]{2})?([ap])', time);
    if (not(match)):
        print 'ERROR: Could not convert invalid time (' + time + ') to ap style';
        return 'invalid time';

    else:
        hour = match.groups()[0];
        mins = '';
        apm  = '';
        if (len(match.groups()) == 3):
            mins = match.groups()[1];
            apm  = match.groups()[2];
        else:
            apm  = match.groups()[1];

        if (mins == None):  mins = '';
        if (mins == ':00'): mins = '';
        if (apm  == 'a'):   apm  = ' a.m.';
        if (apm  == 'p'):   apm  = ' p.m.';

        time_str = hour + mins + apm;

        if (time_str == '12 p.m.'): time_str = 'noon';
        if (time_str == '12 a.m.'): time_str = 'midnight';

        return time_str;
    

class Day(object):
    def __init__(self, day):
        assert(type(day) == int), 'ERROR: day must be initialize with an integer day of the month';
        self.day = day;
        self.events = [];

    def AddEvent(self, event):
        assert(type(event) == Event), 'ERROR: event must be an Event object (type = ' + str(type(event)) + ')';

        if(not(event.IsEmpty())):
            self.events.append(event);

    def __str__(self):
        temp  = 'DayObject\n';
        temp += '  day:' + str(self.day) + '\n';
        temp += '  ' + str(len(self.events)) + ' events\n';
        return temp;

    def FormatASPX(self, level):
        assert(type(level) == int), 'ERROR: level must be an integer';
        
        aspx  = '\t'*level + '<ul>\n';
        for e in self.events:
            aspx += e.FormatASPX(level+1);
        aspx += '\t'*level + '</ul>\n';

        return aspx;

month_list = ['january', 'february', 'march', 'april', 'may', 'june',
              'july', 'august', 'september', 'october', 'november', 'december'];
day_list = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
class Calendar(object):
    def __init__(self):
        self.date  = '';
        self.first = 0;
        self.last  = 0;
        self.days  = [];

    def SetDate(self, date):
        assert(type(date) == str), 'ERROR: date must be a string';

        month, year = date.lower().split(' ');
        if (not(month in month_list)): print 'ERROR: unknown month: ' + month; return False;
        if (not(len(year) == 4 and re.match('[0-9]{4}', year))): print 'ERROR: invalid year: ' + year; return False;

        self.date = month[0].upper() + month[1:] + ' ' + year;
        return True;

    def SetDayFirst(self, first):
        assert(type(first) == str), 'ERROR: first day must be a string';

        first = first.lower();
        if (not(first in day_list)): print 'ERROR: unknown first day: ' + first; return False;

        self.first = day_list.index(first);
        return True;

    def SetDayLast(self, last):
        assert(type(last) == str), 'ERROR: last day must be a string';

        last = int(last);
        if (last < 1 or last > 31): print 'ERROR: invalid last day: ' + str(last); return False;

        self.last = last;
        return True;

    def AddDay(self, day):
        assert(type(day) == Day), 'ERROR: day must be a Day object';

        self.days.append(day);

    def __str__(self):
        temp  = 'CalObject\n';
        temp += '  date:' + str(self.date) + '\n';
        temp += '  first:' + str(day_list[self.first]) + '\n';
        temp += '  last:' + str(self.last) + '\n';
        temp += '  ' + str(len(self.days)) + ' days\n';
        return temp;

    def FormatASPX(self):
        aspx = aspx_start + self.date + aspx_middle;
        level = 7;

        # start first week
        aspx += '\t'*level + '<tr>\n';
        level+=1;

        # if the week doesn't start on monday, padd it over
        if (self.first != 0):
            aspx += '\t'*level + '<td colspan="' + str(self.first) + '">&nbsp</td>\n';

        # while we're not finished
        day_cur = 0;
        index_cur = 0;
        while (day_cur + self.first < self.last):
            # if we have a new week, start a new row
            if ((day_cur + self.first) % 7 == 0):
                aspx += '\t'*(level-1) + '</tr>\n\n';
                aspx += '\t'*(level-1) + '<tr>\n';
            
            # next day
            day_cur+=1;

            # make date
            aspx += '\t'*level + '<td>' + str(day_cur) + '\n';
            level+=1;
            
            # check for events
            if (index_cur < len(self.days) and self.days[index_cur].day == day_cur):
                aspx += self.days[index_cur].FormatASPX(level);
                index_cur+=1;
                while (index_cur < len(self.days) and self.days[index_cur].day == day_cur):
                    print 'ERROR: duplicate entries for day:', day_cur;
                    index_cur+=1;

            # if this is a weekend day, stuff sunday in as well
            if ((day_cur + self.first) % 7 == 6):
                aspx += '\t'*level + '<hr />\n\n';

                # if the sunday is part of this month
                if (day_cur < self.last):
                    # advance to sunday
                    day_cur+=1;

                    # make date
                    aspx += '\t'*level + str(day_cur) + '\n';
                    
                    # check for events
                    if (index_cur < len(self.days) and self.days[index_cur].day == day_cur):
                        aspx += self.days[index_cur].FormatASPX(level);
                        index_cur+=1;
                        while (index_cur < len(self.days) and self.days[index_cur].day == day_cur):
                            print 'ERROR: duplicate entries for day:', day_cur;
                            index_cur+=1;

            # close box
            level-=1;
            aspx += '\t'*level + '</td>\n';

        # ok, we've finished all the days, whatever's left over is colspanned
        if (day_cur + self.first % 7 != 0):
            aspx += '\t'*level + '<td colspan="' + str(7 - day_cur % 7) + '">&nbsp</td>\n';

        # and close the row
        level-=1;
        aspx += '\t'*level + '</tr>\n';

        # and finish off the aspx
        aspx += aspx_end;

        # done!
        return aspx;


# all the aspx junk that'd clutter up the above code
aspx_start = """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Register tagprefix="bhc" Tagname="meta" src="~/includes/meta.ascx" %>
<%@ Register tagprefix="bhc" Tagname="header" src="~/includes/header.ascx" %>
<%@ Register tagprefix="bhc" Tagname="channel" src="~/emgi/channelhd.ascx" %>
<%@ Register tagprefix="bhc" Tagname="sidebar" src="~/emgi/sidebar.ascx" %>
<%@ Register tagprefix="bhc" Tagname="footer" src="~/includes/footer.ascx" %>

<html>
	<head>
		<!-- include sitewide stylesheets and scripts -->
		<bhc:meta title="Ellison Miles Geotechnology Institute: Calendar of Events" runat="server" />
		<!-- include page-specific stylesheets here -->
		<link rel="stylesheet" type="text/css" href="/emgi/emgi.css" />
		<link rel="stylesheet" type="text/css" href="/emgi/calendar.css" />
		<style type="text/css">
			.redhot { color: #C20; }
		</style>
	</head>
	
	<body>
		<bhc:header runat="server" />
		<bhc:channel runat="server" />
		
		<table id="sidebar-layout-table" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td id="sidebar-in-table" valign="top"><bhc:sidebar runat="server" /></td>
				<td valign="top">
					<div id="page-header">
						<div id="breadcrumbs">
							<a href="/instruction/">Instructional Areas</a> &raquo;
							<a href="/emgi/">Ellison Miles Geotechnology Institute</a> &raquo;
							<a class="selected">Calendar</a>
						</div>
						<h1>""";
aspx_middle = """</h1>
					</div>
					
					<div id="page-content">
						<table width="100%" border="1" cellpadding="5" cellspacing="0" class="calendar">
							<tr>
								<th>Mon</th>
								<th>Tues</th>
								<th>Wed</th>
								<th>Thurs</th>
								<th>Fri</th>
								<th>Sat<br />
									Sun</th>
							</tr>
""";
aspx_end = """<td colspan="5">
                                        
									
							  </td>
								
								<!-- finish out the square for days the month doesn't have -->
								
							</tr>
						</table>
						<p align="center"><A HREF="calendar-archive.aspx"><strong>Calendar Archive</strong></A></p>
						<p>&nbsp;</p>
					</div> <!-- end page-content -->
				</td>
			</tr>
		</table>


		
		<!-- include the sitewide footer -->
		<bhc:footer runat="server" />
	</body>
</html>"""
