#!/bin/bash
#
#    swatch - a simple shell script for calcultaing Swatch Time
#
#    Copyright (c) 2021 by Lin SiFuh
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

# Configure your UTC timezone
TIMEZONE="UTC+8"

main_t() {

  if [[ "${TIMEZONE//UTC}" -gt "0" ]]; then
    Z="${TIMEZONE/+/-}"
  else
    Z="${TIMEZONE/-/+}"
  fi
  export TZ="UTC-1"
  read -r UH UM <<<"$(date --date='TZ="'${Z}'" '"${T}"'' +"%H %M";unset TZ)"
  R=$(echo "((${UH}*3600)+(${UM}*60))/86.4"|bc -l)
  echo "${T} ${TIMEZONE} = @${R}"

}

main_b() {

  Z="${TIMEZONE//UTC}"
  if [[ "${Z}" -gt "0" ]]; then
    Z="${Z#?}" Z=$(echo "${Z}-1"|bc) Z="-${Z}"
  else
    if [[ "${Z}" = "-0" ]] || [[ "${Z}" = "+0" ]]; then
      Z="${Z#?}" Z=$(echo "${Z}+1"|bc) Z="+${Z}"
    elif [[ "${Z}" -lt "0" ]]; then
      Z="${Z#?}" Z=$(echo "${Z}+1"|bc) Z="+${Z}"
    fi
  fi
  export TZ="UTC${Z}"
  S=$(echo "${B}*86.4"|bc -l)
  T=$(date -d@"${S}" +%H:%M;unset TZ)
  echo "@${B} = ${T} ${TIMEZONE}"

}

swatch_usage() {

  echo ""
  echo "Usage: swatch [-t <HH:MM>]"
  echo "       swatch [-b <beats>]"
  echo ""
  exit 0

}

swatch_options() {

  (( "${#}" )) || swatch_usage
  while getopts t:b: OPT; do
    case "${OPT}" in
      t ) T="${OPTARG}" ;;
      b ) B="${OPTARG}" ;;
      * ) swatch_usage; exit 0 ;;
    esac
  done

}

swatch_check_t() {

  if [[ "${#T}" -gt "5" ]] ; then
    swatch_usage
  else
    if [[ "${#T}" -lt "5" ]]; then
      swatch_usage
    else
      if [[ $(date -d "$T" > /dev/null 2>&1; echo $?) = "1" ]]; then
        swatch_usage
      else
        main_t
      fi
    fi
  fi

}

swatch_check_b() {

  if [[ "${B%.*}" =~ "0" ]];then
    B="0"
    main_b
  else
    regexp='^[0-9|.][.0-9]*$';test
    if expr match "${B}" "\($regexp\)" &> /dev/null ; then
      if [[ "${B%.*}" -gt "1000" ]]; then
        swatch_usage
      else
        main_b
      fi
    else
      swatch_usage
    fi
  fi

}

swatch_options "${@}" 

if [[ -n "${T}" ]]; then
  swatch_check_t
else
  if [[ -n "${B}" ]]; then
    swatch_check_b
  fi
fi

exit 0
