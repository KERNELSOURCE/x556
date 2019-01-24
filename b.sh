#!/bin/bash

#
# Copyright (C) 2018 Yuvraj Saxena (frap130)
# Copyright (C) 2018 SaMad SegMane (MrSaMaDo)
# Copyright (C) 2019 Raymond Miracle
#

# Script To Compile Kernels

# Colors
ORNG=$'\033[0;33m'
CYN=$'\033[0;36m'
PURP=$'\033[0;35m'
BLINK_RED=$'\033[05;31m'
BLUE=$'\033[01;34m'
BLD=$'\033[1m'
GRN=$'\033[01;32m'
RED=$'\033[01;31m'
RST=$'\033[0m'
YLW=$'\033[01;33m'

BUILD=y
function BANNER() {
echo "WELCOME LETS START THE BUILDING"
clear
}

function BINFO() {
        echo "### Edit BINFO If u Want to change Host/User. ###"
        export KBUILD_BUILD_USER=Raymond-Miracle
        export KBUILD_BUILD_HOST=OmegaHOST
}

function TOOLCHAIN() {
if [[ ! -d gtc ]]; then 
    echo "${RED}####################################"
    echo "${CYN}#       TOOLCHAIN NOT FOUND!       #"
    echo "${YLW}####################################"
clear
    sudo rm -rf toolchain
    sudo rm -rf linaro
    sudo rm -rf gcc/.git
	echo "${YLW}####################################"
    echo "${GRN}#       CLONING TOOLCHAIN          #"
    echo "${YLW}####################################"
    git clone https://github.com/raymondmiracle/Toolchain /Toolchain
	echo "${ORNG}##############################"
	echo "${BLUE}★★Cloning AnyKernel2 !!!!!!!!"
	echo "${ORNG}##############################"
	git clone https://github.com/Panchajanya1999/AnyKernel2
	echo "${ORNG}##############################"
	echo "${BLUE}★★Cloning AnyKernel2 Done.!!!"
	echo "${ORNG}##############################"
    export CROSS_COMPILE=/Toolchain/bin/aarch64-linux-android-
    export SUBARCH=arm64
else
    export CROSS_COMPILE=$PWD/toolchain/bin/aarch64-linux-android-
    export SUBARCH=arm64
fi
}

function BUILD() {
        mkdir -p out
        echo "${PURP} READING DEFCONFIG..."
        make O=out/ ARCH=arm64 rlk6737m_open_n_defconfig | tee defconfiglog.txt
        echo "${YLW} BUILDING KERNEL..." 
        make -j$(nproc --all) O=out/ ARCH=arm64 | tee kernellog.txt
        OIMAGE=out/arch/arm64/boot/Image.gz-dtb
}
function CHECK() {
rm -rf *.log
rm -rf boot.img-zImage
rm -rf *.zip
if [[ ! -e ${OIMAGE} ]];
then
        echo "${RED}############################"
        echo "${RED}#        BUILD ERROR!      #"
        echo "${RED}############################"
        echo "${CYN}#       Uploading Logs     #"
        echo "${RED}############################"
        TRANSFER kernellog.txt
else
        echo "${GRN} #####################################"
        echo "${GRN} #                                   #"
        echo "${GRN} #    SUCCESSFULLY BUILDED KERNEL    #"
        echo "${GRN} #                                   #"
        echo "${GRN} #####################################"
        mv ${OIMAGE} boot.img-zImage
		cp $PWD/out/arch/arm64/boot/boot.img-zImage AnyKernel2/boot.img-zImage
		cd AnyKernel2
		zip -r9 Omega-Kernel.zip * -x .git README.md
clear
fi
}

function CLEAN() {
clear
        echo "${GRN}#        Cleaning Tree!      ${RST}"
        make clean
        make mrproper
clear
}

function HELP() {
	echo "${ORNG}options:${RST}"
	echo "${CYN}  b, build     Buid Kernel${RST}"
	echo "${RST}  c, clean     clean Kernel${RST}"
	echo "${GRN}  h, Help      Options${RST}"
        read junk
}

function TRANSFER() {
        file="$1"
        zipname=$(echo "${file}" | awk -F '/' '{print $NF}')
        destination="$2"
        url=$(curl -# -T "${file}" https://transfer.sh/${destination})
        printf '\n'
        echo "Download $zipname at $url"
}

function FORMAT_TIME() {
        MINS=$(((${1}-${2})/60))
        SECS=$(((${1}-${2})%60))
if [[ ${MINS} -ge 60 ]]; then
        HOURS=$((${MINS}/60))
        MINS=$((${MINS}%60))
fi

if [[ ${HOURS} -eq 1 ]]; then
        TIME_STRING+="1 HOUR, "
elif [[ ${HOURS} -ge 2 ]]; then
        TIME_STRING+="${HOURS} HOURS, "
fi

if [[ ${MINS} -eq 1 ]]; then
        TIME_STRING+="1 MINUTE"
else
        TIME_STRING+="${MINS} MINUTES"
fi

if [[ ${SECS} -eq 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND 1 SECOND"
elif [[ ${SECS} -eq 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND 1 SECOND"
elif [[ ${SECS} -ne 1 && -n ${HOURS} ]]; then
        TIME_STRING+=", AND ${SECS} SECONDS"
elif [[ ${SECS} -ne 1 && -z ${HOURS} ]]; then
        TIME_STRING+=" AND ${SECS} SECONDS"
fi

        echo ${TIME_STRING}
}

        BANNER

if [[ ${BUILDING_ON_CI} = 'y' ]]; then
        START_SCRIPT "${@}"
else
	START_SCRIPT
fi

if [[ "${BUILD}" = 'y' ]]; then
clear
        START=$(date +"%s")
        TOOLCHAIN
clear
        BINFO
        sleep 0.3
        BUILD
        CHECK
        END=$(date +%s)
        TIME_STRING="$(FORMAT_TIME "${START}" "${END}")"
        echo "${GRN}Completed In: ${TIME_STRING}"
elif [[ "${CLEAN}" = 'y' ]]; then
        CLEAN
else
if [[ "${HELP}" = 'y' ]]; then
clear
        HELP
fi
fi
