#!/bin/bash

# Add this script to crontab with: 0 0 * * * /root/kubernetes-vaultwarden/backup.sh >> /root/kubernetes-vaultwarden/backup.log 2>>/root/kubernetes-vaultwarden/backup.error

export KUBECONFIG=/etc/kubernetes/admin.conf
DATE=`date +"%d%m%Y"`
echo "[DEBUG] KUBECONFIG: $KUBECONFIG"

echo "[INFO] Starting backup for vaultwarden at $DATE"

NS=vaultwarden

VOL=`/usr/bin/kubectl get pvc vaultwarden-pv-claim -n $NS -o jsonpath='{.spec.volumeName}'`
if [ -z "$VOL" ]
then
    echo "[ERROR] Cannot get vaultwarden volume!"
    exit 1
else
    echo "[DEBUG] Vaultwarden volume: $VOL"
fi
VW_FOLDER=`/usr/bin/kubectl get pv $VOL -o jsonpath='{.spec.nfs.path}' | cut -d / -f 4`

SOURCE_PATH=/k8s_nfs/$VW_FOLDER
echo "[DEBUG] Vaultwarden folder: $SOURCE_PATH"
DEST_PATH=/nfs/homelab/backup/vaultwarden
echo "[INFO] Backup destination: $DEST_PATH/vaultwarden_backup_${DATE}.tar.gz"

# Execute backup
echo "[INFO] tar -cvf $DEST_PATH/vaultwarden_backup_${DATE}.tar.gz $SOURCE_PATH"
/usr/bin/tar -cvf $DEST_PATH/vaultwarden_backup_${DATE}.tar.gz $SOURCE_PATH

echo "[INFO] Backup finished"
echo "[INFO] Purging old backups"
#Purge old backups
find $DEST_PATH/*.tar.gz -mtime +7 -exec rm {} \;
echo "[INFO] End of script"
echo ""