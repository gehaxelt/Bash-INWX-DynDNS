INWX DynDNS Script
=================

This is a small bash script, which works as a DynDNS updater. It works only with domains which are registered at [inwx.de](inwx.de). It will only update the ip record, if the ip has changed.

##Requirements##

This script does not require any additional tools. All tools should be available on a regular linux system:

- curl
- sed


##Installation##

- 1. Create a new directory in your home folder. E.g. dyndns.

```mkdir ~/dyndns```

```cd ~/dyndns```

- 2. Clone the files from github


```git clone git@github.com:gehaxelt/Bash-INWX-DynDNS.git .```


- 3. Edit the dnsupdate.sh and fill in your login credentials.

```nano dnsupdate.sh```

- 4. Get the wished dns entry id from the inwx website and set it in the script.

- 5. Edit your crontab. For a 5-minutes update use: ```*/5 * * * * cd /home/$USER/dyndns && bash dnsupdate.sh```

```crontab -e```


