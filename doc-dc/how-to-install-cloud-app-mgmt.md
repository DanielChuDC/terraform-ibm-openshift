### Install cloud app mgmt

- https://www.ibm.com/support/knowledgecenter/SS8G7U_19.4.0/com.ibm.app.mgmt.doc/content/install_mcm_server_script_full_monitoring.html?cp=SSFC4F_1.2.0


### Before you begin
* Ensure that IBM Cloud Pak for Multicloud Management is installed on your hub cluster. For more information, see the "Install the IBM® Cloud Pak for Multicloud Management section" in Installing the IBM Cloud Pak for Multicloud Management offline topic.
* Install the Helm CLI. For instructions, see Installing the Helm CLI (helm).
* Install the Kubernetes CLI, kubectl, and configure access to your cluster. For instructions, see Installing the Kubernetes CLI (kubectl).
* Install the cloudctl command-line CLI. For instructions, see Installing cloudctl.
* You must onboard LDAP users. For more information, see Onboarding LDAP users.
- Configure the Elasticsearch vm.max_map_count parameter on all worker nodes by completing the following steps:
      For Elasticsearch, you must set a kernel parameter on all worker nodes. These nodes are identified when you configure the persistent storage later in this procedure. You must set vm.max_map_count to a minimum value of 1048575. Set the parameter by using the sysctl command to ensure that the change takes effect immediately. Run the following command on each worker node:

      sysctl -w vm.max_map_count=1048575
      Copy

      You must also set the vm.max_map_count parameter in the /etc/sysctl.conf file to ensure that the change is still in effect after the node is restarted.

      vm.max_map_count=1048575

### Create the Cloud App Management ingress TLS and client secrets:
```sh

./ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh cloud_Proxy_FQDN my_release_name \
kube-system icam-ingress-tls icam-ingress-client icam-ingress-artifacts

# example 
./ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh icp-proxy.ocp-admin.com ibmcloudappmgmt \
 kube-system icam-ingress-tls icam-ingress-client icam-ingress-artifacts
```

Procedure

1. Complete the following steps as an administrator on your hub cluster on the infrastructure node of your IBM Cloud Pak for Multicloud Management environment.

2. Create a directory, which you can use to save the installation files to and complete installation steps. For this procedure, an example directory that is called install_dir is used.
```
mkdir install_dir/
```

3. Locate the Cloud App Management server installation image file icam_ppa_2019.4.0_prod.tar.gz (Part number: CC4KNEN) on IBM Passport Advantage® . Download the installation image file to the install_dir directory.

For more information about the IBM Cloud App Management components and their part numbers, see the Part numbers topic.

**The Cloud App Management server with IBM Cloud Pak for Multicloud Management must be installed in the kube-system namespace. Throughout this procedure, if prompted for a namespace, you must use kube-system.**
### Load the image into private registry host in OCP


4. As an administrator, log in to the management console. 

```
cloudctl login -a my_cluster_URL -n kube-system --skip-ssl-validation
```

Where my_cluster_URL is the name that you defined for your cluster such as https://cluster_address:443. For future references to masterIP, use the value for cluster_address. An example of cluster_address is icp-console.apps.hostname-icp-mst.domain.com.

5. As an OpenShift administrator, log in to the OpenShift Container Platform:

```
oc login
```

Log in to the Docker registry:
```
docker login $(oc registry info) -u $(oc whoami) -p $(oc whoami -t)
```

6. Load the Passport Advantage Archive (PPA) file installation image file into IBM's Docker registry:
```
cloudctl catalog load-archive --archive ./icam_ppa_2019.4.0_prod.tar.gz  --registry $(oc registry info)/kube-system


# example
oc login https://dc-09-jan-31eded178c-master-0.ocp-admin.com:8443 --token=aamc5R52Zt3osZ_O6BA-LB8Q4sM-6_N3YEqAGq63cY8
cloudctl login -a https://icp-console.ocp-admin.com:443 --skip-ssl-validation -u admin -p my-avengers-Herolist-ironman3000 -n services
docker login docker-registry-default.ocp-admin.com  -u admin  -p `oc whoami -t`      
cloudctl catalog load-archive --archive ./icam_ppa_2019.4.0_prod.tar.gz --registry docker-registry-default.ocp-admin.com/kube-system


```

where icam_ppa_2019.4.0_prod.tar.gz is the compressed Cloud App Management server PPA installation image file.

If you see the similar log like [log](./load-app-mgmt-chart.log) then it is completed pushing the image.

7. Extract the Helm charts from the Passport Advantage Archive (PPA) file into the install_dir directory:
```
cd install_dir
tar -xvf ./icam_ppa_2019.4.0_prod.tar.gz  charts 
tar -xvf ./charts/ibm-cloud-appmgmt-prod-1.6.0.tgz

# Example
mkdir cloudapp_installdir
cd cloudapp_installdir/
tar -xvf ../icam_ppa_2019.4.0_prod.tar.gz  charts
tar -xvf ./charts/ibm-cloud-appmgmt-prod-1.6.0.tgz

# Example output
charts/
charts/ibm-cloud-appmgmt-prod-1.6.0.tgz

```



**The charts value is required to ensure the tar command extracts only the charts directory from the icam_ppa_2019.4.0_prod.tar.gz file. Otherwise, all the images are extracted, which might cause space issues.**

8. Change directory to the ibm-cloud-appmgmt-prod directory.
```
cd install_dir/ibm-cloud-appmgmt-prod

# example (continue from step 7)
cd ibm-cloud-appmgmt-prod/

```

9. Create the Cloud App Management ingress TLS and client secrets:
```
./ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh cloud_Proxy_FQDN my_release_name \
kube-system icam-ingress-tls icam-ingress-client icam-ingress-artifacts

# example (continue from step 8)
# This step is really important
# The release name need to match the helm release name
# Else you cannot access though web console
./ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh icp-proxy.ocp-admin.com ibmcloudappmgmt \
kube-system icam-ingress-tls icam-ingress-client icam-ingress-artifacts


# Example output
# If you get this means you are ok
Signature ok
subject=/C=US/ST=New York/L=Armonk/O=International Business Machines Corporation/OU=IBM Cloud App Management/CN=Signer CA
Getting CA Private Key
Signature ok
subject=/C=US/ST=New York/L=Armonk/O=International Business Machines Corporation/OU=IBM Cloud App Management/CN=icp-proxy.ocp-admin.com
Getting CA Private Key
Signature ok
subject=/C=US/ST=New York/L=Armonk/O=International Business Machines Corporation/OU=IBM Cloud App Management/CN=Integration Client
Getting CA Private Key
secret/icam-ingress-tls created
secret/icam-ingress-client created
secret/icam-ingress-artifacts created
secret/icam-ingress-tls patched
secret/icam-ingress-client patched
secret/icam-ingress-artifacts patched

```

**Where cloud_Proxy_FQDN is the FQDN of your IBM Cloud Pak for Multicloud Management Proxy, and my_release_name is the name of the Cloud App Management Helm Chart, for example: ibmcloudappmgmt.**

10. Prepare Persistent storage: Persistent storage is required in a production environment. IBM highly recommends local storage, persistent volumes backed by local disks or partitions. For information about how to configure persistent storage, see Understanding Kubernetes storage.
Cloud App Management includes the prepare-pv.sh script that helps with creating storage lasses and Persistent Volumes that are backed by local storage. To use this script, complete the following steps:

```sh
#Locate the script in the Helm chart directory. It is in install_dir/ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/prepare-pv.sh.
#Execute the script without any parameters to see the usage instructions:

./ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/prepare-pv.sh


# Identify the correct parameter values and run the script with the parameter set. For example:

./ibm-cloud-appmgmt-prod/ibm_cloud_pak/pak_extensions/prepare-pv.sh --size1_amd64 --releasename ibmcloudappmgmt \
--cassandraNode 10.10.10.1 --zookeeperNode 10.10.10.2 --kafkaNode 10.10.10.3 --couchdbNode 10.10.10.4 --datalayerNode \
10.10.10.5 --elasticSearchNode 10.10.10.6 --local

# Create the persistent volumes and storage classes from the resource files:

kubectl create -f ibm-cloud-appmgmt-prod/ibm_cloud_pak/yaml/


# When you are configuring the storage class parameters later in this procedure (see Table 1 table for more information), you must provide the storage classes that you defined for each of the different stateful sets. 
# For example, if you used --CassandraClass myCassandraStorageClass, you must provide myCassandraStorageClass as the value for Cassandra Storage Class.
#  If you did not specify custom storage classes and you used the defaults, you must provide the default values that the prepare-pv.sh script uses: my_release_name-local-storage-elasticsearch, my_release_name-local-storage-kafka, and so on. 
# To verify which storage classes are created and are available to use, run kubectl get storageclass.


```

12. Log in to the console of your target cluster.
13. Click Catalog in the upper right corner.
14. Search for the ibm-cloud-appmgmt-prod Helm chart and select it.
15. Click Configure.

16. Configure all parameters under Configuration.
See Table 1 for more information.

17. Under the Parameters area, expand All parameters and configure the required parameters.
See Table 1 for more information.
Table 1. Helm chart configuration parameters

<table summary="" id="task_install_mcm_server_script__d441e497" style="width: 90%" class="defaultstyle ibm-grid"><caption><span class="tablecap">Table 1. <span class="keyword">Helm</span> chart configuration parameters</span></caption><colgroup><col style="width:51.08695652173913%"><col style="width:24.456521739130437%"><col style="width:24.456521739130437%"></colgroup><thead style="text-align:left;">
<tr style="vertical-align:top;">
<th id="d266748e634" class="thcenter thmid">Parameter name</th>

<th id="d266748e637" class="thcenter thmid">Description/Commands</th>

<th id="d266748e640" class="thcenter thmid">Example</th>

</tr>

</thead>
<tbody>
<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Helm release name</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The <span class="keyword">Helm</span> release name. Any alphanumeric string, which can
include dashes.</td>

<td headers="d266748e640 " class="tdcenter tdmid">ibmcloudappmgmt</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Target namespace</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Select the <span class="ph uicontrol">kube-system</span>
namespace.</td>

<td headers="d266748e640 " class="tdcenter tdmid">kube-system</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Target cluster</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The cluster that the
<code class="ph codeph">ibm-cloud-appmgmt-prod</code>
<span class="keyword">Helm</span> chart is being installed on</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">License Accepted</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Select the checkbox.</td>

<td headers="d266748e640 " class="tdcenter tdmid"><img src="images/yes.jpg" alt="Yes"></td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Create CRD</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Required for multi-cloud integrations</td>

<td headers="d266748e640 " class="tdcenter tdmid"><img src="images/yes.jpg" alt="Yes"></td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Create TLS Certs</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">
<ul class="ibm-colored-list ibm-textcolor-gray-80">
<li> If you are completing an online installation using Entitled Registry, select the check
box.</li>

<li>If you are completing an offline installation (downloading the PPA from IBM
Passport Advantage) and you want to accept the
default setting for creating TLS certs, which means this check box is not selected, you must run the
<span class="ph filepath">make-ca-cert-icam.sh</span> script to create the Ingress secrets. It is important that
you run this script before you install the <code class="ph codeph">ibm-cloud-appmgmt-prod</code>
<span class="keyword">Helm</span> chart. An example of how to
run the <span class="ph filepath">make-ca-cert-icam.sh</span> is:
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock19">./ibm_cloud_pak/pak_extensions/lib/make-ca-cert-icam.sh <var class="keyword varname ibm-item-note-alternate">cloud_Proxy_FQDN</var> <var class="keyword varname ibm-item-note-alternate">my_release_name</var> \
kube-system icam-ingress-tls icam-ingress-client icam-ingress-artifacts</code><a href="javascript:void(0);" id="copy-btn-19" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre>
Where <var class="keyword varname ibm-item-note-alternate">cloud_Proxy_FQDN</var> is the FQDN of your <span class="keyword">IBM Cloud Pak for Multicloud Management</span> Proxy, and <var class="keyword varname ibm-item-note-alternate">my_release_name</var> is the
name of the <span class="keyword">Cloud App
Management</span> Helm Chart, for
example: <code class="ph codeph">ibmcloudappmgmt</code>.</li>

<li>If you are completing an offline installation (downloading the PPA from IBM
Passport Advantage) and you want the installer
to automatically create the Ingress secrets for you, then select the check box. You do not need to
run the <span class="ph filepath">make-ca-cert-icam.sh</span> script.</li>

</ul>

</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Resource monitoring </span></td>

<td headers="d266748e637 " class="tdcenter tdmid">If you are installing in full monitoring mode,
select the checkbox . Ensure that this check box is not checked for eventing only.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Resource Analytics</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Do not select the checkbox to enable the
baselines feature.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Console FQDN</span></td>

<td headers="d266748e637 " class="tdleft tdmid">
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock20">oc get routes icp-console -o=jsonpath='{.spec.host}'</code><a href="javascript:void(0);" id="copy-btn-20" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre>
</td>

<td headers="d266748e640 " class="tdcenter tdmid">icp-console.hostname-icp-mst.test.com</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Console Port</span></td>

<td headers="d266748e637 " class="tdleft tdmid">
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock21">oc get configmap ibmcloud-cluster-info -n kube-public \
-o=jsonpath='{.data.cluster_router_https_port}'</code><a href="javascript:void(0);" id="copy-btn-21" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre>
</td>

<td headers="d266748e640 " class="tdcenter tdmid">443</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Console Client Secret Name</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">This field must be left empty.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Console TLS Secret Name</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">This field must be left empty.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Proxy FQDN </span></td>

<td headers="d266748e637 " class="tdleft tdmid">
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock22">oc get configmap ibmcloud-cluster-info -n kube-public -o=jsonpath='{.data.proxy_address}'</code><a href="javascript:void(0);" id="copy-btn-22" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre>
</td>

<td headers="d266748e640 " class="tdcenter tdmid">icp-proxy.apps.hardy-marmoset-icp-mst.test.com </td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Proxy Client Secret</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave the default value.</td>

<td headers="d266748e640 " class="tdcenter tdmid">Default value:
<code class="ph codeph">icam-ingress-client</code></td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cloud Proxy TLS Secret </span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave the default value.</td>

<td headers="d266748e640 " class="tdcenter tdmid">Default value:
<code class="ph codeph">icam-ingress-tls</code></td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cluster Master FQDN</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock23">oc get routes icp-console -o=jsonpath='{.spec.host}'</code><a href="javascript:void(0);" id="copy-btn-23" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre>
</td>

<td headers="d266748e640 " class="tdcenter tdmid">icp-console.apps.hardy-marmoset-icp-mst.fyre.ibm.com</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cluster Master Port</span></td>

<td headers="d266748e637 " class="tdleft tdmid">
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock24">oc get configmap ibmcloud-cluster-info -n kube-public \
-o=jsonpath='{.data.cluster_router_https_port}'</code><a href="javascript:void(0);" id="copy-btn-24" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre>
</td>

<td headers="d266748e640 " class="tdcenter tdmid">443</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cluster Master CA</span></td>

<td headers="d266748e637 " class="tdleft tdmid">Optional: If you provided your own certificate
for the <span class="keyword">IBM Cloud Pak for Multicloud Management</span> ingress, you must create a ConfigMap
containing the certificate authority's certificate in PEM format (for example: <code class="ph codeph">kubectl
create configmap master-ca --from-file=./ca.pem</code>) and set this value to the name of this
ConfigMap. If you did not provide your own certificate, leave this value empty.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Host Alias - Cloud Proxy IP</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Optional: The IP address of the <span class="keyword">IBM Cloud Pak for Multicloud Management</span> proxy. It is used where the DNS does not resolve the
<span class="keyword">IBM Cloud Pak for Multicloud Management</span> proxy's fully qualified domain name (FQDN).
It can be determined by running:
<pre class="codeblock ibm-textcolor-default ibm-background-neutral-white-40"><code data-clipboard-id="codeblock25">kubectl get no -l proxy=true -o=jsonpath='{ $.items[*].status.addresses[?(@.type=="InternalIP")].address }'</code><a href="javascript:void(0);" id="copy-btn-25" class="copy-to-clipboard-btn"><img src="https://www.ibm.com/support/knowledgecenter/images/icons/copy.png" title="Copy" alt="Copy" width="26" height="26"></a></pre></td>

<td headers="d266748e640 " class="tdcenter tdmid">10.21.17.70</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Product Deployment Size</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Determine cluster resource requests and limits
for the product. See <a href="planning_scaling.html?cp=SSFC4F_1.2.0&amp;view=kc" data-widget="tooltip" class="tipso_style ibm-widget-processed">Planning hardware and sizing</a> for more information.</td>

<td headers="d266748e640 " class="tdcenter tdmid">test_amd64</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Image Repository</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">
<ul class="ibm-colored-list ibm-textcolor-gray-80">
<li>If you completing an offline installation (downloading the PPA file from IBM
Passport Advantage), you must remove the
trailing slash from the value.</li>

<li>If you are completing an online installation using an IBM
entitled registry, it is the name of the entitled registry repository.</li>

</ul>

</td>

<td headers="d266748e640 " class="tdcenter">
<ul class="ibm-colored-list ibm-textcolor-gray-80">
<li>docker-registry.default.svc:5000/kube-system</li>

<li><code class="ph codeph">cp.icr.io/cp/app-mgmt</code></li>

</ul>

</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Image Pull Secret Name</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">If you completing an online installation using
Entitled Registry, you must enter the secret name that you created in the Entitled Registry Setup
steps. If you are not completing an online installation, leave this field empty.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Image Prefix</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave this field empty.</td>

<td headers="d266748e640 " class="tdcenter tdmid">&nbsp;</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Image pull policy</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave the default value:
<code class="ph codeph">IfNotPresent</code></td>

<td headers="d266748e640 " class="tdcenter tdmid"><code class="ph codeph">IfNotPresent</code></td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cassandra Replicas</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Configure the Cassandra Replicas.</td>

<td headers="d266748e640 " class="tdcenter tdmid">1</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Default Storage Class</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">Default storage class for the product. If the
other STORAGECLASS values, for example, Cassandra Data STORAGECLASS are set to default, they  use
the value that is provided here. If <span class="ph uicontrol">Default Storage Class</span> is left empty, the
environment's default storage class is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">glusterfs/rook-Cepheus/ or leave it
empty</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cassandra Data STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by
Cassandra data PersistentVolumeClaims (PVCs). If it is set to <span class="ph uicontrol">default</span>, the
StorageClass name that is defined in <span class="ph uicontrol">Default Storage Class</span> is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Cassandra Backup STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by
Cassandra backup PVCs. If it is set to <span class="ph uicontrol">none</span>, the backup volume is disabled.
If it is set to<span class="ph uicontrol"> default</span>, the storage class name that is defined in
<span class="ph uicontrol">Default Storage Class</span> is used. </td>

<td headers="d266748e640 " class="tdcenter tdmid">none</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">CouchDB Data STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by CouchDB
PersistentVolumeClaims PVCs. If it is set to <span class="ph uicontrol"> default</span>, the storage class name
that is defined in <span class="ph uicontrol">Default Storage Class</span> is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">| default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Datalayer Jobs STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by
Datalayer PVCs. If it is set to <span class="ph uicontrol">default</span>, the storage class name that is
defined in <span class="ph uicontrol">Default Storage Class</span> is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Elasticsearch Data STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by
Elasticsearch PVCs. If it is set to <span class="ph uicontrol">default</span>, the storage class name that is
defined in <span class="ph uicontrol">Default Storage Class</span> is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Kafka Data STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by Kafka
PVCs. If it is set to <span class="ph uicontrol">default</span>, the storage class name that is defined in
<span class="ph uicontrol">Default Storage Class</span> is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol">Zookeeper Data STORAGECLASS</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The storage class name that is used by Kafka
PVCs. If it is set to <span class="ph uicontrol">default</span>, the storage class name that is defined in
<span class="ph uicontrol">Default Storage Class</span> is used.</td>

<td headers="d266748e640 " class="tdcenter tdmid">default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft">…</td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave everything up to but not including the
<span class="ph uicontrol">Product Name</span> parameters as default values.</td>

<td headers="d266748e640 " class="tdcenter tdmid">default</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft">Under CEM Configuration, configure <span class="ph uicontrol">Product Name</span></td>

<td headers="d266748e637 " class="tdcenter tdmid"><span class="ph uicontrol"><span class="keyword">IBM Cloud App
Management</span> for Multicloud Manger</span></td>

<td headers="d266748e640 " class="tdcenter tdmid"><span class="ph uicontrol"><span class="keyword">IBM Cloud App
Management</span> for Multicloud Manger</span></td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft">…</td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave everything up to but not including the
<span class="ph uicontrol">Cluster administrator Username</span> parameter as default values.</td>

<td headers="d266748e640 " class="tdcenter tdmid">Default value</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft"><span class="ph uicontrol"> Cluster administrator Username</span></td>

<td headers="d266748e637 " class="tdcenter tdmid">The username of your cluster
administrator.</td>

<td headers="d266748e640 " class="tdcenter tdmid">admin</td>

</tr>

<tr>
<td headers="d266748e634 " class="tdleft">…</td>

<td headers="d266748e637 " class="tdcenter tdmid">Leave all remaining parameters as default
values.</td>

<td headers="d266748e640 " class="tdcenter tdmid">Default value</td>

</tr>

</tbody>
</table>
 


### 
docker-registry-default.ocp-admin.com 



### After installed cloud app mgmt, you can use helm-cli to get notes and execute it

```sh
cloudctl login -a https://icp-console.ocp-admin.com:443 --skip-ssl-validation -u admin -p my-avengers-Herolist-ironman3000 -n kube-system
helm get notes ibmcloudappmgmt --tls

## Example
[ danielchu ~]$ helm get notes ibmcloudappmgmt --tls
NOTES:
1. Wait for all pods to become ready. You can keep track of the pods either through the dashboard or through the command line interface: kubectl get pods -l release=ibmcloudappmgmt -n kube-system

2. (Optional) Validate health of pods by running helm tests: helm test ibmcloudappmgmt --tls --cleanup

3. OIDC registration with IBM Cloud Private is required to be able to login to IBM Cloud App Management's UI. As an IBM Cloud Private user with the Cluster Administrator role, run the following kubectl command:
kubectl exec -n kube-system -t `kubectl get pods -l release=ibmcloudappmgmt -n kube-system | grep "ibmcloudappmgmt-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/oidc_reg.sh" "`echo $(kubectl get secret platform-oidc-credentials -o yaml -n kube-system | grep OAUTH2_CLIENT_REGISTRATION_SECRET: | awk '{print $2}')`"
Policy registration with IBM Cloud Private is required to allow IBM Cloud App Management's services to be able to access other services. As an IBM Cloud Private user with the Cluster Administrator role, run the following kubectl command:
kubectl exec -n kube-system -t `kubectl get pods -l release=ibmcloudappmgmt -n kube-system | grep "ibmcloudappmgmt-ibm-cem-cem-users" | grep "Running" | head -n 1 | awk '{print $1}'` bash -- "/etc/oidc/registerServicePolicy.sh" "`echo $(kubectl get secret ibmcloudappmgmt-cem-service-secret -o yaml -n kube-system | grep cem-service-id: | awk '{print $2}')`" "`cloudctl tokens --access`"

```