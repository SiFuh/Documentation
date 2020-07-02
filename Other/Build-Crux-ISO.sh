#!/bin/bash

set -e

VERSION=3.5

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/opt/bin:/opt/sbin

echo "Started ISO build: $(date)"

ISODIR="/admin/repo/crux-${VERSION}-iso-ci"
ISOGIT="git://crux.nu/system/iso.git"
ISOBRANCH="${VERSION}"
#COMMIT="6e7bdc1bb9b68d914ac0bbd0a910d791f00b20a7"

rm -vf ${ISODIR}/ports/{core,opt,xorg}/*/.md5sum

if [ ! -d ${ISODIR} ]; then
    git clone ${ISOGIT} ${ISODIR}
    cd ${ISODIR}
 if [ ! -z "${COMMIT}" ]; then
  git checkout ${COMMIT}
 else
     git checkout ${ISOBRANCH}
 fi
else
    cd ${ISODIR}
    git reset --hard HEAD
 if [ ! -z "${COMMIT}" ]; then
  git checkout ${COMMIT}
 else
     git pull
 fi
fi

#ports -u
pwd

rsync -a /usr/ports/core ports/
rsync -a /usr/ports/opt ports/
rsync -a /usr/ports/xorg ports/
rsync -a /usr/ports/yenjie/f2fs-tools ports/opt
rsync -a /usr/ports/deepthought/lz4 ports /opt

prtwash ports/*/*

#sed -i -e 's,make,make -j1,g' ports/opt/gnu-efi/Pkgfile
#rm -f ports/opt/gnu-efi/.signature

patch -i ../Makefile.patch
export KERNEL_VERSION=$(head -n 10 Makefile \
       |grep "KERNEL_VERSION" \
       | awk {'print $3 '})

cp ../linux-${KERNEL_VERSION}.config kernel/

make clean rootfs-clean

make kernel

make bootstrap

(cd doc/handbook; ./get_wiki_handbook; ./get_wiki_release_notes)

sed -i -e '7s/$/ -updated/' Makefile

make iso

echo "Finished ISO build: $(date)"
