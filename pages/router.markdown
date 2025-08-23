---
layout: default
title: Pulling Routers' ARP tables
parent: Config
nav_order: 3
---

I would advise creating a bare-bone, read-only service account to ssh into the router and pull the arp table. Take further steps to limit what IP(s) can login to the router under that account as well, assuming that option is available to you. Technically, this step is only needed if you are dealing with separate networks where direct arp requests won't work, but I figured might as well standardize this to all of your networks.
<br><br>
I currently only have this configured for `-t 0` (None provided), `-t 1` (Fortigate), and `-t 2` (pfsense). You'll likely need to write your own profile if your router vendor/model is different. The way the data is returned and how you interact/login to the shell are going to be unique after all. When this option is disabled (`0`), this will rely on direct pings to each IP in the range you provided to determine what hosts are online. This scenario also expects the IP to be on the local network, arp requests won't work otherwise.
<br><br>
If you do write your own profile there are two scenarios you are likely to run into. The first is where you can directly pull the arp cache upon login and log the results - `sshpass` works well for this. The second is when a more interactive login is required, like for pfsense which I use at home. In this scenario you can use `expect`, which allows you to structure expected prompts like menu options before you can run the query for the arp table. Check out the file at `WompRat/Scripts/pfsense_login.exp` for an example. Ensure the file has executable permissions too.
<br><br>
That's really all there is for this step, just search through the script to find where you'll need to update the credentials and play around with it further.
<br><br>
