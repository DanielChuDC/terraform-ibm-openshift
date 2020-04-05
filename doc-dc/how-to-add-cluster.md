

- Success
```yaml

customresourcedefinition.apiextensions.k8s.io/endpoints.multicloud.ibm.com configured
namespace/multicluster-endpoint configured
secret/klusterlet-bootstrap configured
secret/multicluster-endpoint-operator-pull-secret configured
serviceaccount/ibm-multicluster-endpoint-operator configured
clusterrolebinding.rbac.authorization.k8s.io/ibm-multicluster-endpoint-operator configured
deployment.apps/ibm-multicluster-endpoint-operator configured
endpoint.multicloud.ibm.com/endpoint created



```

- Failed
```yaml
customresourcedefinition.apiextensions.k8s.io/endpoints.multicloud.ibm.com configured
namespace/multicluster-endpoint configured
secret/klusterlet-bootstrap configured
secret/multicluster-endpoint-operator-pull-secret configured
serviceaccount/ibm-multicluster-endpoint-operator configured
clusterrolebinding.rbac.authorization.k8s.io/ibm-multicluster-endpoint-operator configured
deployment.apps/ibm-multicluster-endpoint-operator configured
error: unable to recognize "STDIN": no matches for kind "Endpoint" in version "multicloud.ibm.com/v1beta1"


# Solution:
Wait for a while and execute the command again
Take a look here for more info
https://www.ibm.com/support/knowledgecenter/en/SSBS6K_3.2.1/mcm/manage_cluster/import_cli.html


```