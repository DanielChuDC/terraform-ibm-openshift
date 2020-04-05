### Installation step

1. git clone https://github.com/kabanero-io/kabanero-foundation.git
2. cd kabanero-foundation
3. git checkout 0.2.0
4. cd kabanero-foundation/scripts
5. Review the <install-kabanero-foundation.sh> script 
5. As a cluster-admin, replace the <MY_OPENSHIFT_MASTER_DEFAULT_SUBDOMAIN> with your subdomain by `openshift_master_default_subdomain=ocp-admin.com`
6. Run command `ENABLE_KAPPNAV=yes openshift_master_default_subdomain=ocp-admin.com ./install-kabanero-foundation.sh` , it will enable kappnav


