---
layout: default
title: Log Structure
nav_order: 3
---

I feel this is relatively straight-forward, but that may not be a shared sentiment. The log structure is formatted as the following:
```
WompRat/
 ├─ Logs/
    ├─ YYYY-MM-DD/
       ├─ HH-MM-SS/
          ├─ nmapScans/
             ├─ 10_xx_xx_xx.nmap
          ├─ arpTable.log
          ├─ dns_data.log
          ├─ dns_data_reformatted.log
          ├─ log.csv
          ├─ stdouterr.log
```
<br>
Obviously scans from the same day will be under the same directory and every time a new cronjob begins a new scan/folder using the `HH-MM-SS` time will be created.
<br><br>
The `nmapScans/` directory will house the scans of all _unknown_ devices that were discovered and run during the cronjob.
<br><br>
The `arpTable.log` file contains the arp cache that was pulled from the router, this is used for relating IPs to their MACs for device identification and white-listing purposes.
<br><br>
The `dns_data.log` file is the raw dns A records that were pulled from the Windows DNS Server. The reformatted `dns_data_reformatted.log` file is a cleaned up version stored in a dictionary format.
<br><br>
The `log.csv` file is the primary log file of which devices were online and why they were either ignored due to being a domain joined device or white-listed MAC, or were flagged for further scanning.
<br><br>
The `stdouterr.log` contains the standard output and errors from the `scan.sh` script, which includes some useful data about what settings were used and much more.
<br><br>
