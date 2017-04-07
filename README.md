INWX DynDNS Script
=================

This is a small bash script, which works as a DynDNS updater. It works only with domains which are registered at [inwx.de](https://inwx.de). It only updates the ip record, if the ip has changed.

##Requirements

This script does not require any additional tools. All tools should be available on a regular linux system:

- curl
- sed


##Installation

- 1. Create a new directory in your home folder. E.g. dyndns.

```
mkdir ~/dyndns
cd ~/dyndns
```

- 2. Clone the files from github


```
git clone git@github.com:gehaxelt/Bash-INWX-DynDNS.git .
```


- 3. Edit the dnsupdate.sh and fill in your login credentials.

```
nano dnsupdate.sh
```

- 4. Get the wished dns entry id from the inwx website and set it in the script. See below how to get the ID.
- 5. Edit your crontab. For a 5-minutes update use: ```*/5 * * * * cd /home/$USER/dyndns && bash dnsupdate.sh```

```
crontab -e
```

## How to obtain the DNS entry ID?

First, login to the [inwx](https://inwx.de) website. Navigate to "Nameserver" section:

![Inwx's nameserver section](./screenshots/inwx-1.png)

Then open the DNS entries for your domain and right-click on the entry you'd like to dynamically update. Choose the "inspect element" menue entry.

![DNS entries for a domain](./screenshots/inwx-2.png)

Now you should see the developer tools and a `<div>`-element. The number in the `id`-attribute's value after `record_div_` is the wanted number.

![DNS entry's ID](./screenshots/inwx-3.png)

Copy this ID (here: 206895961) into your script.

Alternatively you can use the [INWX API](https://www.inwx.de/de/help/apidoc/f/ch02s09.html#nameserver.info) to obtain the record id.