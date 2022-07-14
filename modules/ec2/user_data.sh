#!/bin/bash
function getUserName(){
	if [[ ${USER_NAME} == "autodetect" ]]
	then
		USER_NAME=$(id 1000 | cut -d' ' -f1 | sed -r 's/^.*\((.*)\).*$/\1/')
	else
		USER_NAME=${USER_NAME}
	fi
}
function getInstaller(){
        knowndistros='
{
        "amazon":"yum",
        "ubuntu":"apt-get",
        "suse":"zypper",
        "centos":"yum"
}'
        if [[ ${INSTALLER} == "autodetect" ]]
        then
                local distro=$(cat /etc/*release | grep -i -w name | sed -r 's/^.*"(.*)".*$/\1/g')
                for knowndistro in $(echo "$knowndistros" | jq -r 'keys[]')
                do
                        if [[ $(echo $distro | grep -i $knowndistro) != "" ]]
                        then
                                INSTALLER=$(echo "$knowndistros" | jq -r '.'"$knowndistro"'')
                        fi
                done
	else
		INSTALLER=${INSTALLER}	
        fi
}
function handlePersistentDisk(){
        mkdir -p /home/persistent
        local toAdd="1"
        local toMount=$(lsblk | grep "$(echo "sdf" | sed 's/^s//')" | grep disk | cut -d' ' -f1)
        if [[ $toMount = "" ]]
        then
                toAdd="p1"
                toMount=$(lsblk | grep nvme | grep -v nvme0 | grep disk | cut -d' ' -f1)
        fi
        if [[ $toMount = "" ]]
        then
                echo "Could not find the persistent disk, retry in 1 s"
                sleep 1
                handlePersistentDisk
        fi
        toMount=$(echo "/dev/$toMount")
        existingPartitions=$(fdisk -l $toMount | grep -w -A 1 Device | grep -v Device)
        if [[ $existingPartitions == "" ]]
        then
                createAndFormatPartition $toMount $toAdd
        fi
        while ! mount "$toMount$toAdd" /home/persistent 2>/dev/null
        do
                echo "Could not mount yet"
                sleep 1
        done
        echo "Successfully mounted the disk"
        echo "$toMount$toAdd     /home/persistent          ext4    defaults,noatime  0   2">>/etc/fstab
        echo "Persistent disk added to fstab"
}

function createAndFormatPartition(){
fdisk "$1"<<EOF
n
p
1


w
EOF
while ! mkfs.ext4 "$1$2" 2>/dev/null
do
        echo "Could not format yet"
        sleep 1
done
}
function insertKeys(){
  rm /home/$USER_NAME/.ssh/authorized_keys
  echo '${PUBLIC_KEYS}' | jq -r '.[]' >>/home/$USER_NAME/.ssh/authorized_keys
  chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
  chmod 600 /home/$USER_NAME/.ssh/authorized_keys
}
getUserName
exec >>/home/$USER_NAME/log.txt
exec 2>&1
curl -L -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && chmod +x /usr/bin/jq
echo '{"foo":"bar"}' | jq || ${INSTALLER} install jq -y #get installer would not work without jq anyway
getInstaller
$INSTALLER update -y
$INSTALLER install unzip -y
$INSTALLER install git -y
$INSTALLER install tmux -y
echo '{"foo":"bar"}' | jq && insertKeys
if [[ ${PERSISTENT_STORAGE} != 0 ]]
then
	handlePersistentDisk
	HOMEDIR="/home/persistent"
  chown -R "$USER_NAME" /home/persistent
else
	HOMEDIR=$(echo "/home/$USER_NAME")
fi
if [[ ${PERSISTENT_STORAGE} != 0 ]]
then
	echo cd /home/persistent >> /home/$USER_NAME/.bashrc
fi
for addtool in $(echo '${ADDITIONAL_TOOLS}' | jq -r '.[]')
do
  $INSTALLER install $addtool -y
  if [[ $(echo $addtool | grep docker) != "" ]]
  then
    usermod -a -G docker $USER_NAME
    service docker start
    systemctl enable docker
  fi
done

su - $USER_NAME bash -c 'aws configure<<EOF


${REGION}

EOF'
echo 'cli_pager='>>/home/$USER_NAME/.aws/config
if [[ $USER_NAME == "ubuntu" ]]
then
	snap remove amazon-ssm-agent
	snap install amazon-ssm-agent --classic
fi
echo "Success"
