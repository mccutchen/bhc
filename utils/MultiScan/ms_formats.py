# Author:    Travis Haapala
# Section:   Brookhaven MPI
# e-mail:    thaapala@dcccd.edu
# extention: x4104
# Created:   03 July 2007
# Modified:  03 July 2007

# Synopsis:
# just cleans up the code in multiscan by moving all the formatting junk into this file

import ms_data_lib as data_lib

class WebOutputFormat:
    # clean up the code a bit with a short-form
    x = data_lib.fmt.id;

    # set up res_fmt
    res_fmt = data_lib.fmt();
    res_fmt.SetFmt(['norm'],
                   [x('indent'),'<html>\n',x('level+'),
                    x('indent'),'<head>\n',x('level+'),
                    x('indent'),'<link rel="stylesheet" href="results_style.css" type="text/css" />\n',x('level-'),
                    x('indent'),'</head>\n',
                    x('indent'),'<body id="scan">\n',x('level+'),
                    x('indent'),'<div id="page-container">\n',x('level+'),
                    x('indent'),'<div class="results">\n',x('level+'),
                    x('indent'),'<div class="title results_title">',x('hits'),' result(s) found.</div>\n',
                    x('data'),x('level-'),
                    x('indent'),'</div>\n',x('level-'),
                    x('indent'),'</div>\n',x('level-'),
                    x('indent'),'</body>\n',x('level-'),
                    x('indent'),'</html>']);

    # set up node_fmt
    node_fmt = data_lib.fmt();
    node_fmt.SetFmt(['norm'],
                    [x('indent'),'<div class="node">\n',x('level+'),
                     x('indent'),'<div class="title node_title">',x('hits'),' - ',x('name'),'</div>\n',x('level+'),
                     x('data'),x('level-'),
                     x('indent'),'</div>\n']);
    node_fmt.SetFmt(['first','only'],
                    [x('indent'),'<div class="node_first">\n',x('level+'),
                     x('indent'),'<div class="title node_title">',x('hits'),' - ',x('name'),'</div>\n',x('level+'),
                     x('data'),x('level-'),
                     x('indent'),'</div>\n']);

    # set up loc_fmt
    loc_fmt = data_lib.fmt();
    loc_fmt.SetFmt(['norm'],
                   [x('indent'),'<div class="loc">\n',x('level+'),
                    x('indent'),'<div class="title loc_title"> (',x('row'),',',x('col'),'): \'',x('str'),'\'</div>\n',
                    x('indent'),'<div class="line">',x('pre'),'<span class="str">',x('str'),'</span>',x('fol'),'</div>\n',x('level-'),
                    x('indent'),'</div>\n',x('level-')]);
    loc_fmt.SetFmt(['last','only'],
                   [x('indent'),'<div class="loc_last">\n',x('level+'),
                    x('indent'),'<div class="title loc_title"> (',x('row'),',',x('col'),'): \'',x('str'),'\'</div>\n',
                    x('indent'),'<div class="line">',x('pre'),'<span class="str">',x('str'),'</span>',x('fol'),'</div>\n',x('level-'),
                    x('indent'),'</div>\n',x('level-')]);


    def res():
        return WebOutputFormat.res_fmt;
    res = staticmethod(res);

    def node():
        return WebOutputFormat.node_fmt;
    node = staticmethod(node);

    def loc():
        return WebOutputFormat.loc_fmt;
    loc = staticmethod(loc);

    # note: this is more for documentation and to give you a starting
    #         point if you decide to write a new stylesheet. You can
    #         copy-paste this into a css and have it work or write a
    #         script to allow for certain variations as you please.
    #         I like it as-is.
    def css():
        return '''
body#scan
{
    background-color: #FFFFFF;
}
body#scan div
{
    margin-left:      25px;
    border-left:      1px solid #000000;
    font-size:        12pt;
}
body#scan div.title
{
	margin-left:      0px;
	border-left:      0px;
	border-bottom:    1px solid #000000;
	padding-left:     7px;
	font-weight:      bold;
	font-size:        14pt;
}

body#scan div#page-container
{
	background-color: #EEEEEE;
	margin-left:      0px;
	border:           0px;
	padding:          15px 15px 15px 15px;
}
body#scan div.results
{
	margin-left:      0px;
	border:           1px solid #000000;
	padding-left:     0px;
}
body#scan div.results_title
{
	background-color: #FFCCCC;
}
body#scan div.node
{
	border-top:       1px solid #000000;
}
body#scan div.node_first
{
	border-top:       0px;
}
body#scan div.node_title
{
	background-color: #CCFFCC;
}
body#scan div.loc
{
	border-bottom:    1px solid #000000;
}
body#scan div_loc_last
{
	border-bottom:    0px;
}
body#scan div.loc_title
{
	border-bottom:    0px;
	background-color: #FFFFCC;
}
body#scan div.line
{
	border-left:     0px;
}
body#scan span.str
{
	font-weight:     bold;
	text-decoration: underline;
	font-size:       150%;
}''';
    css = staticmethod(css)
