# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   05 November 2007
# Modified:  05 November 2007

# Synopsis:
# Contains the data structures used in the BHC Schedule Builder


# Transform is just a cheezy little struct
class Transform(object):
    __init__(self):
        self.semester = '';
        self.year = '';
        self.transform = '';

    SetTo(self, semester, year, transform):
        self.semester = semester;
        self.year = year;
        self.transform = transform;

    SetSemester(self, semester):
        self.semester = semester;

    SetSemester(self, semester):
        self.semester = semester;

    SetSemester(self, semester):
        self.semester = semester;

    # extremely simplistic, just makes sure everything's been set
    IsValid(self):
        return ((self.semester != '') and (self.year != '') and (self.transform != ''));
