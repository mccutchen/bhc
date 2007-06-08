<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ register tagprefix="bhc" tagname="header" src="~/includes/header.ascx" %>
<%@ register tagprefix="bhc" tagname="meta" src="~/includes/meta.ascx" %>
<%@ register tagprefix="bhc" tagname="footer" src="~/includes/footer.ascx" %>
<html>
    <head>
        <bhc:meta title="Concurrent Enrollment" runat="server" />
        <style type="text/css">
            ul {
                list-style-type: none;
                margin: 1em 2em;
                padding: 0;
            }
            li {
                margin: 0;
                padding: 0;

                margin-bottom: 1em;
                padding-left: 26px;
                background: transparent url(/images/bhc/icons/silk/accept.gif) no-repeat 0 4px;
            }
        </style>
    </head>
    <body>
        <bhc:header runat="server" />

        <div id="page-header">
            <div id="breadcrumbs">
                <a href="/">Home</a>&nbsp;&nbsp;&raquo;&nbsp;
                <a href="/course-schedules/">Course Schedules</a>&nbsp;&nbsp;&raquo;&nbsp;
                <a href="/course-schedules/non-credit/">Noncredit</a>&nbsp;&nbsp;&raquo;&nbsp;
                <a class="selected">Concurrent Enrollment</a>
            </div>
            <h1>Credit Courses Not for Credit:  Concurrent Enrollment</h1>
        </div>

        <div id="page-content">
            <p>Most Brookhaven College credit courses are available for noncredit enrollment. Enrollment in any course that is not for credit is completed through the <a href="/instruction/cce/">Corporate and Continuing Education Division</a>.</p>
            <p>It is important to remember that enrollment is based upon space availability and, where applicable, completion of appropriate assessment and advising.</p>
            <p>Tuition is charged at the Dallas County Community College District&#8217;s credit tuition rate and lab costs may apply.</p>
            <p>For concurrent enrollment in a credit course, please follow the following procedure.</p>
            <ul>
                <li><h3>STEP 1:</h3> Choose the credit course you want to take and determine the course and section number.</li>
                <li><h3>STEP 2:</h3> Obtain a concurrent enrollment form in the Corporate and Continuing Education Division office. <strong>Important: some credit courses require division approval</strong>. The CCE Office will be able to advise you about which ones require advance approval from the instructional division.</li>
                <li><h3>STEP 3:</h3> Bring your completed registration form to the Corporate and Continuing Education Division Office, Student Services Center, Building S, Room S022.</li>
                <li><h3>STEP 4:</h3> Pay for your courses at the Cashier&#8217;s Office.  Your tuition receipt shows the class location and scheduled meeting time.  Please show your paid tuition receipt to the instructor at your class.</li>
            </ul>
            <p class="special-notice"><strong>IMPORTANT NOTE:</strong> Noncredit courses also are subject to the third-attempt tuition policy.</p>
        </div>

        <bhc:footer runat="server" />
    </body>
</html>
