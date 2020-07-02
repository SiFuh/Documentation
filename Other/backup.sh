#!/bin/bash -
#
#    backup.sh - My backup script. If it screws up your system then you should
#    have backed up first.
#
#    Copyright (c) 2005 by Lin SiFuh
#
#    *************************************************************************
#    *                                                                       *
#    * This program is free software; you can redistribute it and/or modify  *
#    * it under the terms of the GNU General Public License as published by  *
#    * the Free Software Foundation; either version 2 of the License, or     *
#    * (at your option) any later version.                                   *
#    *                                                                       *
#    *************************************************************************
#
#   **** USE AT YOUR OWN RISK ****
#

## UUID of the drive you wish to Backup too.
DEVuuid=""
## The Directory where you wish to mount the disk.
DIRbck=""
## The directory which you wish to backup too.
BCKdir="$DIRbck/DISRTO-`date +%Y%m%d`"
## The command to backup your system.
CMDsfc="rsync -aAXv --exclude=/admin/* \
                    --exclude=/dev/* \
                    --exclude=/proc/* \
                    --exclude=/sys/* \
                    --exclude=/tmp/* \
                    --exclude=/run/* \
                    --exclude=/mnt/* \
                    --exclude=/mnt2/* \
                    --exclude=/media/* \
                    --exclude=/lost+found"

## Checking if you are root.
root_sfc(){
    if [ "root" != "$USER" ]; then
        echo "You are not root!"
        exit 0
    fi
}

## Check the filesystems integrity.
fsck_sfc(){
    echo "Running fsck $DEVdev"
    fsck -yV $DEVdev 2>&1
    backup_sfc
}

## Mounting the backup disk drive.
mount_sfc(){
    if grep -qs "$DIRbck" /proc/mounts; then
        echo "$DIRbck is already mounted. It shouldn't be."
        echo "Exiting...."
        exit 0
    else
        echo "$DIRbck is not mounted. Attempting to mount $DEVdev to $DIRbck"
        mount $DEVdev $DIRbck
        if [ $? -eq 0 ]; then
            echo "$DEVdev mounted successfully to $DIRbck!"
        else
            echo "Something went wrong with the mount..."
            echo "Exiting...."
            exit 0
        fi
    fi
}

## Unmount the backup disk drive.
umount_sfc(){
    if grep -qs "$DEVdev" /proc/mounts; then
        echo "$DEVdev is mounted. Attempting to unmount."
        umount $DEVdev
        if [ $? -eq 0 ]; then
            echo "$DEVdev unmounted successfully!"
            fsck_sfc
        else
            echo "Something went wrong with the mount..."
            exit 0
        fi
    else
        echo "$DEVdev is not mounted"
        fsck_sfc
    fi
}

## Final unmount of the backup disk drive after backup has completed.
finalumount_sfc(){
    if grep -qs "$DEVdev" /proc/mounts; then
        echo "$DEVdev is mounted. Attempting to unmount."
        umount $DEVdev
        if [ $? -eq 0 ]; then
            echo "$DEVdev unmounted successfully!"
            exit 0
        else
            echo "Something went wrong with the mount..."
            exit 0
        fi
    else
        echo "$DEVdev is not mounted."
        echo "Backup was successful."
        exit 0
    fi
}

## Backup data to disk.
backup_sfc(){
mount_sfc
    if [ -d "$BCKdir" ]; then
        echo "Destination is $BCKdir. Hope that's ok."
    else
        mkdir $BCKdir
        echo "Created new destination as $BCKdir. Hope that's ok."
    fi
    echo -n "Backing up: "
    $CMDsfc / $BCKdir
    sync
    echo "done!"
    umount $DIRbck
    finalumount_sfc
}

## Check to see if the mount point exists.
check_sfc(){
    root_sfc
    ## Find out which disk the UUID is associated with. 
    DEVdev=`blkid | grep $DEVuuid | cut -d ":" -f 1`
    if [ -d "$DIRbck" ]; then
        echo "Mount point $DIRbck exists."
        umount_sfc
    else
        echo "Mount point $DIRbck doesn't exist. I will create it"
        mkdir -p $DIRbck
    fi
    check_sfc
}
check_sfc


