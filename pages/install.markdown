---
layout: default
title: Initial Install
parent: Config
nav_order: 1
---

Well, let's begin with the following.
<br>
1. Start with any linux distro, I've tested this on Debian and Arch. Download the Github repo from <a href="https://github.com/fe-moldark/WompRat" target="_blank" rel="noopener noreferrer">here</a>, all you will need from there is the `WompRat` directory saved to the base of your user's home directory.
2. I would recommend creating a separate user account with a local-only logon. The one I used can be created using `sudo useradd -m  -s /bin/bash -k /etc/skel skywalker`, then set a password using `sudo passwd skywalker`. _For now_ the user requires root permissions, so add them to their respective `sudo` or `wheel` groups. I'll re-write this later so it can run as a standard user.
    - You will need to update all scripts to account for a different username if you choose something other than what I recommended. I might make this easier in the future, but I'm feeling a bit lazy at the moment.
3. This requires a local DB of the MAC address vendors from <a href="https://maclookup.app/downloads/csv-database" target="_blank" rel="noopener noreferrer">here</a> saved to `WompRat/Data/mac-vendors-export.csv`. You can go elsewhere for a db of this data or set up active queries (be aware of rate limiting though), but this will help provide information about the type of device depending on the reported MAC address. It wouldn't hurt to keep this updated.
4. Add in the following alias to your `~/.bashrc` file: `alias search='/usr/bin/python3 /home/skywalker/WompRat/Scripts/search_for_mac.py'` and reload it with `source ~/.bashrc`. More on this later.
5. Some other dependencies - you may need to install `sshpass`, `expect`, and whatever python modules you find missing. You'll find out when something throws an error your way.
<br><br>

