---
layout: default
title: Notifications
parent: Config
nav_order: 6
---

Not to be confused with the [alerts](/pages/alerts) page, this is a daily email I send myself for review, which can also be run manually. The email contains a list of every unknown device that was discovered that day so far using a couple of scripts to get the job done.

First thing to note is how this is configured in the crontab:
```bash
# Noon email update
0 12 * * * echo '' > /home/skywalker/WompRat/Scripts/updateMe.log && /bin/bash /home/skywalker/WompRat/Scripts/updateMe2.sh >> /home/skywalker/WompRat/Scripts/updateMe.log
5 12 * * * /usr/bin/python3 /home/skywalker/WompRat/Scripts/send_email_v3.py --recipient "recipient@domain.com" --subject "Daily unknown devices log" --body "file:/home/skywalker/WompRat/Scripts/updateMe.log"
```
<br>
Feel free to review the file in full, but what this is doing is over-writing the log file at noon and collecting the records of every unique IP stored in all the `nmapScans/` directories for that day into one file. Any files in there after all would indicate an IP was flagged as unknown and an initial nmap scan was conducted. It sorts and copies all of this data to a log file, which is eventually emailed to whatever address you designate. And no, it won't include 24 instances of the same IP address, only the first scan of an IP will be included to avoid a horribly long and confusing log.
<br><br>
I do want to note very briefly that the `--body` section of that python script can either be straight text or it can attach the contents of a text file like you see me doing by prepending `file:`, then the file location. Just a useful function I decided to build in, otherwise the body content will be whatever the flag's string is. For the `updateMe2.sh` script, not including any arguments defaults to searching logs from that day, including a single argument formatted as `YYYY-MM-DD` will search that day instead (assuming the directory exists). The only time a unique day would be selected is if you were running this manually looking for something.
<br><br>
You can locate both of the scripts used on this page in the main `WompRat/Scripts/` directory, and keep an eye out for more recent versions than the above cronjob shows.
<br><br>
Last thing for this page - the update/notification this sends out includes information about the MAC vendor using a local database I've downloaded. The db is from <a href="https://maclookup.app/downloads/csv-database" target="_blank" rel="noopener noreferrer">maclookup.app</a> and should be saved to `WompRat/Data/mac-vendors-export.csv`.
<br><br>
