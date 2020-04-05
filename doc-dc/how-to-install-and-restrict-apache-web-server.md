# How to restrict apache web server


### How to install apache web server?
Prepare and populate the repository server

During the installation, and any future updates, you need a webserver to host the software. RHEL 7 can provide the Apache webserver.

    Prepare the webserver:

        If you need to install a new webserver in your disconnected environment, install a new RHEL 7 system with at least 110 GB of space on your LAN. During RHEL installation, select the Basic Web Server option.

        If you are re-using the server where you downloaded the OpenShift Container Platform software and required images, install Apache on the server:

        $ sudo yum install httpd

    Place the repository files into Apache’s root folder.

        If you are re-using the server:

        $ mv /path/to/repos /var/www/html/
        $ chmod -R +r /var/www/html/repos
        $ restorecon -vR /var/www/html

        If you installed a new server, attach external storage and then copy the files:

        $ cp -a /path/to/repos /var/www/html/
        $ chmod -R +r /var/www/html/repos
        $ restorecon -vR /var/www/html

    Add the firewall rules:

    $ sudo firewall-cmd --permanent --add-service=http
    $ sudo firewall-cmd --reload

    Enable and start Apache for the changes to take effect:

    $ systemctl enable httpd
    $ systemctl start httpd


### Version 

```
[root@dc-ocp-311-b610f7abf3-bastion conf]# httpd -v
Server version: Apache/2.4.6 (Red Hat Enterprise Linux)
Server built:   Jun  9 2019 13:01:04
```

https://webmasters.stackexchange.com/questions/59624/allowing-access-to-an-apache-virtual-host-from-the-local-network-only


- cd /etc/httpd/conf/
- locate /etc/httpd/conf/httpd.conf


 ### Answer 1 (Only work in apache 2.2)
 ```s


Easy. Just set something like this within your main configuration or your virtual configuration:

<Directory /var/www/path/to/your/web/documents>

  Order Deny,Allow
  Deny from all
  Allow from 127.0.0.1 ::1
  Allow from localhost
  Allow from 192.168
  Allow from 10
  Satisfy Any

</Directory>

The <Directory></Directory> statement basically says, “Use these rules for anything in this directory. And by “this directory” that refers to the /var/www/path/to/your/web/documents which I have set in this example but should be changed to match your site’s local directory path.

Next within the <Directory></Directory> area you are changing the default Apache behavior which Allow’s all by default to Order Deny,Allow. Next, you set Deny from all from denies access from everyone. Follwing that are the Allow from statements which allows access from 127.0.0.1 ::1 (localhost IP address), localhost (the localhost itself). That’s all the standard stuff. Since access from localhost is needed for many internal system processes.

What follows is the stuff that matters to you.

The Allow from for 192.168 as well as 10 will allow access from any/all network addresses within the network range that is prefixed by those numbers.

So by indicating 192.168 that basically means if a user has an address like 192.168.59.27 or 192.168.1.123 they will be able to see the website.

And similarly using the Allow from for the 10 prefix assures that if someone has an IP address of 10.0.1.2 or even 10.90.2.3 they will be able to see the content.

Pretty much all internal networks in the world use either the 192.168 range or something in the 10 range. Nothing external. So using this combo will achieve your goal of blocking access to the outside world but only allow access from within your local network.


 ```


### Answer 2 (Working example)

See more from https://httpd.apache.org/docs/2.4/mod/mod_authz_host.html

```conf
# Further relax access to the default document root:
<Directory "/var/www/html">
    #
    # Possible values for the Options directive are "None", "All",
    # or any combination of:
    #   Indexes Includes FollowSymLinks SymLinksifOwnerMatch ExecCGI MultiViews
    #
    # Note that "MultiViews" must be named *explicitly* --- "Options All"
    # doesn't give it to you.
    #
    # The Options directive is both complicated and important.  Please see
    # http://httpd.apache.org/docs/2.4/mod/core.html#options
    # for more information.
    #
    Options Indexes FollowSymLinks

    #
    # AllowOverride controls what directives may be placed in .htaccess files.
    # It can be "All", "None", or any combination of the keywords:
    #   Options FileInfo AuthConfig Limit
    #
    AllowOverride None

    #
    # Controls who can get stuff from this server.
    #

   #Require all granted
  #Require all denied
  Require local
  Require ip 127.0.0.1
  Require ip 192.168
  Require ip 10

</Directory>


```
