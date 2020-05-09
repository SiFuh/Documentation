#!/bin/bash

KERNEL_OLD=$(uname -r)

echo -n "Kernel version: "
read KERNEL

(cd ~/Downloads && \
wget -c "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL:0:1}.x/linux-${KERNEL}.tar.xz")

echo "sudo su"
echo "cd /usr/src/ && tar -xpvf /admin/SiFuh/Downloads/linux-${KERNEL}.tar.xz"
echo "cd /usr/src/linux-${KERNEL}"
echo "make mrproper"
echo "cp /boot/config-${KERNEL_OLD} .config"
echo "make -j 8 all && \\"
echo "make -j 8 modules_install && \\"
echo "cp arch/x86/boot/bzImage /boot/vmlinuz-${KERNEL} && \\"
echo "cp System.map /boot/System.map-${KERNEL} && \\"
echo "cp .config /boot/config-${KERNEL}  && \\"
echo "/usr/bin/dkms autoinstall -k ${KERNEL}
