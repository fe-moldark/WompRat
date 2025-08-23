import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import argparse
import os


parser = argparse.ArgumentParser(description="Flags for email script.")

parser.add_argument("--recipient", required=True, help="Recipient address")
parser.add_argument("--subject", required=True, help="Subject of email")
parser.add_argument("--body", required=True, help="Body of message, or as link to file using format 'file:/location/of/file.log'")

args = parser.parse_args()


sender_email = "contact@domain.com"
receiver_email = str(args.recipient)
subject = str(args.subject)

# Body content comes in two forms, straight text or in log file
# if the 'body' parameter is prepended by 'file:', it will attempt to use its contents as the message body
body=str(args.body)
if str(body)[0:5]=="file:":
    file_loc=str(body[5:])
    if os.path.exists(file_loc):
        readFile=open(file_loc,"r")
        body=readFile.read()
        readFile.close()
    else:
        print('! There was an error reading the file input at: '+str(file_loc))
        body=' ! There was an error reading the file input at: '+str(file_loc)
else:
    pass # Use the body text as it was loaded into as an argument


app_password = "oh good I remembered to remove this..."

msg = MIMEMultipart()
msg['From'] = sender_email
msg['To'] = receiver_email
msg['Subject'] = subject
msg.attach(MIMEText(body, 'plain'))


try:
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465)
    server.login(sender_email, app_password)
    text = msg.as_string()
    server.sendmail(sender_email, receiver_email, text)
except Exception as e:
    print(f"Error: {e}")
finally:
    server.quit()

