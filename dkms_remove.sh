#!/bin/bash

#BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
#GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
#BLUE=$(tput setaf 4)
#MAGENTA=$(tput setaf 5)
#CYAN=$(tput setaf 6)
#WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

if [ "root" != "$USER" ]; then
  echo "You are not root!"
  exit 0
fi

dkms status | while read -r j ; do
  DKMS=$(echo "$j" | sed -e 's\,\\g' | awk '{print "-m "$1" -v "$2" -k "$3 }')
  read -r -p "Run the command: 'dkms ${YELLOW}${BOLD}uninstall${RESET} ${DKMS}' [y/N]? " PROMPT 0</dev/tty
  if [[ ! ${PROMPT} =~ ^([yY][eE][sS]|[yY])$ ]] ; then
    echo "Skipping..."
  else
    /usr/bin/dkms uninstall ${DKMS}
    read -r -p "Run the command: 'dkms ${RED}${BOLD}remove${RESET} ${DKMS}' [y/N]? " PROMPT 0</dev/tty
    if [[ ! ${PROMPT} =~ ^([yY][eE][sS]|[yY])$ ]] ; then
      echo "Skipping..."
    else  
      /usr/bin/dkms remove ${DKMS}
    fi
  fi
done

read -r -p "Would you like to list dkms status before exiting [y/N]?" PROMPT
if [[ ! ${PROMPT} =~ ^([yY][eE][sS]|[yY])$ ]] ; then
  :
else
  /usr/bin/dkms status
fi

