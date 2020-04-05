### Step 0
Move the file to one of the node, in this case is app-0

`scp  root@10.66.216.183:/root/place-to-repo/icp-cam-x86_64-4.1.tar.gz .`

- Install Cloudctl on app-0
```
# Go to Welcome page 
https://icp-console.ocp-admin.com/multicloud/welcome

# Under the section - install cli, Select the right target OS

curl -kLo cloudctl-linux-amd64-v3.2.3-1557 https://icp-console.ocp-admin.com:443/api/cli/cloudctl-linux-amd64

```

Then login into the mcm ibm cloud pak cluster

### Step 1


Run the following command to add the default pod security policy:

 oc adm policy add-scc-to-user ibm-anyuid-hostpath-scc system:serviceaccount:services:default




### Step 2
Generate a deployment ServiceID API Key:
```
export serviceIDName='service-deploy'
export serviceApiKeyName='service-deploy-api-key'
cloudctl login -a <ibm_cloud_pak_mcm_console_url> --skip-ssl-validation -u <ibm_cloud_pak_mcm_admin_id> -p <ibm_cloud_pak_mcm_admin_password> -n services
cloudctl iam service-id-create ${serviceIDName} -d 'Service ID for service-deploy'
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'idmgmt'
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'identity'
cloudctl iam service-api-key-create ${serviceApiKeyName} ${serviceIDName} -d 'Api key for service-deploy'

#example

export serviceIDName='service-deploy'
export serviceApiKeyName='service-deploy-api-key'
cloudctl login -a https://icp-console.ocp-admin.com:443 --skip-ssl-validation -u admin -p my-avengers-Herolist-ironman3000 -n services
cloudctl iam service-id-create ${serviceIDName} -d 'Service ID for service-deploy'
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'idmgmt'
cloudctl iam service-policy-create ${serviceIDName} -r Administrator,ClusterAdministrator --service-name 'identity'
cloudctl iam service-api-key-create ${serviceApiKeyName} ${serviceIDName} -d 'Api key for service-deploy'

```
Perserve and use the API Key that you receive from the service-api-key-create command in deployApiKey value of Helm Chart install. 

- The example output like this
```
Creating API key service-deploy-api-key of service service-deploy as admin...
OK
Service API key service-deploy-api-key is created

Please preserve the API key! It cannot be retrieved after it's created.
                 
Name          service-deploy-api-key   
Description   Api key for service-deploy   
Bound To      crn:v1:icp:private:iam-identity:mycluster:n/services::serviceid:ServiceId-b83ae417-b4ba-4e6f-8521-d8e44212c279   
Created At    2020-01-11T13:52+0000   
API Key       X5NlQkonc5hGLF67x68Z9Yg30vHzQ4Q011B_HZAqkO6l   

```

### Step 3


Run the following commands to load the Cloud Automation Manager offline PPA image into OpenShift docker registry:

    For Openshift 3.11:
```
oc login -u <openshift console admin user> -p <openshfit console admin password>      

cloudctl login -a <ibm_cloud_pak_mcm_console url> --skip-ssl-validation -u <ibm_cloud_pak_mcm_admin_ID> -p <ibm_cloud_pak_mcm_admin_password> -n services       

docker login docker-registry.default.svc:5000 -u <openshfit admin user>  -p `oc whoami -t`      

cloudctl catalog load-archive --archive icp-cam-[x86-64 | ppc]-4.1.tar.gz --registry docker-registry.default.svc:5000/services


# example for x86

oc login https://dc-09-jan-31eded178c-master-0.ocp-admin.com:8443 --token=aamc5R52Zt3osZ_O6BA-LB8Q4sM-6_N3YEqAGq63cY8
cloudctl login -a https://icp-console.ocp-admin.com:443 --skip-ssl-validation -u admin -p my-avengers-Herolist-ironman3000 -n services
docker login docker-registry-default.ocp-admin.com  -u admin  -p `oc whoami -t`      
cloudctl catalog load-archive --archive icp-cam-x86_64-4.1.tar.gz --registry docker-registry-default.ocp-admin.com/services




```

    For OpenShit 4.2:
```
    Copy the login command from OpenShift Console and paste it to the Infra node that can access the OpenShift Console.

     HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')

     cloudctl login -a <ibm_cloud_pak_mcm_Console_Url> --skip-ssl-validation -u <ibm_cloud_pak_mcm_admin_ID> -p <ibm_cloud_pak_mcm_password> -n services

     docker login -u <oc admin> -p $(oc whoami -t) $HOST

     cloudctl catalog load-archive --archive icp-cam-[x86-64 | ppc]-4.1.tar.gz --registry $HOST/services
```

---
###  After the helm chart loaded, install it from UI / cli

---
### From cli, you need to prepare the glusterfs and set the dynamic provision to be true
- Use GlusterFS to dynamically create four persistent volumes for Cloud Automation Manager database, log files, terraform, and Cloud Automation Manager Template Designer.
https://www.ibm.com/support/knowledgecenter/SS2L37_4.1.0.0/cam_create_pv_gluster.html?cp=SSFC4F_1.2.0

- Create a storage.yaml and apply it with helm cli while install cam

```yaml

camMongoPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "<your GlusterFS storage class name>"
camLogsPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "<your GlusterFS storage class name>"
camTerraformPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "<your GlusterFS storage class name>"
camBPDAppDataPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "<your GlusterFS storage class name>"

# Example

camMongoPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "glusterfs-storage"
camLogsPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "glusterfs-storage"
camTerraformPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "glusterfs-storage"
camBPDAppDataPV:
  persistence:
    useDynamicProvisioning: true
    storageClassName: "glusterfs-storage"
```

### To create a value.yaml for planning to use IBM Business Process Manager, IBM Cloud Orchestrator, Ansible Provider or Broker services then do the following steps:
- Increase the replica count to 1 for Business Process Manager service in values.yml. By default, the replica count for these services is set to 0.

```yaml
camBpmProvider:
 replicaCount: 1
camAnsibleProvider:
 replicaCount: 1
camIcoProvider:
 replicaCount: 1
camBrokerProvider:
 replicaCount: 1
 storeNamespace: helm-consume-test

```

### How to pass env var with helm cli
- According to this,
https://github.com/helm/helm/issues/944
Most cleaner method is also though `-f `

```yaml
#Option 3: Interpolate -f values.yaml
#The third option is to do environment variable interpolation over the file passed in with the -f flag. So say we had helm install -f foo.yaml bar, foo.yaml could contain lines like this:

token: "$MY_APP_TOKEN"
key: "$MY_APP_SECRET_KEY"

```
- Another solution can see here
https://www.ibm.com/support/knowledgecenter/en/SS2L37_3.2.1.0/cam_bpm_ico_post_install.html


- The complete example for increase the repliace set will look like 
```
```yaml
camBpmProvider:
 replicaCount: 1
camAnsibleProvider:
 replicaCount: 1
camIcoProvider:
 replicaCount: 1
camBrokerProvider:
 replicaCount: 1
 storeNamespace: helm-consume-test

name: BPM_ENDPOINT
 value: https://9.9.9.9:9443/
name: BPM_USERNAME
 value: admin
name: BPM_PASSWORD
 value: passw0rd

```

```



### How to apply the storage yaml with helm cli
    - According to this https://helm.sh/docs/intro/using_helm/ 
    - You can then override any of these settings in a YAML formatted file, and then pass that file during installation.

    There are two ways to pass configuration data during install:
        --values (or -f): Specify a YAML file with overrides. This can be specified multiple times and the rightmost file will take precedence
        --set: Specify overrides on the command line.

        $ echo '{mariadbUser: user0, mariadbDatabase: user0db}' > config.yaml
        $ helm install -f config.yaml stable/mariadb --generate-name

---
1. SSH login to the IBM Multicloud Manager master node and configure the kubectl and helm CLI commands as follows:
2. Run the following command to download the Cloud Automation Manager chart from IBM Multicloud Manager:
```sh
wget <mcm_console_URL>/helm-repo/requiredAssets/ibm-cam-4.1.0.tgz --no-check-certificate

# example
wget https://icp-console.ocp-admin.com/helm-repo/requiredAssets/ibm-cam-4.1.0.tgz --no-check-certificate
```

If you get the following similar result, means you successfully wget it
```
--2020-01-31 00:06:37--  https://icp-console.ocp-admin.com/helm-repo/requiredAssets/ibm-cam-4.1.0.tgz
Resolving icp-console.ocp-admin.com (icp-console.ocp-admin.com)... 119.81.77.190
Connecting to icp-console.ocp-admin.com (icp-console.ocp-admin.com)|119.81.77.190|:443... connected.
WARNING: cannot verify icp-console.ocp-admin.com's certificate, issued by ‘/C=US/ST=New York/L=Armonk/O=IBM Cloud Private/CN=www.ibm.com’:
  Self-signed certificate encountered.
HTTP request sent, awaiting response... 200 OK
Length: 118049 (115K) [application/octet-stream]
Saving to: ‘ibm-cam-4.1.0.tgz’

100%[=============================================================================================================>] 118,049     --.-K/s   in 0.001s  

2020-01-31 00:06:37 (86.1 MB/s) - ‘ibm-cam-4.1.0.tgz’ saved [118049/118049]
```

3. Install with helmcli
```
helm install ibm-cam-4.1.0.tgz --name cam --namespace services --set global.iam.deployApiKey=pkFopAShIXlac7OYSHkKP-LcwdEnk9U-erEftLCgG3Hb --set global.audit=false --set global.offline=false --set global.enableFIPS=false --tls

The global.enableFIPS is required only if you want to be FIPS compliant.
```

