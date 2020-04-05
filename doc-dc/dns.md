https://www.redhat.com/en/blog/five-nines-dnsmasq

https://www.golinuxcloud.com/configure-dns-caching-server-dnsmasq-centos-7/


Verify DNS caching Server

The following steps can be used with tcpdump to ensure that DNS caching server is working as expected.

Install the tcpdump package on aterminal (Term A)

[root@node2 ~]# yum -y install tcpdump

Open another terminal session (Term B) and run the following command.

[root@node2 ~]# tcpdump port 53
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes

Run the following command twice on the terminal (Term A) and confirm that tcpdump shows 1 DNS query to your upper DNS server in Term B




