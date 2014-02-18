​#!/bin/bash

BOOTLOADER="syslinux"
SYSTEM_NAME=
MOUNTPOINT="/mnt"
TARGET=
INSTALLATION_MODE="pacstrap"
LOCALE="en_US"
KEYMAP="cz-qwertz"
ARCHITECTURE=$(uname -m) # i686  | x86_64

ROOT_PASSWORD=root
USER_NAME=
USER_PASSWORD=
PACKAGES="base base-devel ${BOOTLOADER}"
X_SERVER_PACKAGES="xorg-server xorg-xinit synaptics"

VERBOSE=0
PACMAN_OPTIMISATION=0
INSTALl_X_SERVER=0

# $* log data
log(){
  if [[ ${VERBOSE} -eq 1 ]]; then
      echo -e $*
  fi
}

printhelp(){
    echo "-b (grub | syslinux)     Define the bootloader to installation. If this option is not used syslinux is installed by defaut."
    echo "-m                       Define the mountpoint used to install Archlinux. By defaut ${0} will use /mnt as mountpoint"
    echo "-i (pacstrap | chroot)   Define the installation mode. By defaut ${0} will use pacstrap mode."
    echo "-k                       Define the new system's locale. By default ${0} will use en_US."
    echo "-l                       Define the new system's keymap. By default ${0} will use cz-qwertz."
    echo "-x                       Install X server."
}

printusage(){
  echo "Usage : arch-inst [options] system_name target root-password username user-passorwd"
  echo "In order to list options do arch-inst -h"
}

printsummary(){
  log "\nsummary :"
  log "--------------------------------------------"
  log "system's name = "${SYSTEM_NAME}
  log "achitecture = "${ARCHITECTURE}
  log "bootloader = "${BOOTLOADER}
  log "mountpoint = "${MOUNTPOINT}
  log "target disk = "${TARGET}
  log "installation mode  = "${INSTALLATION_MODE}
  log "locale = "${LOCALE}
  log "keymap = "${KEYMAP}
  log "root password = "${ROOT_PASSWORD}
  log "user name = "${USER_NAME}
  log "user password = "${USER_PASSWORD}
  log "packages = "${PACKAGES}
  log "--------------------------------------------"
  log "verbose = "${VERBOSE}
  log "install x server = "${VERBOSE}
  log "pacman optimisation = "${PACMAN_OPTIMISATION}
  log "--------------------------------------------"
}

askconfirmation(){
#  confirmation=""
#  
#  while [ "$confirmation" != "y" ] || [ "$confirmation" != "yes" ] || [ "$confirmation" != "n" ] || [ "$confirmation" != "no" ];
#  do
#    echo -n "Confirm the opération? : "
#    read confirmation
#  done
#  if [ "$confirmation" = "n" ] || [ "$confirmation" = "no" ];
#    then
#      echo "operation aborted"
#      exit 0
#  fi
}

parseparameters(){
  while getopts vhob:m:l:k:i: options
  do
    case ${options} in
      v)
        VERBOSE=1
        ;;
      h)
        printhelp
        exit 0
        ;;
      b)
        BOOTLOADER=${OPTARG}
        ;;
      m)
        MOUNTPOINT=${OPTARG}
        ;;
      l)
        LOCALE=${OPTARG}
        ;;
      k)
        KEYMAP=${OPTARG}
        ;;
      i)
        INSTALLATION_MODE=${OPTARG}
        ;;
      o)
        PACMAN_OPTIMISATION=1
        ;;
      x)
        INSTALl_X_SERVER=1
        ;;
      ?)   
        printusage
        exit 2
    esac
  done
 
  shift $((OPTIND-1))
  #if [ $# -lt 5 ]
  #  then
  #    printusage
  #    exit 0
  #fi
 
  SYSTEM_NAME=$1
  TARGET=$2
  ROOT_PASSWORD=$3
  USER_NAME=$4
  USER_PASSWORD=$5
  shift 5
  while [[ "${1}" != "" ]]; do
    PACKAGES=${PACKAGES}" "$1
    shift
  done
}

install_package(){
  if [[ $# -lt 3 ]]; then
    echo "usage install_package instalation-mode mountpoint"
  fi

  case ${INSTALLATION_MODE} in
    "pacstrap")
      log "\tbase packages installation start ..."
      #    pacstrap ${MOUNTPOINT} base base-devel
      log "\tbase packages installation done!\n"
      ;;
    "chroot")
      ;;
    *)
      echo "instalation-mode (pactsrap | chroot)"
      exit 3
  esac
}

# ${1} = mountpoint
# ${2} = package's name
install_package_pacstrap(){
  if [[ ${#} -lt 2 ]]; then
    echo "usage install_package_pacstrap mountpoint package's_name"
  fi

  log "\t${2} packages installation start ..."
  pacstrap ${1} ${2}
  log "\t${2} packages installation done!\n"
}

# ${1} = mountpoint
# ${2} = package's name
install_package_chroot(){
  if [[ ${#} -lt 2 ]]; then
    echo "usage install_package_chroot mountpoint cahe-directory package's_name"
  fi

  CACHE_DIRECTORY=${1}/var/cache/pacman/pkg
  log "\t${2} packages installation start ..."
  pacman -r ${1} --cachedir ${CACHE_DIRECTORY} -S {2}
  log "\t${2} packages installation done!\n"
}
 
# ${1} = packages' name
install_packages(){
  log "packages installation start ...\n"

  while [[ "${1}" != "" ]]; do
    case ${INSTALLATION_MODE} in
      "pacstrap")
          install_package_pacstrap ${MOUNTPOINT} ${1}
        ;;
      "chroot")
          install_package_chroot ${MOUNTPOINT} ${1}
        ;;
      *)
      echo "instalation-mode (pactsrap | chroot)"
      exit 3
    esac
    shift
  done

  log " packages installation done!\n"
}

# ${1} bootloader's name
configure_bootloader(){
  log "bootloader installation start ..."
  case ${1} in
    "syslinux")
      log "syslinux configuration"
      syslinux-install_update -iam
      chroot ${MOUNTPOINT} vim /boot/syslinux/syslinux.conf
      ;;
    "grub")
      log "grub configuration"
      grub-install --target=i386-pc --recheck --debug ${TARGET}
      grub-mkconfig -o /boot/grub/grub.cfg
      chroot ${MOUNTPOINT} vim /boot/grub/grub.cfg
      ;;
    *)
      echo "bootloader (syslinux | grub)"
      exit 4
  esac
  log "bootloader installation done!\n"
}

# ${1} pacman optimisation
optimize_pacman(){
  if [[ ${1} -eq 1 ]];
    then
      log "pacman optimisation start ..."
      install_packages reflector
      chroot ${MOUNTPOINT} reflector --verbose -l 200 --sort rate --save ${ARCH_SYS}/etc/pacman.d/mirrorlist
      log "pacman optimisation done!\n"
        
  fi
}

configure(){
  log "system configuration start ...\n"
  # generate the fstab
  log "fstab generation start ..."
  touch ${MOUNTPOINT}/etc/fstab
  genfstab -U ${MOUNTPOINT} >> ${MOUNTPOINT}/etc/fstab
  log "fstab generation done!\n"
  # set the computer's name
  log "system's name definition start ..."
  touch ${MOUNTPOINT}/etc/hostname
  echo ${SYSTEM_NAME} >> ${MOUNTPOINT}/etc/hostname
  log "system's name definition done!\n"

  # set the local time
  log "local time definition start ..."
  ln -s ${MOUNTPOINT}/usr/share/zoneinfo/Europe/Paris ${MOUNTPOINT}/etc/localtime
  log "local time definition done!\n"

  # set the local
  log "local definition start ..."
  mv ${MOUNTPOINT}/etc/local.gen ${MOUNTPOINT}/etc/local.gen.bkp
  touch ${MOUNTPOINT}/etc/local.gen
  echo ${LOCALE}\ UTF-8 >> ${MOUNTPOINT}/etc/local.gen
  echo ${LOCALE}\ ISO-8859-1>> ${MOUNTPOINT}/etc/local.gen
  chroot ${MOUNTPOINT}  locale-gen
  echo LANG=\"${LOCALE}".UTF-8"\" >> ${MOUNTPOINT}/etc/locale.conf
  log "local definition done!\n"

  # set the keymap
  log "keymap definition start ..."
  echo KEYMAP=${KEYMAP} >> ${MOUNTPOINT}/etc/vconsole.conf
  log "keymap definition done!\n"
 
  # create initial RAM disk
  log "RAM disk creation start ..."
  chroot ${MOUNTPOINT} mkinitcpio -p linux
  log "RAM disk creation done!\n"


  # optimise pacman
  optimize_pacman ${PACMAN_OPTIMISATION}
 
  # configure bootloader
  configure_bootloader ${BOOTLOADER}

  log "system configuration done!\n"
}

unmount_all_partitions(){
  umount -R ${MOUNTPOINT}
}
 
echo "Installation start ..."
# parse script parameters
parseparameters $*
# print the summary
printsummary

# update pacman
pacman -Sy
# create all directories if needed
if [[ "${INSTALLATION_MODE}" == "chroot" ]]; then
  mkdir -p "${MOUNTPOINT}"/var/{cache/pacman/pkg,lib/pacman} "${MOUNTPOINT}"/{dev,proc,sys,run,tmp,etc,boot,root}
fi
# install base system packages
install_packages ${PACKAGES}
# install X server if needed
if [[ ${INSTALl_X_SERVER} ]]; then
  install_packages ${X_SERVER_PACKAGES}
  chroot ${MOUNTPOINT} cp /etc/skel/.xinitrc ~
fi
# configure base system
configure
# unmount all mounted partitions
unmount_all_partitions
echo "Your archlinux installation is done ;)"
exit 0
