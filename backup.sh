DATE=`date +"%d%m%Y"`

NS=vaultwarden

VOL=`kubectl get pvc vaultwarden-pv-claim -n $NS -o jsonpath='{.spec.volumeName}'`

VW_FOLDER=`kubectl get pv $VOL -o jsonpath='{.spec.nfs.path}' | cut -d / -f 4`

SOURCE_PATH=/k8s_nfs/$VW_FOLDER
DEST_PATH=/nfs/homelab/backup/vaultwarden

/usr/bin/tar -cvf $DEST_PATH/vaultwarden_backup_${DATE}.tar.gz $SOURCE_PATH

#Purge old backups
find $DEST_PATH/*.tar.gz -mtime +7 -exec rm {} \;
