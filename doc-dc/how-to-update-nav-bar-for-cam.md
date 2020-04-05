### For update nav bar for Cloud Automation Manager

- https://www.ibm.com/support/knowledgecenter/SS2L37_4.1.0.0/cam_navigation_cloudpak_install.html?cp=SSFC4F_1.2.0


Enable navigation to the Cloud Automation Manager within the IBM Cloud Pak console.

Complete the following steps to enable navigation to Cloud Automation Manager.
```sh
# 1. Obtain the menu customization script automation-navigation-updates.sh from IBM Passport Advantage® Opens in a new tab website. You must run the script on a Linux operating system.

# 2. Install and authenticate kubectl. For more information, see Managing your clusters with IBM Cloud Pak for Multicloud Management.

# 3. You must install JQ. For more information, see Download jq Opens in a new tab.

# 4. Run the following command to enable navigation to your Cloud Automation Manager located in the default namespace (services):

chmod 755 ./automatation-navigation-updates.sh -a

# 5. Run the following command to enable navigation to your Cloud Automation Manager located in a different namespace:

chmod 755 ./automatation-navigation-updates.sh -a mynamespace

# example
[ danielchu ~]$ ./automation-navigation-updates.sh -a services
Checking if kubectl is installed...
kubectl is installed
Running kubectl command to retrieve navigation items...
*** A backup cr file is stored in ./navconfigurations.orginal

Finished importing into navconfigurations.yaml
Verifying...
Navconfigurations.yaml file is valid
Navigation items added to file
Updating MCM with new items...
Finished updating MCM
Success!


# 6. Verify that the Cloud Automation Manager instance is in the IBM Cloud Pak console navigation menu. From the IBM Cloud Pak navigation menu click Automate infrastructure > Terraform Automation .
```
Cloud Automation Manager is integrated with the IBM Cloud Pak console.
