https://access.redhat.com/solutions/3716861


Resolution

    Ensure that all pending CSRs are approved
    Raw

    oc get csr -o name | xargs oc adm certificate approve

    Ensure that atomic-openshift-node service is running on all relevant nodes
    Raw

    systemctl status atomic-openshift-node

    Ensure that the API server can proxy a request to the node's kubelet
    Raw

    oc get --raw /api/v1/nodes/${NAME}/proxy/healthz
    /// alternative to check all
    for i in $(oc get nodes --no-headers -o=custom-columns=NAME:.metadata.name); do printf "${i}\n"; oc get --raw /api/v1/nodes/${i}/proxy/healthz ; printf "\n"; done;




https://access.redhat.com/solutions/3680401
