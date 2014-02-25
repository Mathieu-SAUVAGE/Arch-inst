#!/bin/sh

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
X_SERVER_PACKAGES="xorg-server xorg-xinit"

VERBOSE=0
PACMAN_OPTIMISATION=0
INSTALl_X_SERVER=0
ARGS=

# $* log data
log(){
  if [[ ${VERBOSE} -eq 1 ]]; then
      echo -e $*
  fi
}

printhelp(){
    echo "-b | --bootloader  (grub | syslinux)          Define the bootloader to installation. If this option is not used syslinux is installed by defaut."
    echo "-m | --mountpoint                             Define the mountpoint used to install Archlinux. By defaut ${0} will use /mnt as mountpoint."
    echo "-i | --instalation_mode (pacstrap | chroot)   Define the installation mode. By defaut ${0} will use pacstrap mode."
    echo "-k | --keymap                                 Define the new system's locale. By default ${0} will use en_US."
    echo "-l | --locale                                 Define the new system's keymap. By default ${0} will use cz-qwertz."
    echo "-v | --verbose                                Enable verbose mode."
    echo "-x | --installation_mode                      Install X server."
}

printusage(){
  echo "Usage : arch-inst [options] system_name target root-password username user-passorwd."
  echo "In order to list options do arch-inst -h."
}

printsummary(){
  log "\nsummary :"
  log "--------------------------------------------"
  log "System's name = "${SYSTEM_NAME}
  log "Achitecture = "${ARCHITECTURE}
  log "Bootloader = "${BOOTLOADER}
  log "Mountpoint = "${MOUNTPOINT}
  log "Target disk = "${TARGET}
  log "Installation mode  = "${INSTALLATION_MODE}
  log "Locale = "${LOCALE}
  log "Keymap = "${KEYMAP}
  log "Root password = "${ROOT_PASSWORD}
  log "User name = "${USER_NAME}
  log "User password = "${USER_PASSWORD}
  log "Packages = "${PACKAGES}
  log "--------------------------------------------"
  log "Merbose = "${VERBOSE}
  log "Install x server = "${VERBOSE}
  log "Pacman optimisation = "${PACMAN_OPTIMISATION}
  log "--------------------------------------------"
}

parseparameters(){
  ARGS=$(getopt -c $0 -o vhob:m:l:k:i: -l "verbose,help,pacman_optimisation,bootloader:,mountpoint:,locale:,keymap:,installation_mode:" -n "getopt.sh" -- "$@");
  eval set -- ${ARGS};

  while true; do
    case ${1} in
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      -h|--help)
        printhelp
        exit 0
        ;;
      -b|--bootloader)
        BOOTLOADER=${1}
        shift 2
        ;;
      -m|--mountpoint)
        MOUNTPOINT=${1}
        shift 2
        ;;
      -l|--locale)
        LOCALE=${1}
        shift 2
        ;;
      -k|--keymap)
        KEYMAP=${1}
        shift 2
        ;;
      -i|--installation_mode)
        INSTALLATION_MODE=${1}
        shift 2
        ;;
      -o|--pacman_optimisation)
        PACMAN_OPTIMISATION=1
        PACKAGES=${PACKAGES}" reflector"
        shift
        ;;
      -x|--installation_mode)
        INSTALL_X_SERVER=1
        PACKAGES=${PACKAGES}" "${X_SERVER_PACKAGES}
        shift
        ;;
      --)
        shift
        break
        ;;
    esac
  done 
  
  if [ $# -lt 5 ]
    then
      printusage
      exit 0
  fi
 
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

# ${1} = mountpoint
# ${2} = packages' name
install_package_pacstrap(){
  if [[ $# -lt 2 ]]; then
    echo "usage install_package_pacstrap mountpoint package's_name"
  fi
  log "\t${2} packages installation start ..."
  MOUNT=${1}
  shift
  pacstrap ${MOUNT} ${PACKAGES}
  log "\t${2} packages installation done!\n"
}

# ${1} = mountpoint
# ${2} = packages' name
install_package_chroot(){
  if [[ $# -lt 2 ]]; then
    echo "usage install_package_chroot mountpoint cahe-directory package's_name"
  fi
  log "\t${2} packages installation start ..."
  MOUNT=${1}
  shift
  CACHE_DIRECTORY=${MOUNT}/var/cache/pacman/pkg
  pacman -r ${MOUNT} --cachedir ${CACHE_DIRECTORY} -S ${PACKAGES}
  log "\t${2} packages installation done!\n"
}
 
# ${*} = packages' name
install_packages(){
  log "packages installation start ...\n"

  case ${INSTALLATION_MODE} in
    "pacstrap")
       install_package_pacstrap ${MOUNTPOINT}
       ;;
    "chroot")
      install_package_chroot ${MOUNTPOINT}
      ;;
    *)
      echo "instalation-mode (pactsrap | chroot)"
      exit 3
    esac

  log " packages installation done!\n"
}

# ${1} = packages' name
install_system(){
  # create all directories if needed
  if [[ "${INSTALLATION_MODE}" == "chroot" ]]; then
    mkdir -p "${MOUNTPOINT}/var/{cache/pacman/pkg,lib/pacman}" "${MOUNTPOINT}/{home,dev,proc,sys,run,tmp,etc,boot,root}"
  fi
  # install base system packages
  install_packages
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


optimize_pacman(){
  log "pacman optimisation start ..."
  chroot ${MOUNTPOINT} reflector --verbose -l 200 --sort rate --save ${ARCHITECTURE}/etc/pacman.d/mirrorlist
  log "pacman optimisation done!\n"
}

configure_system(){
  log "system configuration start ...\n"
  # generate the fstab
  log "fstab generation start ..."
  genfstab -U ${MOUNTPOINT} >> ${MOUNTPOINT}/etc/fstab
  log "fstab generation done!\n"
  # set the computer's name
  log "system's name definition start ..."
  echo ${SYSTEM_NAME} >> ${MOUNTPOINT}/etc/hostname
  log "system's name definition done!\n"

  # set the local time
  log "local time definition start ..."
  ln -s ${MOUNTPOINT}/usr/share/zoneinfo/Europe/Paris ${MOUNTPOINT}/etc/localtime
  log "local time definition done!\n"

  # set the local
  log "local definition start ..."
  mv ${MOUNTPOINT}/etc/local.gen ${MOUNTPOINT}/etc/local.gen.bkp
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
  if [[ ${PACMAN_OPTIMISATION} -eq 1 ]];
    then
      log "pacman optimisation start ..."
      optimize_pacman
      log "pacman optimisation done!\n"
  fi
  
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
# install the system
install_system
# configure base system
configure_system
# unmount all mounted partitions
unmount_all_partitions
echo "Your archlinux installation is done ;)"
exit 0
