#!/bin/bash

# Configure these options
KERNEL_LOCATION="/boot/"
DOWNLOAD_LOCATION="/admin/SiFuh/Downloads/"

# Only set this if you use CONFIG_LOCALVERSION in the kernel
LOCALVERSION="-yenjie"

# Color settings
#BLACK=$(tput setaf 0)
#RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
#YELLOW=$(tput setaf 3)
#BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
#CYAN=$(tput setaf 6)
#WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# You shouldn't need to configure anything below this line
KERNEL_OLD=$(uname -r)

check_kernel() {

  echo ""
  echo "Your current kernel version is ${GREEN}${BOLD}${KERNEL_OLD}${RESET}"
  echo ""
  echo "Checking online for the latest kernel release..."

  CHECK=$(curl -s https://www.kernel.org/ |grep -A 1 latest_link |tail -n 1)
  KERNEL=$(echo ${CHECK} | cut -d ">" -f 2 | cut -d  "<" -f 1)
  URL=$(echo ${CHECK} | cut -d "\"" -f 2)

  read -r -p "The latest kernel release is version ${MAGENTA}${BOLD}${KERNEL}${RESET}. Download [y/N]? " PROMPT 0</dev/tty
  if [[ ! ${PROMPT} =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    exit 0
  else
    cd ${DOWNLOAD_LOCATION} && wget -c ${URL}
    build_kernel
  fi

}

build_kernel() {

  echo ""
  read -r -p "Extract, prepare and build kernel version ${MAGENTA}${BOLD}${KERNEL}${RESET} [y/N]? " PROMPT 0</dev/tty
  if [[ ! ${PROMPT} =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    exit 0
  else
    echo "Changing to root"
    echo "Extracting kernel"

    sudo -i <<EOF
    cd /usr/src/ && \
    tar -xpf ${DOWNLOAD_LOCATION}/linux-${KERNEL}.tar.xz

    echo "Preparing kernel"
    cd /usr/src/linux-${KERNEL} && \
    make mrproper 

    echo "Copying ${KERNEL_LOCATION}/config-${KERNEL_OLD} to .config"
    cp ${KERNEL_LOCATION}/config-${KERNEL_OLD} .config 

    echo "Building kernel"
    make -j 8 all && \
    make -j 8 modules_install 

    echo "Copying kernel version ${MAGENTA}${BOLD}${KERNEL}${LOCALVERSION}${RESET} to ${KERNEL_LOCATION}"
    cp arch/x86/boot/bzImage ${KERNEL_LOCATION}/vmlinuz-${KERNEL}${LOCALVERSION} && \
    cp System.map ${KERNEL_LOCATION}/System.map-${KERNEL}${LOCALVERSION} && \
    cp .config ${KERNEL_LOCATION}/config-${KERNEL}${LOCALVERSION}
EOF

    build_dkms
  fi

}

build_dkms() {

  echo ""
  read -r -p "Would you like to build dkms modules for kernel version ${MAGENTA}${BOLD}${KERNEL}${LOCALVERSION}${RESET} [y/N]? " PROMPT 0</dev/tty
  if [[ ! ${PROMPT} =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    exit 0
  else
    echo "Changing to root"
    echo "Building dkms modules for kernel version ${MAGENTA}${BOLD}${KERNEL}${LOCALVERSION}${RESET}"

    sudo -i <<EOF
    /usr/sbin/dkms autoinstall -k ${KERNEL}${LOCALVERSION}
EOF

  fi

}


check_kernel
