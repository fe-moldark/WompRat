---
layout: default
title: Considerations
nav_order: 5
---

These are some thoughts I put together about how this all works and some limitations I've noticed.
<br><br>
1. **Direct pinging vs using an arp table to ID active/online hosts**<br>
This was a bit bizarre, but I noticed from using the arp tables there were a few devices that were online and pingable, however, they did not appear in the arp tables of the local router. There are several reasons why this could be the case, but this was not an issue for me as it seemed isolated to a particular kind of sensor I didn't care about. That being said, if you want to avoid accidentally missing hosts you could rewrite the script to conduct ping sweeps instead of relying on the arp tables (or incorporate both). Another reason could be a malicious device that is intentionally dropping icmp traffic, but would still appear in a router's arp table if it's communicating on the network.

2. **Hard coding credentials**<br>
Obviously this is never recommended and I do it for the email password, the read-only ssh account for the router, and the dns server's service account. But hey, I do what I want. If you want to be an idiot like me then create separate service accounts for them, they should be read-only, and where you can configure it - limit which IPs can remote into the server/router under that account. Further reduce the attack surface of your server (the one running `WompRat`) if you can by blocking traditional remote access methods like ssh/vnc if you're running this as a VM. Keeping logins local-only is preferred.

3. **Nmap scanning through routers/switches**<br>
To be clear it still works, but it's kinda weird. That's my technical opinion, feel free to quote it. What I noticed was that scans that had to go through a second firewall/switch (outside its local network) would start flagging ports as open, even when they clearly weren't. On the service version section of the scan it'll just show `?` for ports like 22, 80, and a few others, even when that's just some network device in between them that was reporting as open. If the device you are scanning does in fact have that port open you'll see it's best guess from the service version scan populate, so keep that flag enabled.

4. **MAC spoofing**<br>
Half of this script is reliant on the device's MAC address after all, and guess what - people can spoof this! A real shocker, I know. Not much to do about this except preferring to use proper NAC rules and segment traffic / isolate hosts the right way, which is not the aim of this tool.

5. **Exercising caution**<br>
Not all devices like being scanned via nmap and may freak out, just something to keep in mind when designating your IP scopes. I think that's the only disclaimer I'll put in here, otherwise feel free to bring down production! Looking forward to hearing from you all on `r/ShittySysadmin`.
<br><br>
