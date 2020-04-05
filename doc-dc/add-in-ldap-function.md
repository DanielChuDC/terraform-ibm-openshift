# How to have ldap function

# By using  https://github.com/osixia/docker-phpLDAPadmin

And this helm chart https://github.com/DanielChuDC/icp-openldap


### Need to add in the command below for the ldap admin pod to run due to its root permission
- oc adm policy add-scc-to-user anyuid -z default -n default
 

Check the solution here:
```
https://github.com/osixia/docker-openldap/issues/184

I did tested a little, and yes, in my case, it was clearly related to the root restricted use in Openshift (and maybe could the same for OP in Kubernetes).

FYI, here is the command line (for Openshift) to execute to solve this problem (by allowing root execution in container for the specified project name) :
oc adm policy add-scc-to-user anyuid -z default -n <yourprojectname>

Need to find how to do it for Kubernetes, but it's cleary related to Security-Context concept...

But keep in mind that, sanitizing directly the container to avoid root call is way better.
Cheers

```

### To import user
- Use cloudctl
cloudctl api
cloudctl iam ldaps # to get ldapid
cloudctl iam user-import -c <ldapid> -u <username>

cloudctl iam user-import -c f6e433b0-3475-11ea-8409-dba5be534bc7 -u user1 # example
