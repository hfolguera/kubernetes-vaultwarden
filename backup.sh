DATE=`date +"%d%m%Y"`

NS=vaultwarden

VOL=`kubectl get pvc vaultwarden-pv-claim -n vaultwarden -o jsonpath='{.spec.volumeName}'`

PATH=`kubectl get pv pvc-8a90d510-4248-4c11-b194-50f196ac427b -o jsonpath='{.spec.nfs.path}' | cut -d / -f 4`

SOURCE_PATH=/k8s_nfs/$PATH
DEST_PATH=/nfs/homelab/backup/vaultwarden/

/usr/bin/tar -cvf $DEST_PATH/vaultwarden_backup_${DATE}.tar.gz $SOURCE_PATH

#Purge old backups
find $DEST_PATH/*.tar.gz -mtime +7 -exec rm {} \;
