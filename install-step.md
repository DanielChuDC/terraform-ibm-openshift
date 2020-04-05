# This is daniel chu half automated installation step

```terraform
# Cluster formation

variable bastion_flavor {
  default = "B1_4X16X100"
}

variable master_flavor {
   default = "B1_16X32X100"
}

variable infra_flavor {
   default = "B1_16X32X100"
}

variable app_flavor {
   default = "B1_16X32X100"
}

# Where Cluster need 3 nodes
variable storage_flavor {
   default = "B1_8X16X100"
}


# oc get nodes
# Exclusing Bastion node
NAME                                           STATUS    ROLES                          AGE       VERSION
dc-06-dec-d9fccc1737-app-0.ocp-cloud.com       Ready     compute,icp-proxy              14h       v1.11.0+d4cacc0
dc-06-dec-d9fccc1737-infra-0.ocp-cloud.com     Ready     compute,icp-management,infra   14h       v1.11.0+d4cacc0
dc-06-dec-d9fccc1737-master-0.ocp-cloud.com    Ready     compute,icp-master,master      14h       v1.11.0+d4cacc0
dc-06-dec-d9fccc1737-storage-0.ocp-cloud.com   Ready     compute                        14h       v1.11.0+d4cacc0
dc-06-dec-d9fccc1737-storage-1.ocp-cloud.com   Ready     compute                        14h       v1.11.0+d4cacc0
dc-06-dec-d9fccc1737-storage-2.ocp-cloud.com   Ready     compute                        14h       v1.11.0+d4cacc0

```

### Following this tutorial
Installing IBM Cloud Pak for Integration on OCP 3.11
https://developer.ibm.com/integration/blog/2019/09/25/installing-ibm-cloud-pak-for-integration-on-ocp-3-11/

End to End installation of IBM Cloud Pak for Integration on IBM Cloud infrastructure
https://developer.ibm.com/recipes/tutorials/end-to-end-installation-of-ibm-cloud-pak-for-integration-on-ibm-cloud-infrastructure/


### Table of content

0. Setup Domain name service in IBM Cloud.
1. Access and provision IBM Cloud Classic infrastructure
2. Set up repo for OCP 3.11 rpms.
3. Run `make infrastructure` for provision classical infrastructure in IBM Cloud
   - It will execute action below
      - Step up local disk(300GB) for master node @ /var/lib/docker(200GB) and /opt/ibm-cloud-private-3.2.0(99GB) and mount at /etc/fstab
      - Step up all iscis disk for all node for 100GB
      - You will need to point the `A` record DNS entry for Master node FQDN and its ip address.

4. Run `make rhnregister` for pointing to the repo vm and access neccessary rpms
   - You will need to modify the ip address of the repo according to your repo vm.
   - The rest are indicated inside `rhn_register.sh`
      - Optional
      - copy the key file and put into bastion node
      - Paste the line below before running `make openshift` command
      - `
        # When you need to have confiure router too,
        # follow this https://access.redhat.com/documentation/en-us/openshift_container_platform/3.11/html/configuring_clusters/install-config-certificate-customization
        openshift_master_named_certificates=[{"certfile":"/root/ocp-cloud.com/fullchain.pem","keyfile":"/root/ocp-cloud.com/privkey.pem"}]
        openshift_hosted_router_certificate={"certfile": "/root/ocp-cloud.com/fullchain.pem", "keyfile": "/root/ocp-cloud.com/privkey.pem", "cafile": "/root/ocp-cloud.com/fullchain.pem"} 
        openshift_master_overwrite_named_certificates=true
        `
5. Run `make openshift` for preparation for OCP installtion
   - This action will responsible for prepare and download ansible playbook
   - Only do for prepare-cluster action


6. ssh into Bastion node and run 
`
ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml -e ansible_user=root
` for checking prerequisites
7. ssh into Bastion node and run 
`
ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml -e ansible_user=root
` for install cluster based on inventory file and /etc/hosts file


7.
```sh

# Login with oc -u system:admin
oc login -u system:admin
# Create an htpasswd file, we'll use htpasswd auth for OpenShift.
htpasswd -cb /etc/origin/master/htpasswd admin test123
# Add permision
oc adm policy add-cluster-role-to-user cluster-admin admin


```

Possible command you need
```

#  make rhn_username="12586794|moxing" rhn_password=eyJhbGciOiJSUzUxMiJ9.eyJzdWIiOiJhMGY0ZDA3Yzg1Zjg0OGVlODAyY2U3NDM4MDE5NTIxZSJ9.lBKQ9uK8Ld6B9x0nz-_g-JWqpg2_uAxAcLLbPZmjaeQWotfkXzla149eLcWVVyYjk6GqSzzwphz6UaP2td1B8cgMUXD-fSeJlvmMK2qwBx3SNYSpnxMQhF7xSNFpz8gMtJQ4cmUwKN6Cnr_6zyWDtW_qPox3GdUYwzPYiHn9t86BACIky7aZnLIFmA5b7Au8GxjPRkAk6HMZ2oKeCarZzcYv8tSSWSdJ8TF9L_CemakfevimHg2f3aNMxt43coAJye0Gi343MnzNaB552aZ9ekTu3mWNwPG58QNQcVnpg8e7j0VPTHDV8XMNeCc7Y_lfXV7oOmJWHd98fDd-Pk8JPaWSuqE5bqHG7lIruDOV9uf8brV1f-drjydU0-fGQWNJWeggzMS208PnHv7FDiEcTO54Rko8CjYNMSIM24dINv1AhSTYDe-tvaW7-IcB-YQ3pvSzT7SJln44fa6bUzeCut5LVToFgDxPOL1v_hfxPf9mbA2ZLJ6rDtE0cOmJak0Mg-bvcSA8RsMm6VAY88dr7FO2aSsXiFag3nMxtQbwBAkuTAEP2gLsqjMSncuKb_6JhQfbhJOixNNPT-3iTK2r4JkZ9m587nsgeb6nUclM4bTtMvEJkSzfBHqH9kETAHHckoPlJJCexYMAtWhxMh9p8iLSHLTtEd5GqhqZMN5mf8I infrastructure

# make rhn_username="awdawdawd" rhn_password="awd" pool_id="awd" rhnregister

# make openshift

# ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/adhoc/uninstall.yml  -e ansible_user=root

# 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml -e ansible_user=root'

#
# nameserver 10.0.80.11
# nameserver 10.0.80.12
# options single-request-reopen

# echo "nameserver 10.0.80.11 \n nameserver 10.0.80.12 " > "/etc/origin/node/resolv.conf"
# cat <<EOF >> /etc/origin/node/resolv.conf
# nameserver 10.0.80.11
# nameserver 10.0.80.12
# EOF

# https://codergists.com/redhat/containers/openshift/2019/06/17/approving-csr-on-openshift-v4-cluster.html
# oc get csr
# oc adm certificate approve csr-ABCDEF
# // We can approve the requests with the following
# oc get csr -o name | xargs oc adm certificate approve

# oc patch storageclass glusterfs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'

oc patch storageclass ibmc-file-gold -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'


# oc patch storageclass glusterfs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'

# oc rollout latest logging-es-data-master-gcdxl00u

# oc patch persistentvolumeclaim/metrics-cassandra-1 -p {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"labels":{"metrics-infra":"hawkular-cassandra"},"name":"metrics-cassandra-1","namespace":"openshift-infra"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"10Gi"}},"storageClassName":"glusterfs-storage"}}

 oc patch persistentvolumeclaim/metrics-cassandra-1 -p  {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"labels":{"metrics-infra":"hawkular-cassandra"},"name":"metrics-1","namespace":"openshift-infra"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"15Gi"}},"selector":{"matchLabels":{"storage":"glusterfs"}},"storageClassName":"glusterfs-storage"}}

# sudo sed -i -e 's/manage_etc_hosts: True/manage_etc_hosts: False/g' /etc/cloud/cloud.cfg


#
# ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/openshift-web-console/config.yml -e ansible_user=root

# ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/openshift-glusterfs/new_install.yml -e ansible_user=root

# ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/openshift-glusterfs/uninstall.yml -e ansible_user=root

# ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/openshift-glusterfs/uninstall.yml -e "openshift_storage_glusterfs_wipe=true" -e ansible_user=root


## For metric server
## https://docs.openshift.com/container-platform/3.11/install_config/cluster_metrics.html
## https://docs.openshift.com/container-platform/3.11/install/configuring_inventory_file.html
ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml \
   -e openshift_metrics_install_metrics=True \
   -e openshift_metrics_cassandra_storage_type=pv \
   -e openshift_metrics_cassandra_pvc_size=10Gi  \
   -e openshift_metrics_cassandra_pvc_storage_class_name=glusterfs-storage

## Example output 
INSTALLER STATUS **************************************************************************************************************************************
Initialization   : Complete (0:01:47)
Metrics Install  : Complete (0:03:15)

## Uninstall metric server
## https://docs.openshift.com/container-platform/3.11/install_config/cluster_metrics.html
ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml \
   -e openshift_metrics_install_metrics=False

```


### One step closer to install ICP 3.2.x on top of RHOS
https://developer.ibm.com/recipes/tutorials/end-to-end-installation-of-ibm-cloud-pak-for-integration-on-ibm-cloud-infrastructure/

$ tar xf ibm-cloud-private-rhos-3.2.0.1907.tar.gz -O | sudo docker load


# Login into  cluster using oc command

$ oc login https://dc-13-Dec-36f67a3bd7-master-0.ocp-cloud.com:8443 --token=oIsKyz07YgXKZ0aO7PBBV5cM2h0GajtUCks8tDxmB5Y

$ oc get nodes

# Get subdomain route 
$ kubectl -n openshift-console get route console -o jsonpath='{.spec.host}'| cut -f 2- -d "."

# Get storageclass
$ oc get sc

# Labeling node to compute so can deploy pod there
$ kubectl label nodes dc-09-jan-31eded178c-master-0.ocp-admin.com node-role.kubernetes.io/compute=true
 
$ kubectl label nodes dc-09-jan-31eded178c-infra-0.ocp-admin.com node-role.kubernetes.io/compute=true

# Patch the storageclass to be default storageclass
[ danielchu ~]$ kubectl patch storageclass glusterfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

storageclass.storage.k8s.io/glusterfs-storage patched

# Get kubeconfig from ocp, make sure you are in folder `installer_files/cluster`
$ sudo cp /etc/origin/master/admin.kubeconfig kubeconfig

# LASTLY,
sudo docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.0.1907-rhel-ee install-with-openshift 

- Use this to output the log in a file
sudo docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z --security-opt label:disable ibmcom/icp-inception-amd64:3.2.0.1907-rhel-ee install-with-openshift > install-icp.log



# To uninstall the ICP with OCP cluster

- Run the command, else will have permission error
$ sudo docker run --privileged -ti --net=host -e LICENSE=accept -v $(pwd):/installer/cluster ibmcom/icp-inception-amd64:3.2.0.1907-rhel-ee uninstall-with-openshift

- Remove the node name, by applying a `-` behind 
```yaml
kubectl label node dc-13-dec-36f67a3bd7-master-0.ocp-cloud.com node-role.kubernetes.io/icp-master-
kubectl label node dc-13-dec-36f67a3bd7-app-0.ocp-cloud.com node-role.kubernetes.io/icp-proxy-
kubectl label node dc-13-dec-36f67a3bd7-infra-0.ocp-cloud.com node-role.kubernetes.io/icp-management-
```
- Restart docker service for all nodes
$ systemctl restart docker

- Restart all nodes in the cluster


# To install ICP for OCP with own custom certificate
https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/create_cert.html
- You can BYOK (Bring Your Own Key) to use inside your IBM Cloud Private cluster.

1. Create the cfc-certs/root-ca directory inside your cluster directory.
```
mkdir -p <installation_dir>/cluster/cfc-certs/root-ca

# In our context
mkdir -p cfc-certs/root-ca
```

2. Rename your existing CA key to ca.key and copy it to the installation directory.
```
cp <BYOK> <installation_dir>/cluster/cfc-certs/root-ca/ca.key
```

3. Rename your existing CA certificate to ca.crt, and copy it to the installation directory.
```
cp <BYOK_cert> <installation_dir>/cluster/cfc-certs/root-ca/ca.crt
```

4. If you have a certificate chain, then place the chain within the file ca-chain.crt in the directory <installation_dir>/cfc-certs/root-ca/. For example:
```
cp <BYOK_cert_chain> <installation_dir>/cluster/cfc-certs/root-ca/ca-chain.crt
```

NOTE: The certificate chain must contain only the signers of the BYO CA certificate, but must not contain the BYO CA certificate itself. The order of the chain must be the immediate signer of your BYO CA, followed by the signer of that CA, etc.

```yaml
cp privkey.pem ca.key
cp fullchain.pem ca.crt
cp chain.pem ca-chain.crt

```

5. Install your cluster.



!!!
Starting Tiller v2.12.3+icp (tls=true)
*ICP 3.2.0 cannot work with tiller which higher than v2.12.3*
- Follow this to create customs cert and put in directory before installation
https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/create_cert.html
- Availble cipher sets
https://www.ibm.com/support/knowledgecenter/SSBS6K_3.2.0/installing/tls.html




NAME                                           STATUS    ROLES     AGE       VERSION
dc-13-dec-43b3f59a8a-app-0.ocp-cloud.com       Ready     compute   27m       v1.11.0+d4cacc0
dc-13-dec-43b3f59a8a-infra-0.ocp-cloud.com     Ready     infra     27m       v1.11.0+d4cacc0
dc-13-dec-43b3f59a8a-master-0.ocp-cloud.com    Ready     master    36m       v1.11.0+d4cacc0
dc-13-dec-43b3f59a8a-storage-0.ocp-cloud.com   Ready     compute   27m       v1.11.0+d4cacc0
dc-13-dec-43b3f59a8a-storage-1.ocp-cloud.com   Ready     compute   27m       v1.11.0+d4cacc0
dc-13-dec-43b3f59a8a-storage-2.ocp-cloud.com   Ready     compute   27m       v1.11.0+d4cacc0



# version 4.0 / 1.2.0
- Uninstall
 docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable ibmcom/mcm-inception-amd64:3.2.3  uninstall-with-openshift


- Install 
 docker run -t --net=host -e LICENSE=accept -v $(pwd):/installer/cluster:z -v /var/run:/var/run:z -v /etc/docker:/etc/docker:z --security-opt label:disable ibmcom/mcm-inception-amd64:3.2.3 install-with-openshift > cloudpak-install.log
