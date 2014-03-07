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

LOCALES_ARRAY=(
 "aa_DJ.UTF-8 UTF-8"
 "aa_DJ ISO-8859-1"
 "aa_ER UTF-8"
 "aa_ER@saaho UTF-8"
 "aa_ET UTF-8"
 "af_ZA.UTF-8 UTF-8"
 "af_ZA ISO-8859-1"
 "am_ET UTF-8"
 "an_ES.UTF-8 UTF-8"
 "an_ES ISO-8859-15"
 "ar_AE.UTF-8 UTF-8"
 "ar_AE ISO-8859-6"
 "ar_BH.UTF-8 UTF-8"
 "ar_BH ISO-8859-6"
 "ar_DZ.UTF-8 UTF-8"
 "ar_DZ ISO-8859-6"
 "ar_EG.UTF-8 UTF-8"
 "ar_EG ISO-8859-6"
 "ar_IN UTF-8"
 "ar_IQ.UTF-8 UTF-8"
 "ar_IQ ISO-8859-6"
 "ar_JO.UTF-8 UTF-8"
 "ar_JO ISO-8859-6"
 "ar_KW.UTF-8 UTF-8"
 "ar_KW ISO-8859-6"
 "ar_LB.UTF-8 UTF-8"
 "ar_LB ISO-8859-6"
 "ar_LY.UTF-8 UTF-8"
 "ar_LY ISO-8859-6"
 "ar_MA.UTF-8 UTF-8"
 "ar_MA ISO-8859-6"
 "ar_OM.UTF-8 UTF-8"
 "ar_OM ISO-8859-6"
 "ar_QA.UTF-8 UTF-8"
 "ar_QA ISO-8859-6"
 "ar_SA.UTF-8 UTF-8"
 "ar_SA ISO-8859-6"
 "ar_SD.UTF-8 UTF-8"
 "ar_SD ISO-8859-6"
 "ar_SY.UTF-8 UTF-8"
 "ar_SY ISO-8859-6"
 "ar_TN.UTF-8 UTF-8"
 "ar_TN ISO-8859-6"
 "ar_YE.UTF-8 UTF-8"
 "ar_YE ISO-8859-6"
 "ayc_PE UTF-8"
 "az_AZ UTF-8"
 "as_IN UTF-8"
 "ast_ES.UTF-8 UTF-8"
 "ast_ES ISO-8859-15"
 "be_BY.UTF-8 UTF-8"
 "be_BY CP1251"
 "be_BY@latin UTF-8"
 "bem_ZM UTF-8"
 "ber_DZ UTF-8"
 "ber_MA UTF-8"
 "bg_BG.UTF-8 UTF-8"
 "bg_BG CP1251"
 "bho_IN UTF-8"
 "bn_BD UTF-8"
 "bn_IN UTF-8"
 "bo_CN UTF-8"
 "bo_IN UTF-8"
 "br_FR.UTF-8 UTF-8"
 "br_FR ISO-8859-1"
 "br_FR@euro ISO-8859-15"
 "brx_IN UTF-8"
 "bs_BA.UTF-8 UTF-8"
 "bs_BA ISO-8859-2"
 "byn_ER UTF-8"
 "ca_AD.UTF-8 UTF-8"
 "ca_AD ISO-8859-15"
 "ca_ES.UTF-8 UTF-8"
 "ca_ES ISO-8859-1"
 "ca_ES@euro ISO-8859-15"
 "ca_FR.UTF-8 UTF-8"
 "ca_FR ISO-8859-15"
 "ca_IT.UTF-8 UTF-8"
 "ca_IT ISO-8859-15"
 "crh_UA UTF-8"
 "cs_CZ.UTF-8 UTF-8"
 "cs_CZ ISO-8859-2"
 "csb_PL UTF-8"
 "cv_RU UTF-8"
 "cy_GB.UTF-8 UTF-8"
 "cy_GB ISO-8859-14"
 "da_DK.UTF-8 UTF-8"
 "da_DK ISO-8859-1"
 "de_AT.UTF-8 UTF-8"
 "de_AT ISO-8859-1"
 "de_AT@euro ISO-8859-15"
 "de_BE.UTF-8 UTF-8"
 "de_BE ISO-8859-1"
 "de_BE@euro ISO-8859-15"
 "de_CH.UTF-8 UTF-8"
 "de_CH ISO-8859-1"
 "de_DE.UTF-8 UTF-8"
 "de_DE ISO-8859-1"
 "de_DE@euro ISO-8859-15"
 "de_LU.UTF-8 UTF-8"
 "de_LU ISO-8859-1"
 "de_LU@euro ISO-8859-15"
 "doi_IN UTF-8"
 "dv_MV UTF-8"
 "dz_BT UTF-8"
 "el_GR.UTF-8 UTF-8"
 "el_GR ISO-8859-7"
 "el_CY.UTF-8 UTF-8"
 "el_CY ISO-8859-7"
 "en_AG UTF-8"
 "en_AU.UTF-8 UTF-8"
 "en_AU ISO-8859-1"
 "en_BW.UTF-8 UTF-8"
 "en_BW ISO-8859-1"
 "en_CA.UTF-8 UTF-8"
 "en_CA ISO-8859-1"
 "en_DK.UTF-8 UTF-8"
 "en_DK ISO-8859-1"
 "en_GB.UTF-8 UTF-8"
 "en_GB ISO-8859-1"
 "en_HK.UTF-8 UTF-8"
 "en_HK ISO-8859-1"
 "en_IE.UTF-8 UTF-8"
 "en_IE ISO-8859-1"
 "en_IE@euro ISO-8859-15"
 "en_IN UTF-8"
 "en_NG UTF-8"
 "en_NZ.UTF-8 UTF-8"
 "en_NZ ISO-8859-1"
 "en_PH.UTF-8 UTF-8"
 "en_PH ISO-8859-1"
 "en_SG.UTF-8 UTF-8"
 "en_SG ISO-8859-1"
 "en_US.UTF-8 UTF-8"
 "en_US ISO-8859-1"
 "en_ZA.UTF-8 UTF-8"
 "en_ZA ISO-8859-1"
 "en_ZM UTF-8"
 "en_ZW.UTF-8 UTF-8"
 "en_ZW ISO-8859-1"
 "es_AR.UTF-8 UTF-8"
 "es_AR ISO-8859-1"
 "es_BO.UTF-8 UTF-8"
 "es_BO ISO-8859-1"
 "es_CL.UTF-8 UTF-8"
 "es_CL ISO-8859-1"
 "es_CO.UTF-8 UTF-8"
 "es_CO ISO-8859-1"
 "es_CR.UTF-8 UTF-8"
 "es_CR ISO-8859-1"
 "es_CU UTF-8"
 "es_DO.UTF-8 UTF-8"
 "es_DO ISO-8859-1"
 "es_EC.UTF-8 UTF-8"
 "es_EC ISO-8859-1"
 "es_ES.UTF-8 UTF-8"
 "es_ES ISO-8859-1"
 "es_ES@euro ISO-8859-15"
 "es_GT.UTF-8 UTF-8"
 "es_GT ISO-8859-1"
 "es_HN.UTF-8 UTF-8"
 "es_HN ISO-8859-1"
 "es_MX.UTF-8 UTF-8"
 "es_MX ISO-8859-1"
 "es_NI.UTF-8 UTF-8"
 "es_NI ISO-8859-1"
 "es_PA.UTF-8 UTF-8"
 "es_PA ISO-8859-1"
 "es_PE.UTF-8 UTF-8"
 "es_PE ISO-8859-1"
 "es_PR.UTF-8 UTF-8"
 "es_PR ISO-8859-1"
 "es_PY.UTF-8 UTF-8"
 "es_PY ISO-8859-1"
 "es_SV.UTF-8 UTF-8"
 "es_SV ISO-8859-1"
 "es_US.UTF-8 UTF-8"
 "es_US ISO-8859-1"
 "es_UY.UTF-8 UTF-8"
 "es_UY ISO-8859-1"
 "es_VE.UTF-8 UTF-8"
 "es_VE ISO-8859-1"
 "et_EE.UTF-8 UTF-8"
 "et_EE ISO-8859-1"
 "et_EE.ISO-8859-15 ISO-8859-15"
 "eu_ES.UTF-8 UTF-8"
 "eu_ES ISO-8859-1"
 "eu_ES@euro ISO-8859-15"
 "fa_IR UTF-8"
 "ff_SN UTF-8"
 "fi_FI.UTF-8 UTF-8"
 "fi_FI ISO-8859-1"
 "fi_FI@euro ISO-8859-15"
 "fil_PH UTF-8"
 "fo_FO.UTF-8 UTF-8"
 "fo_FO ISO-8859-1"
 "fr_BE.UTF-8 UTF-8"
 "fr_BE ISO-8859-1"
 "fr_BE@euro ISO-8859-15"
 "fr_CA.UTF-8 UTF-8"
 "fr_CA ISO-8859-1"
 "fr_CH.UTF-8 UTF-8"
 "fr_CH ISO-8859-1"
 "fr_FR.UTF-8 UTF-8"
 "fr_FR ISO-8859-1"
 "fr_FR@euro ISO-8859-15"
 "fr_LU.UTF-8 UTF-8"
 "fr_LU ISO-8859-1"
 "fr_LU@euro ISO-8859-15"
 "fur_IT UTF-8"
 "fy_NL UTF-8"
 "fy_DE UTF-8"
 "ga_IE.UTF-8 UTF-8"
 "ga_IE ISO-8859-1"
 "ga_IE@euro ISO-8859-15"
 "gd_GB.UTF-8 UTF-8"
 "gd_GB ISO-8859-15"
 "gez_ER UTF-8"
 "gez_ER@abegede UTF-8"
 "gez_ET UTF-8"
 "gez_ET@abegede UTF-8"
 "gl_ES.UTF-8 UTF-8"
 "gl_ES ISO-8859-1"
 "gl_ES@euro ISO-8859-15"
 "gu_IN UTF-8"
 "gv_GB.UTF-8 UTF-8"
 "gv_GB ISO-8859-1"
 "ha_NG UTF-8"
 "he_IL.UTF-8 UTF-8"
 "he_IL ISO-8859-8"
 "hi_IN UTF-8"
 "hne_IN UTF-8"
 "hr_HR.UTF-8 UTF-8"
 "hr_HR ISO-8859-2"
 "hsb_DE ISO-8859-2"
 "hsb_DE.UTF-8 UTF-8"
 "ht_HT UTF-8"
 "hu_HU.UTF-8 UTF-8"
 "hu_HU ISO-8859-2"
 "hy_AM UTF-8"
 "hy_AM.ARMSCII-8 ARMSCII-8"
 "ia_FR UTF-8"
 "id_ID.UTF-8 UTF-8"
 "id_ID ISO-8859-1"
 "ig_NG UTF-8"
 "ik_CA UTF-8"
 "is_IS.UTF-8 UTF-8"
 "is_IS ISO-8859-1"
 "it_CH.UTF-8 UTF-8"
 "it_CH ISO-8859-1"
 "it_IT.UTF-8 UTF-8"
 "it_IT ISO-8859-1"
 "it_IT@euro ISO-8859-15"
 "iu_CA UTF-8"
 "iw_IL.UTF-8 UTF-8"
 "iw_IL ISO-8859-8"
 "ja_JP.EUC-JP EUC-JP"
 "ja_JP.UTF-8 UTF-8"
 "ka_GE.UTF-8 UTF-8"
 "ka_GE GEORGIAN-PS"
 "kk_KZ.UTF-8 UTF-8"
 "kk_KZ PT154"
 "kl_GL.UTF-8 UTF-8"
 "kl_GL ISO-8859-1"
 "km_KH UTF-8"
 "kn_IN UTF-8"
 "ko_KR.EUC-KR EUC-KR"
 "ko_KR.UTF-8 UTF-8"
 "kok_IN UTF-8"
 "ks_IN UTF-8"
 "ks_IN@devanagari UTF-8"
 "ku_TR.UTF-8 UTF-8"
 "ku_TR ISO-8859-9"
 "kw_GB.UTF-8 UTF-8"
 "kw_GB ISO-8859-1"
 "ky_KG UTF-8"
 "lb_LU UTF-8"
 "lg_UG.UTF-8 UTF-8"
 "lg_UG ISO-8859-10"
 "li_BE UTF-8"
 "li_NL UTF-8"
 "lij_IT UTF-8"
 "lo_LA UTF-8"
 "lt_LT.UTF-8 UTF-8"
 "lt_LT ISO-8859-13"
 "lv_LV.UTF-8 UTF-8"
 "lv_LV ISO-8859-13"
 "mag_IN UTF-8"
 "mai_IN UTF-8"
 "mg_MG.UTF-8 UTF-8"
 "mg_MG ISO-8859-15"
 "mhr_RU UTF-8"
 "mi_NZ.UTF-8 UTF-8"
 "mi_NZ ISO-8859-13"
 "mk_MK.UTF-8 UTF-8"
 "mk_MK ISO-8859-5"
 "ml_IN UTF-8"
 "mn_MN UTF-8"
 "mni_IN UTF-8"
 "mr_IN UTF-8"
 "ms_MY.UTF-8 UTF-8"
 "ms_MY ISO-8859-1"
 "mt_MT.UTF-8 UTF-8"
 "mt_MT ISO-8859-3"
 "my_MM UTF-8"
 "nan_TW@latin UTF-8"
 "nb_NO.UTF-8 UTF-8"
 "nb_NO ISO-8859-1"
 "nds_DE UTF-8"
 "nds_NL UTF-8"
 "ne_NP UTF-8"
 "nhn_MX UTF-8"
 "niu_NU UTF-8"
 "niu_NZ UTF-8"
 "nl_AW UTF-8"
 "nl_BE.UTF-8 UTF-8"
 "nl_BE ISO-8859-1"
 "nl_BE@euro ISO-8859-15"
 "nl_NL.UTF-8 UTF-8"
 "nl_NL ISO-8859-1"
 "nl_NL@euro ISO-8859-15"
 "nn_NO.UTF-8 UTF-8"
 "nn_NO ISO-8859-1"
 "nr_ZA UTF-8"
 "nso_ZA UTF-8"
 "oc_FR.UTF-8 UTF-8"
 "oc_FR ISO-8859-1"
 "om_ET UTF-8"
 "om_KE.UTF-8 UTF-8"
 "om_KE ISO-8859-1"
 "or_IN UTF-8"
 "os_RU UTF-8"
 "pa_IN UTF-8"
 "pa_PK UTF-8"
 "pap_AN UTF-8"
 "pl_PL.UTF-8 UTF-8"
 "pl_PL ISO-8859-2"
 "ps_AF UTF-8"
 "pt_BR.UTF-8 UTF-8"
 "pt_BR ISO-8859-1"
 "pt_PT.UTF-8 UTF-8"
 "pt_PT ISO-8859-1"
 "pt_PT@euro ISO-8859-15"
 "ro_RO.UTF-8 UTF-8"
 "ro_RO ISO-8859-2"
 "ru_RU.KOI8-R KOI8-R"
 "ru_RU.UTF-8 UTF-8"
 "ru_RU ISO-8859-5"
 "ru_UA.UTF-8 UTF-8"
 "ru_UA KOI8-U"
 "rw_RW UTF-8"
 "sa_IN UTF-8"
 "sat_IN UTF-8"
 "sc_IT UTF-8"
 "sd_IN UTF-8"
 "sd_IN@devanagari UTF-8"
 "se_NO UTF-8"
 "shs_CA UTF-8"
 "si_LK UTF-8"
 "sid_ET UTF-8"
 "sk_SK.UTF-8 UTF-8"
 "sk_SK ISO-8859-2"
 "sl_SI.UTF-8 UTF-8"
 "sl_SI ISO-8859-2"
 "so_DJ.UTF-8 UTF-8"
 "so_DJ ISO-8859-1"
 "so_ET UTF-8"
 "so_KE.UTF-8 UTF-8"
 "so_KE ISO-8859-1"
 "so_SO.UTF-8 UTF-8"
 "so_SO ISO-8859-1"
 "sq_AL.UTF-8 UTF-8"
 "sq_AL ISO-8859-1"
 "sq_MK UTF-8"
 "sr_ME UTF-8"
 "sr_RS UTF-8"
 "sr_RS@latin UTF-8"
 "ss_ZA UTF-8"
 "st_ZA.UTF-8 UTF-8"
 "st_ZA ISO-8859-1"
 "sv_FI.UTF-8 UTF-8"
 "sv_FI ISO-8859-1"
 "sv_FI@euro ISO-8859-15"
 "sv_SE.UTF-8 UTF-8"
 "sv_SE ISO-8859-1"
 "sw_KE UTF-8"
 "sw_TZ UTF-8"
 "szl_PL UTF-8"
 "ta_IN UTF-8"
 "ta_LK UTF-8"
 "te_IN UTF-8"
 "tg_TJ.UTF-8 UTF-8"
 "tg_TJ KOI8-T"
 "th_TH.UTF-8 UTF-8"
 "th_TH TIS-620"
 "ti_ER UTF-8"
 "ti_ET UTF-8"
 "tig_ER UTF-8"
 "tk_TM UTF-8"
 "tl_PH.UTF-8 UTF-8"
 "tl_PH ISO-8859-1"
 "tn_ZA UTF-8"
 "tr_CY.UTF-8 UTF-8"
 "tr_CY ISO-8859-9"
 "tr_TR.UTF-8 UTF-8"
 "tr_TR ISO-8859-9"
 "ts_ZA UTF-8"
 "tt_RU UTF-8"
 "tt_RU@iqtelif UTF-8"
 "ug_CN UTF-8"
 "uk_UA.UTF-8 UTF-8"
 "uk_UA KOI8-U"
 "unm_US UTF-8"
 "ur_IN UTF-8"
 "ur_PK UTF-8"
 "uz_UZ ISO-8859-1"
 "uz_UZ@cyrillic UTF-8"
 "ve_ZA UTF-8"
 "vi_VN UTF-8"
 "wa_BE ISO-8859-1"
 "wa_BE@euro ISO-8859-15"
 "wa_BE.UTF-8 UTF-8"
 "wae_CH UTF-8"
 "wal_ET UTF-8"
 "wo_SN UTF-8"
 "xh_ZA.UTF-8 UTF-8"
 "xh_ZA ISO-8859-1"
 "yi_US.UTF-8 UTF-8"
 "yi_US CP1255"
 "yo_NG UTF-8"
 "yue_HK UTF-8"
 "zh_CN.GB18030 GB18030"
 "​#zh_CN.GBK GBK"
 "​#zh_CN.UTF-8 UTF-8"
 "zh_CN GB2312"
 "zh_HK.UTF-8 UTF-8"
 "zh_HK BIG5-HKSCS"
 "zh_SG.UTF-8 UTF-8"
 "zh_SG.GBK GBK"
 "zh_SG GB2312"
 "zh_TW.EUC-TW EUC-TW"
 "zh_TW.UTF-8 UTF-8"
 "zh_TW BIG5"
 "zu_ZA.UTF-8 UTF-8"
 "zu_ZA ISO-8859-1"
)

# $* log data
log(){
	if [[ ${VERBOSE} -eq 1 ]]; then
		echo -e $*
	fi
}
split_by_pipe(){
	declare -a myarr=(`echo $1 |sed 's/|/ /g'`)
	echo ${myarr[*]}
}

generate_locales_file(){
	echo "# Configuration file for locale-gen" >> ${1}
	echo "#" >> ${1}
	echo "# lists of locales that are to be generated by the locale-gen command." >> ${1}
	echo "#" >> ${1}
	echo "# Each line is of the form:" >> ${1}
	echo "#" >> ${1}
	echo "#     <locale> <charset>" >> ${1}
	echo "#" >> ${1}
	echo "#  where <locale> is one of the locales given in /usr/share/i18n/locales" >> ${1}
	echo "#  and <charset> is one of the character sets listed in /usr/share/i18n/charmaps" >> ${1}
	echo "#" >> ${1}
	echo "#  Examples:" >> ${1}
	echo "#  en_US ISO-8859-1" >> ${1}
	echo "#  en_US.UTF-8 UTF-8" >> ${1}
	echo "#  de_DE ISO-8859-1" >> ${1}
	echo "#  de_DE@euro ISO-8859-15" >> ${1}
	echo "#" >> ${1}
	echo "#  The locale-gen command will generate all the locales," >> ${1}
	echo "#  placing them in /usr/lib/locale." >> ${1}
	echo "#" >> ${1}
	echo "#  A list of supported locales is included in this file." >> ${1}
	echo "#  Uncomment the ones you need." >> ${1}
	echo "#" >> ${1}

	for (( i=0; i<${#LOCALES_ARRAY[@]}; i++ ));
	do
		if [ "${LOCALES_ARRAY[$i]}" == "${LOCALE}" ] ; then
			echo ${LOCALES_ARRAY[$i]} >> ${1}
		else
			echo "#"${LOCALES_ARRAY[$i]} >> ${1}
    	fi
	done
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
		printusage
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
	rm ${MOUNTPOINT}/etc/local.gen
	generate_locales_file ${MOUNTPOINT}/etc/local.gen
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
