#!/bin/sh

CHROOT="chroot"
PACSTRAP="pacstrap"

SYSLINUX=syslinux
GRUB=grub

SYSTEM_NAME=
TARGET=
BOOTLOADER=${SYSLINUX}
MOUNTPOINT=/mnt
INSTALLATION_MODE=${PACSTRAP}
LOCALE=en_US.UTF-8\ UTF-8
LOCALE_TIME=America/Los_Angeles
KEYMAP=cz-qwertz
ARCHITECTURE=$(uname -m) # i686  | x86_64

ROOT_PASSWORD=root
USER_NAME=
USER_PASSWORD=
PACKAGES=(base base-devel ${BOOTLOADER})
X_SERVER_PACKAGES=(xorg-server xorg-xinit)
PACMAN_OPTIMISATION_PACKAGES=reflector

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
	echo "-b | --bootloader (grub | syslinux)           Define the bootloader to installation. If this option is not used syslinux is installed by defaut."
	echo "-i | --instalation_mode (pacstrap | chroot)   Define the installation mode. By defaut ${0} will use pacstrap mode."
	echo "-k | --keymap                                 Define the new system's locale. By default ${0} will use en_US."
	echo "-l | --locale                                 Define the new system's keymap. By default ${0} will use cz-qwertz."
	echo "-m | --mountpoint                             Define the mountpoint used to install Archlinux. By defaut ${0} will use /mnt as mountpoint."
	echo "-t | --localtime                              Define the locale time."
	echo "-v | --verbose                                Enable verbose mode."
	echo "-x | --installation_mode                      Install X server."
}

print_usage(){
	echo "Usage : arch-install [options] system_name target root-password username user-passorwd."
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
	log "Locale time = "${LOCALE_TIME}
	log "Keymap = "${KEYMAP}
	log "Root password = "${ROOT_PASSWORD}
	log "User name = "${USER_NAME}
	log "User password = "${USER_PASSWORD}
	log "Packages = "${PACKAGES[@]}
	log "--------------------------------------------"
	log "Merbose = "${VERBOSE}
	log "Install x server = "${INSTALl_X_SERVER}
	log "Pacman optimisation = "${PACMAN_OPTIMISATION}
	log "--------------------------------------------"
}

parseparameters(){
	ARGS=$(getopt -c $0 -o vhob:m:l:k:i:t: -l "verbose,help,pacman_optimisation,bootloader:,mountpoint:,locale:,keymap:,installation_mode:,localtime:" -n "getopt.sh" -- "$@");
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
			BOOTLOADER=${2}
			shift 2
			;;
		-m|--mountpoint)
			MOUNTPOINT=${2}
			shift 2
			;;
		-l|--locale)
			LOCALE=${2}
			shift 2
			;;
		-t|--localetime)
			LOCALE_TIME=${2}
			shift 2
			;;
		-k|--keymap)
			KEYMAP=${2}
			shift 2
			;;
		-i|--installation_mode)
 			INSTALLATION_MODE=${2}
 			shift 2
 			;;
		-o|--pacman_optimisation)
 			PACMAN_OPTIMISATION=1
 			PACKAGES=(${PACKAGES[*]} ${PACMAN_OPTIMISATION_PACKAGES})
 			shift
 			;;
		-x|--installation_mode)
 			INSTALL_X_SERVER=1
 			PACKAGES=(${PACKAGES[*]} ${X_SERVER_PACKAGES[*]})
 			shift
 			;;
		--)
 			shift
 			break
 			;;
		esac
	done

	if [[ $# -lt 5 ]]
	then
		print_usage
		exit 0
	fi
 
	SYSTEM_NAME=$1
	TARGET=$2
	ROOT_PASSWORD=$3
	USER_NAME=$4
	USER_PASSWORD=$5
	shift 5
	PACKAGES=(${PACKAGES[@]} ${*})
}

install_packages_pacstrap(){
	log "\t packages installation start ..."
	pacstrap ${MOUNTPOINT} ${*}
	log "\t packages installation done!\n"
}

install_packages_chroot(){
	log "\t packages installation start ..."
	CACHE_DIRECTORY=${MOUNTPOINT}/var/cache/pacman/pkg
	pacman -r ${MOUNTPOINT} --cachedir ${CACHE_DIRECTORY} -S ${*}
	log "\t packages installation done!\n"
}

install_system(){
	log "system installation start ...\n"
	case ${INSTALLATION_MODE} in
		"${PACSTRAP}")
			install_packages_pacstrap ${PACKAGES[*]}
			;;
		"${CHROOT}")
			pacman -Sy

			mkdir -p ${MOUNTPOINT}/var/cache/pacman/pkg
			mkdir -p ${MOUNTPOINT}/var/lib/pacman
			mkdir -p ${MOUNTPOINT}/home
			mkdir -p ${MOUNTPOINT}/dev
			mkdir -p ${MOUNTPOINT}/proc
			mkdir -p ${MOUNTPOINT}/sys
			mkdir -p ${MOUNTPOINT}/run
			mkdir -p ${MOUNTPOINT}/tmp
			mkdir -p ${MOUNTPOINT}/etc
			mkdir -p ${MOUNTPOINT}/boot
			mkdir -p ${MOUNTPOINT}/root

			install_packages_chroot ${PACKAGES[*]}
			;;
		*)
			echo "instalation-mode (pactsrap | chroot)"
			exit 3
	esac
	log "system installation done!\n"
}


configure_bootloader(){
	log "bootloader installation start ..."
	case ${1} in
		${SYSLINUX})
			log "syslinux configuration"
			syslinux-install_update -iam
			chroot ${MOUNTPOINT} vim /boot/syslinux/syslinux.conf
			;;
		${GRUB})
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
	ln -s ${MOUNTPOINT}/usr/share/zoneinfo/${LOCALE_TIME} ${MOUNTPOINT}/etc/localtime
	log "local time definition done!\n"
	# set the local
	log "local definition start ..."
	genlocales -f ${MOUNTPOINT}/etc/local.gen ${LOCALE}
	chroot ${MOUNTPOINT} locale-gen
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
	log "Unmout all partitions!\n"
	umount -R ${MOUNTPOINT}
	log "All partition unmounted!\n"
}
 
echo "Installation start ..."
# parse script parameters
parseparameters $*
# print the summary
printsummary
# install the system
install_system
# configure base system
configure_system
# unmount all mounted partitions
unmount_all_partitions
echo "Your archlinux installation is done ;)"
exit 0
