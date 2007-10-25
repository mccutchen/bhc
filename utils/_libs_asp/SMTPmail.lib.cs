// Author:   Travis Haapala
// Email:    thaapala@dcccd.edu
// Phone:    972-860-4104
// Division: MPI
// Date:     Aug. 28, 2007
// Modified: Aug. 30, 2007
// Required: Import Namespace="System.Web.Mail"

/* Description
A simple interface for sending smtp mail :)
*/

// some globals
bool   SMTPmail_debug = false;  // set to true in your app if you want debug messages.
bool   default_html   = false;
string default_server = "smtp.dcccd.edu";

// here's some error codes
int SMTPerror_none    = 0,
    SMTPerror_failure = 1;


// sends an email
int SendMail(string to, string from, string subject, string body)
{ return SendMail(to, from, subject, body, default_html, default_server); }
int SendMail(string to, string from, string subject, string body, bool html)
{ return SendMail(to, from, subject, body, html, default_server); }
int SendMail(string to, string from, string subject, string body, bool html, string server)
{
	// processing var
	int err_code = SMTPerror_none;
	
	// create MailMessage object
	MailMessage message = new MailMessage();
	
	// stuff data into MailMessage object
	message.To         = to;
	message.From       = from;
	message.Subject    = subject;
	if (html) { message.BodyFormat = MailFormat.Html; }
	else      { message.BodyFormat = MailFormat.Text; }
	message.Body       = body;
	
	// set our mail server
	SmtpMail.SmtpServer = server;
	
	// send email
	if (!SMTPmail_debug)
	{
		try
		{
			SmtpMail.Send(message);
		}
		catch
		{
			err_code = SMTPerror_failure;
		}
	}
	else
	{
		SmtpMail.Send(message);
	}
	
	// return error, or lack thereof
	return err_code;
}

/* Ok... this is the new way to do it, but we're (unbelievably) still running ASP v1.1

using System.Net.Mail;

// create the email message
MailMessage message = new MailMessage("feedback_form@brookhavencollege.com",
									  "thaapala@dcccd.edu",
									  "New Feedback Recieved",
									  "This is a test\nThis is only a test\nIf this were actual feedback, it would be useful.");

// create and add the attachment(s)
Attachment attachment = new Attachment("sample.doc",
									   MediaTypeNames.Application.Octet);
message.Attachments.Add(attachment);

// create SMTP Client and add credentials
SmtpClient smtpClient = new SmtpClient("Your SMTP Server");
smtpClient.UseDefaultCredentials = false;
// Email with Authentication
smtpClient.Credentials = new NetworkCredential("userID", 
"password", "domainName");

// Send the message
smtpClient.Send(message);

*/