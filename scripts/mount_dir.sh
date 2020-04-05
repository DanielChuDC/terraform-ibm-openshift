#!/bin/bash

# https://cloud.ibm.com/docs/infrastructure/BlockStorage?topic=BlockStorage-mountingLinux
# Create Physical Volumes
# Assume that you have a /dev/xvdc as data disk
# Or you have a block storage in this case
# You need to know the name of the disk to format it.
# That is why below srcipt will get the name of disk mount on the system
# Using lvm2 to format into logical disk


###!!!! Cannot mount iSCSI storage in /etc/fstab will cause boot problem


#LOGFILE=/tmp/hostname.log
#exec > $LOGFILE 2>&1


#fdisk -l | awk '/dev.mapper/{print}' #Similar string contain dev or mapper


echo "=================================================="
echo "= Start of mount_dir.sh"
echo "= Parameter 1 (docker directory file)       : $1"
echo "= If you have more directory file need to mount on start time to ensure the device have enough space to run ICP       : "
echo "= You can add in mount_dir.sh : "
echo "= Getting var for /dev/mapper for block storage"
echo "=================================================="



VARI=`fdisk -l | awk '/dev.mapper/{print $2}' | sed 's/\://g'` # sed to replace the ':' to nothing, use awk to print the desire disk name

echo $VARI

HOST=`hostname`
echo $HOST



# Before it start, need to check the yum repo for lvm existing
echo "=================================================="
echo "= Check yum repo - lvm existence"
echo "=================================================="
if rpm -q lvm &>/dev/null 2>&1;
then
    echo " Package installed."
else
    echo " Package not install. Installing now..."
    sudo yum update -y;
    sudo yum install lvm -y;
    sudo yum install -y lvm2 device-mapper-persistent-data;
fi

# Using pvcreate to create a logical volume based on data disk
pvcreate /dev/xvdc

# Create Volume Groups
# Using vgcreate to create a volume group
vgcreate icp-vg /dev/xvdc

# Create Logical Volumes
# ${kubelet_lv} ${etcd_lv} ${docker_lv} ${management_lv} are the disk size
lvcreate -L 200G -n docker-lv icp-vg
if [[ $HOST =~ "master" ]]
then
   mkdir /opt/ibm-cloud-private-3.2.0
   lvcreate -L 99G -n icp-lv icp-vg
fi

#Create Filesystems
# Format the logical volumes as ext4
mkfs.ext4 /dev/icp-vg/docker-lv
if [[ $HOST =~ "master" ]]
then
   mkfs.ext4 /dev/icp-vg/icp-lv
fi

# Check if the directory is not there
# i.e. /var/lib/docker
# Bear in mind , nfs need to use `test` command , use this will cause time out.
# https://stackoverflow.com/questions/40082346/how-to-check-if-a-file-exists-in-a-shell-script
FILE=/var/lib/docker
if [ -d "$FILE" ];
then # -d : directory ; -e : file
    echo "$FILE exists, skipping for next step."
else
    echo "$FILE not exists. Create the directory now..."
    # Create Directories
    mkdir -p /var/lib/docker
fi


if [[ $HOST =~ "master" ]]
then # -d : directory ; -e : file
    echo "$HOST is master, mount /opt in fstab"
# Add mount in /etc/fstab
# Finally we link the folder with the logical volume
# put it into /etc/fstab to persist the volume during restart
cat <<EOL | tee -a /etc/fstab
/dev/mapper/icp--vg-docker--lv /var/lib/docker ext4 defaults 0 0
/dev/mapper/icp--vg-icp--lv /opt/ibm-cloud-private-3.2.0 ext4 defaults 0 0
EOL
else
    echo "$HOST not master. Do not mount /opt in fstab"
# Add mount in /etc/fstab
# Finally we link the folder with the logical volume
# put it into /etc/fstab to persist the volume during restart
cat <<EOL | tee -a /etc/fstab
/dev/mapper/icp--vg-docker--lv /var/lib/docker ext4 defaults 0 0
EOL

fi


# Mount Filesystems
# Using mount command to mount all
# If mount success, will have no error or log output.
mount -a

# Verifying the mount is success
# Using df -Th <the directory you create>
# The output should return you the example name as : /dev/mapper/icp--<logical volume you create just now>--lv
if [[ $HOST =~ "master" ]]
then
   df -Th /opt/ibm-cloud-private-3.2.0
fi
df -Th /var/lib/docker
