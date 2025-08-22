---
layout: default
title: Integrating your local DNS Server
parent: Config
nav_order: 4
---

So, what's this about adding a DNS server? Well, the end goal here is to identify known vs unknown devices on your network, which your DNS server can aid in when correctly configured. In the context of my on-prem Windows environment this meant ensuring only domain-joined devices can submit entries, which we trust implicitly. This is done by just checking the secure vs insecure settings in DNS Manager. If for some reason you have insecure updates allowed and choose not to change it that makes a) this step counter-intuitive and b) well, just poor practice on your end. But you do you.
<br><br>
I was initially using pointer records in the reverse lookup zone for my queries (`nslookup TARGET_IP SERVER_IP`), but since not all of our DHCP assignments are handed out through the Windows Server (some remote sites' DHCP scopes are managed by the router), this will not work as the pointer records are not automatically generated. When handed out by the Windows DHCP Server it can be configured to automatically do that, so if your set up is small enough and/or aligns with these requirements you should be good to fall back on the `nslookup` route.
<br><br>
Anyway, what this does is query all DNS entries and then reformat that list into a dictionary of `HOSTNAME,IP`. To accomplish this I needed to create a new service account in AD which requires read-only permissions to the domain in DNS Manager. You can right click the  domain you're working with > Properties > Security > and add your user account in there - again, _read-only_. You'll have to modify those login credentials in the `scan.sh` script once configured.
<br><br>
Since you may want to designate different DNS servers depending on the cronjob's network target, the `scan.sh` script accepts an argument for which DNS server to query (`-d SERVER_IP`). Alternatively, you may choose to disable this feature using  `-d 0`, which would be common for home networks or environments where you don't have the DNS server zones set to secure-only updates.
<br><br>


