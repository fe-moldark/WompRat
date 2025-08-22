---
layout: default
title: Search Function
nav_order: 4
---

It became necessary to painfully look through log files for specific devices by their MAC address, so I wrote a script to make it easier and neater. The function is especially useful in determining patterns of when a particular unknown device is online, is it using a static address, how long has it been online for, etc.
<br><br>
This was written in Python and I created an alias in the `.bashrc` file as well, reference the [initial install](/pages/install) page for that. This file should be located in `WompRat/Scripts/search_for_mac.py`.
<br><br>
The script requires one mandatory flag and two optional ones. The MAC address must be specified using `-mac 01:23:45:67:89:ab`. Only using this flag will default to searching **all** log files in the `WompRat/Logs/` directory, which is probably more than you want. To narrow this down you can additionally include the `-start YYYY-MM-DD -end YYYY-MM-DD` flags, which do exactly what one would expect. So, this would be run as something like: `search -mac 01:23:45:67:89:ab -start 2025-05-23 -end 2025-05-30`.
<br><br>
