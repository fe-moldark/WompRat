---
layout: default
title: White-listing MACs and MAC vendors
parent: Config
nav_order: 5
---

The second way devices are recognized as valid/known/trusted on the network is through their MAC address.
<br><br>
Allow listing MACs in this context is done through exact matches or through the OUI portion. A good example of the latter case would be something like sensors or other IOT devices that might get swapped out on the regular but are all from the same manufacturer. As I've said on other pages but will reiterate here, ID'ing devices by MAC only can be problematic in that the address can be spoofed, which might allow someone to go undetected. The good news is that the log files will reflect why a device was ignored or designated for further scanning regardless, so you can always look back and review.
<br><br>
The two files for this are located at:
```
WompRat/
 ├─ Data/
    ├─ whitelisted_macs.csv
    ├─ whitelisted_macs_vendors.csv
```
<br>
These are formatted as below, although only the first two columns are really needed, the rest is just extra info:
`MAC-address,descriptor,last-ip,connected-switch,port-number,notes`
<br><br>
The MAC address must be formatted as `01:23:45:67:89:ab` or `01:23:45` depending on the file. It would be wise to periodically review this as sensors, printers, etc are removed from your network and ensure these lists do not get too inflated and as a result, unmanageable. Something I would also like to write is an automated script that will search through log files for you and if it has not seen the device in the past 6 months (or whatever time frame you set), it would log these for deletion or automatically remove them. Maybe that'll be included in version 2.
<br><br>



