# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   15 May  2007
# Modified:  03 July 2007

# Synopsis:
# Defines classes for assiting in the creation of a menu-driven script


# base class for menu-driven portions of an application
class Menu:
    menu_str   = '';
    id_min     = 0;
    id_max     = 1;

    # def DisplayMenu()
    # input:  valid_list 
    def DisplayMenu(self):
        valid = False;
        while (not valid):
            print self.menu_str;
            opt = raw_input('Enter selection: ');
            if (opt.isdigit() and int(opt) < self.id_max and int(opt) > self.id_min):
                return int(opt);
            else:
                print "Invalid entry, please try again";

# extended class that takes a title and list of options, then prompts the user to choose
class ExtMenu(Menu):
    def __init__(self, title, opt_list):
        assert (type(opt_list) == list), 'MultiScan.multiscan_lib.LoadMenu.__init__(): file_list must be a list of strings';

        # set max
        self.id_max = len(opt_list) + 1;

        # set opt_buf
        opt_buf = ' ';
        temp_int = self.id_max;
        while (temp_int > 9):
            opt_buf = opt_buf + ' ';
            temp_int = temp_int / 10;

        # set menu_str
        self.menu_str = [title + '\n']
        i = 0;
        for opt in opt_list:
            # update counter
            i = i + 1
            
            # set indent
            if (i % 10 == 0):
                opt_buf = opt_buf[1:];

            # add line for current file
            self.menu_str.append(opt_buf + str(i) + ') ' + opt + '\n');

        # join it
        self.menu_str = ''.join(self.menu_str);
