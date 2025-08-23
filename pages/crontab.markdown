---
layout: default
title: The Crontab
parent: Config
nav_order: 2
---

As previously mentioned, this script relies on cronjobs to execute the scans. I have this configured to every hour or so per `/24` subnet. For those unaware on how to configure the crontab, enter in `crontab -e`, select your editor of preference, then add in entries like the one below:
<br>
```bash
10 * * * * /bin/bash /home/skywalker/WompRat/Scripts/scan10dev.sh -n 10.0.20.0 -m 24 -f 192.168.11.1 -t 2 -d 10.0.20.2
```
<br>
I trust you know how cronjobs are formatted, if not that's only a google search away. As for the rest of these flags, the `-n` designates your network, using my example it is `10.0.20.0`. The network mask `-m` is a `/24`, so everything in that range will be scanned. Alternatively, you may use a hyphen, so perhaps you choose `-n 10.0.20.0-255 -m 0` instead (the mask flag is ignored in this case, but still needs to be defined). This allows for more granular control when you may want to avoid scanning certain IP scopes.
<br><br>
The `-f` designates the IP of your firewall/router that you will be pulling the arp tables from. This was necessary for me as I initially used direct pings followed by arp requests to check if a) the host was online and b) to get the MAC of the device. This only extends to your local subnet, however, (duh), so this became necessary in my environment. More on this on the next page.
<br><br>
The `-t` designates the firewall/router type - in other words which profile it will use to remote in and pull data. I list the currently supported types later, but you can always write your own profile.
<br><br>
The `-d` designates your local DNS server, in my case a Windows Server. More on this later.
<br><br>
Lastly, you may install a couple of other cronjobs that will send you automatic daily email updates of any unknown devices that have been discovered. If you wish to configure this refer to the [notifications](/pages/notifications) page.
<br><br>
