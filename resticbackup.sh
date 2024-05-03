#!/bin/sh
############ PARAMETRI SCRIPT ###############
REPO_PATH="/mnt/restic/"
REPO_NAME="restic-backup-yourname/"
REPO=$REPO_PATH$REPO_NAME
ORIGIN_NFS_PATH=xxx.xxx.xxx.xxx:/YOURPATH
BACKUP_PATH="/home/yourname"
PATH_PASSWORD_FILE="/home/youruser/.pwd"
LOG_FILE="/home/yourname/restic.log"
#############################################

mount -t nfs -o v3 $ORIGIN_NFS_PATH $REPO_PATH 

if [ -d $REPO ]; then
  restic -r $REPO backup $BACKUP_PATH --password-file $PATH_PASSWORD_FILE \
    --one-file-system \
    --exclude-caches \
    --exclude ".cache" \
    --exclude ".config/google-chrome" \
    --exclude ".local" \
    --exclude ".dbus" \
    --exclude ".gvfs" \
    --exclude ".local/share/flatpak" \
    --exclude "VirtualBox VMs*" \
    --exclude "snap"  \
    > $LOG_FILE \
  || echo "Restic Backup: Failed to backup"

restic -r $REPO forget --password-file $PATH_PASSWORD_FILE \
    --keep-hourly 12 \
    --keep-daily 7 \
    --keep-weekly 5 \
    --keep-monthly 6 \
    --prune \
    >> $LOG_FILE \
  || echo "Restic Backup: Failed to prune"

restic -r $REPO check --password-file $PATH_PASSWORD_FILE \
    --with-cache \
    >> $LOG_FILE \
  || echo "Restic Backup: Check failed"
  umount $REPO_PATH
else
  echo "Restic Backup: Repository not found !" > $LOG_FILE
  umount $REPO_PATH
fi

chmod 666 $LOG_FILE
