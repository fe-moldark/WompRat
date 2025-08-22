---
layout: default
title: Alerts
parent: Config
nav_order: 7
---

While I was conducting the initial review of devices and deciding what needed white-listed or further reviewed, I noticed some devices would only be online for a few hours at a time, making it difficult to conduct more extensive nmap scanning and otherwise try and ID the device. As a result, I created an alert mechanism that'll notify me via email whenever a device matching criteria in the `alerts.csv` file is found in the base scans.
<br><br>
This file is located at `WompRat/Data/alerts.csv` and is formatted as (for example):
```
MAC_to_alert_on,SingleRecipientAddress,Reason why
40:3f:8c:11:11:11,contact@wesleykent.com,Unkown TP Link device
```
<br>
For more context look in the main `scan.sh` script for the section starting with `alerts_location=''`, this loads in the csv and creates a basic dictionary to house the info. Later in the script look for the section starting with `if [[ -v alerts_dict[$macLookupResult] ]]; then`, which will actually send out the alert if a match is found. It uses the same script as the [notifications](/pages/notifications) page from earlier:
```bash
/usr/bin/python3 /home/skywalker/WompRat/Scripts/send_email_v3.py --recipient "$sendRecipient" --subject "MAC Alert - $macLookupResult" --body "$bodyContent"
```
<br>
I won't go over how to set up the email app password and all that since there are already so many tutorials on how this is done. Once you get it all generated you can swap out the sender email and password in the script.
<br><br>
