
### Installing the IBM Cloud Pak offline
https://www.ibm.com/support/knowledgecenter/en/SSFC4F_1.2.0/install/cloud_pak_foundation.html

### Install the IBM Cloud Pak for Multicloud Management

As the IBM Cloud Pak for Multicloud Management cannot install natively on the OpenShift Container Platform, the services must be installed before other Cloud Pak modules.

    Download the installer package from the IBM Passport Advantage® Opens in a new tab website.
        For a Linux x86_64 cluster, download the ibm-cp4mcm-core-1.2-x86_64.tar.gz file.
        For a Linux on Power (ppc64le) cluster, download the ibm-cp4mcm-core-1.2-ppc64le.tar.gz file.

    If there are no OpenShift Container Platform CLI tools on the boot node, you need to download, decompress, and install the OpenShift Container Platform CLI tools oc from OpenShift Container Platform client binaries Opens in a new tab.

    Load the container images into the local registry:

        For Linux x86_64:

        tar xf ibm-cp4mcm-core-1.2-x86_64.tar.gz -O | sudo docker load


        For Linux on Power (ppc64le):

        tar xf ibm-cp4mcm-core-1.2-ppc64le.tar.gz -O | sudo docker load


    Create an installation directory on the boot node:

       mkdir /opt/ibm-multicloud-manager-1.2; cd /opt/ibm-multicloud-manager-1.2


    Extract the cluster directory:

        For Linux x86_64:
```
sudo docker run --rm -v $(pwd):/data:z -e LICENSE=accept --security-opt label:disable ibmcom/mcm-inception-amd64:3.2.3 cp -r cluster /data
```

        For Linux on Power (ppc64le):

        sudo docker run --rm -v $(pwd):/data:z -e LICENSE=accept --security-opt label:disable ibmcom/mcm-inception-ppc64le:3.2.3 cp -r cluster /data


    Create cluster configuration files by using either of the following options.

        Obtain the kubeconfig from the OpenShift Container Platform:

        The OpenShift configuration files can be found on the OpenShift master node.

            Copy the OpenShift admin.kubeconfig file to the cluster directory. The OpenShift admin.kubeconfig file can be found in the /etc/origin/master/admin.kubeconfig directory:

sudo cp /etc/origin/master/admin.kubeconfig /opt/ibm-multicloud-manager-1.2/cluster/kubeconfig


            If your boot node is different from the OpenShift master node, then the previous file must be copied to the boot node.

            For an OpenShift on IBM Cloud cluster, you can obtain or generate its Kubernetes configuration by following the steps in Creating a cluster with the console Opens in a new tab. Once you log in with oc, you can generate the configuration file by running the following command:

oc config view > /opt/ibm-multicloud-manager-1.2/cluster/kubeconfig

        For Red Hat OpenShift on IBM Cloud, you can use the oc login command to update $KUBECONFIG to point to a file that can hold the profile information.

        The default location for the kubernetes config file is ~/.kube/config unless you override it.

            From your boot node terminal run the following commands:

             export KUBECONFIG=$(pwd)/myclusterconfig
            Copy

             oc login --token=EtZqGLpwxpL8b6CAjs9Bvx6kxe925a1HlB__AR3gIOs --server=https://c100-e.us-east.containers.cloud.ibm.com:32653
            Copy

            You can see that $(pwd)/myclusterconfig has been populated.

            Copy the kubeconfig file:

            cp $KUBECONFIG /opt/ibm-multicloud-manager-1.2/cluster/kubeconfig

            Copy

Update the installation config.yaml

You must update the config.yaml file or use the power.openshift.config.yaml file to replace the config.yaml for Linux on Power (ppc64le) before you deploy the services.

    Add the OpenShift Container Platform nodes that are on the cluster that you want to deploy services upon, to the config.yaml file.

        Collect information for the config.yaml file. Run oc get nodes to get all the cluster node names. Use these OpenShift Container Platform worker node names to select master, proxy, and management targets. Assign any of the OpenShift Container Platform worker nodes to each of the cluster_nodes.

        Update the cluster_nodes section of the config.yaml to identify your chosen OpenShift Container Platform worker nodes. For example:

         oc get nodes
         NAME            STATUS    ROLES                                AGE       VERSION
         10.148.87.135   Ready     compute,infra                        6h        v1.11.0+d4cacc0
         10.148.87.140   Ready     compute,infra                        6h        v1.11.0+d4cacc0
         10.148.87.186   Ready     compute,infra                        6h        v1.11.0+d4cacc0

        Notes: For Red Hat OpenShift on IBM Cloud, you see only the OpenShift Container Platform worker nodes in an IBM Cloud Kubernetes Service managed cluster. The node names are the same as the private IP address of their hosting VMs.

        Use the node information to create the following entries in the config.yaml:

         # A list of OpenShift nodes that used to run services components
         cluster_nodes:
           master:
             - 10.148.87.135
           proxy:
             - 10.148.87.135
           management:
             - 10.148.87.186
        Copy

        Note: The value of the master, proxy, and management parameters is an array and can have multiple nodes; and the same node can be used for the master, management, and proxy. Due to a limitation from OpenShift, if you want to deploy IBM Cloud Pak for Multicloud Management on any OpenShift master or infrastructure node, you must label the node as an OpenShift compute node with the following command:

         oc label node <master node host name/infrastructure node host name> node-role.kubernetes.io/compute=true
