# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   07 August 2007
# Modified:  07 August 2007

# Synopsis:
# Defines data structures to hold and process shedule builder pattern data.
# This is a little redundant, but it makes for clear reading on the other end.

# def GetType()
# an exception-safe way to get the data type of data_lib objects
# input:  obj - the object whose type is to be tested
# output: what type of data_lib object was passed in
#         if the object is not a data_lib object, None is returend
def GetType(obj):
        # get type
        try:
            data_type = obj.GetType();
        except (AttributeError):
            data_type = None;
        return data_type;

# list of data types
type_Subject  = 'Subject';
type_Topic    = 'Topic';
type_Subtopic = 'Subtopic';
type_Pattern  = 'Pattern';

# generic base class
class Item(object):
    __limit__ = ['name', 'comment', 'pattern_list', 'child_list'];
    
    def __init__(self):
        self.name = '';
        self.comment = '';
        self.pattern_list = [];
        self.child_list = [];

    def __init__(self, name):
        assert(type(name) == str);
        self.name = name;
        self.comment = '';
        self.pattern_list = [];
        self.child_list = [];

# holds subject data
class Subject(Item):
    def GetType(self):
        return type_Subject;

# holds topic data
class Topic(Item):
    def GetType(self):
        return type_Topic;

# holds subtopic data
class Subtopic(Item):
    def GetType(self):
        return type_Subtopic;

# holds pattern data
class Pattern(object):
    __limit__ = ['match'];
    
    def __init__(self):
        self.name = '';

    def __init__(self, match):
        assert(type(match) == str);
        self.match = match;

    def GetType(self):
        return type_Pattern;
