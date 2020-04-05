#!/bin/sh

#Update the docker config to allow OpenShift's local insecure registry.
#sed -i '/OPTIONS=.*/c\OPTIONS="--log-driver=json-file --log-opt max-size=1M --log-opt max-file=3"' /etc/sysconfig/docker
# https://access.redhat.com/solutions/3330141
# sed -i '/OPTIONS=.*/c\OPTIONS=" --selinux-enabled  --log-driver=json-file --log-opt max-size=1M --log-opt max-file=3  --signature-verification=False --insecure-registry docker-registry.default.svc.cluster.local:5000 --insecure-registry 172.30.0.0/16"'  /etc/sysconfig/docker
sed -i '/OPTIONS=.*/c\OPTIONS="  --log-driver=json-file --log-opt max-size=1M --log-opt max-file=3  --signature-verification=False --insecure-registry docker-registry.default.svc.cluster.local:5000 --insecure-registry 172.30.0.0/16"'  /etc/sysconfig/docker


systemctl restart docker
