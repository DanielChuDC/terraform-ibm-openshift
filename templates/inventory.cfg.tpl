# OpenShift Inventory Template.
# Note that when the infrastructure is generated by Terraform, this file is
# expanded into './inventory.cfg', based on the rules in:


# Set variables common for all OSEv3 hosts
[OSEv3:vars]

ansible_ssh_user=root
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'

# Deploy OpenShift Enterprise 3.11
openshift_deployment_type=openshift-enterprise
openshift_release= "3.11"
openshift_enable_docker_excluder=false

# We need a wildcard DNS setup for our public access to services, fortunately
# we can use the superb xip.io to get one for free.
openshift_public_hostname=${master_hostname}
openshift_master_default_subdomain=${subdomain}

# Use an htpasswd file as the indentity provider.
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_disable_check= docker_image_availability,docker_storage,memory_availability,package_availability,package_version
# Uncomment the line below to enable metrics for the cluster.
# openshift_hosted_metrics_deploy=true

# https://access.redhat.com/solutions/3617551
openshift_storage_glusterfs_image="registry.access.redhat.com/rhgs3/rhgs-server-rhel7:v3.11"
openshift_storage_glusterfs_block_image="registry.access.redhat.com/rhgs3/rhgs-gluster-block-prov-rhel7:v3.11"
openshift_storage_glusterfs_heketi_image="registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7:v3.11"

openshift_cluster_monitoring_operator_install=false
openshift_cluster_monitoring_operator_node_selector={"node-role.kubernetes.io/infra":"true"}
openshift_certificate_expiry_fail_on_warn=False
oreg_auth_user=${rhn_username}
oreg_auth_password=${rhn_password}

# For icp with ocp
openshift_master_admission_plugin_config={"MutatingAdmissionWebhook":{"configuration": {"apiVersion": "apiserver.config.k8s.io/v1alpha1","kubeConfigFile": "/dev/null","kind": "WebhookAdmission"}},"ValidatingAdmissionWebhook": {"configuration": {"apiVersion": "apiserver.config.k8s.io/v1alpha1","kubeConfigFile": "/dev/null","kind": "WebhookAdmission"}},"BuildDefaults": {"configuration": {"apiVersion": "v1","env": [],"kind": "BuildDefaultsConfig","resources": {"limits": {},"requests": {}}}},"BuildOverrides": {"configuration": {"apiVersion": "v1","kind": "BuildOverridesConfig"}},"openshift.io/ImagePolicy": {"configuration": {"apiVersion": "v1","executionRules": [{"matchImageAnnotations": [{"key": "images.openshift.io/deny-execution","value": "true"}],"name": "execution-denied","onResources": [{"resource": "pods"},{"resource": "builds"}],"reject": true,"skipOnResolutionFailure": true}],"kind": "ImagePolicyConfig"}}}

#cert , remove this if you don't have customs domain
#openshift_master_named_certificates=[{"certfile":"/root/ocp-cloud.com/fullchain.pem","keyfile":"/root/ocp-cloud.com/privkey.pem"}]
#openshift_hosted_router_certificate={"certfile": "/root/ocp-cloud.com/fullchain.pem", "keyfile": "/root/ocp-cloud.com/privkey.pem", "cafile": "/root/ocp-cloud.com/chain.pem"}
#openshift_master_overwrite_named_certificates=true

# For converged mode image registry using glusterfs
openshift_hosted_registry_storage_kind=glusterfs 
openshift_hosted_registry_storage_volume_size=250Gi

# Enable Cluster metric server
openshift_metrics_install_metrics=true
openshift_metrics_cassandra_pvc_size=10Gi
openshift_metrics_cassandra_storage_type=pv
openshift_metrics_cassandra_pvc_storage_class_name=glusterfs-storage


[masters]
${master_block}

# host group for etcd
[etcd]
${master_block}

[nodes:children]
masters
compute_nodes
infra_nodes
glusterfs
glusterfs_registry

[compute_nodes]
${compute_block}

[infra_nodes]
${infra_block}

[glusterfs]
${gluster_block}

[glusterfs_registry]
${gluster_registry_block}

[virtual_nodes:children]
compute_nodes
glusterfs
masters
etcd
infra_nodes
glusterfs_registry


[seed-hosts:children]
masters

[OSEv3:children]
masters
nodes
etcd
glusterfs
glusterfs_registry