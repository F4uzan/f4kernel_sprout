# F4Kernel Custom Build Script
# Created by F4uzan <derpish123@gmail.com>
# Based on 'Custom build script' by Varun Chitre 'varun.chitre15' <varun.chitre15@gmail.com>
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it
#

# Folder variables
KERNEL_DIR=$PWD
ZIMAGE_DIR=$KERNEL_DIR/arch/arm/boot/
E_ZIMAGE=$KERNEL_DIR/arch/arm/boot/zImage
ZIP_DIR=$KERNEL_DIR/arch/arm/boot/zipfile
BUILD_START=$(date +"%s")

# Color variables
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

# Cross compiler path
export CROSS_COMPILE="/home/f4uzan/Android/Toolchain/Linaro-Cortex/bin/arm-cortex_a7-linux-gnueabihf-"

# Do NOT change this, unless you're building for other platform
export ARCH=arm
export SUBARCH=arm

# Kernel user and host build
export KBUILD_BUILD_USER="f4uzan"
export KBUILD_BUILD_HOST="OptimaTeam"

# Zipfile naming
KERNEL_NAME=F4Kernel
DEVICE_NAME=sprout
ZIP_NAME=$KERNEL_NAME-$DEVICE_NAME.zip

# Default defconfig
export DEFCONFIG=f4kernel_sprout_defconfig

# Automatically count job numbers by processor cores
#	0 : Disabled
#	1 : Enabled
export JOB_BY_PROC=0;

# Job numbers script should use if JOB_BY_PROC is disabled
export JOB_NUMBERS=8

compile_kernel ()
{
echo -e "$cyan--------------------------"
echo "Compiling $KERNEL_NAME "
echo -e "--------------------------$nocol"
if [ -e $KERNEL_DIR/arch/arm/boot/zImage.bak ];
	then
	rm $KERNEL_DIR/arch/arm/boot/zImage.bak
fi
if [ -e $E_ZIMAGE ];
	then
	mv $E_ZIMAGE $KERNEL_DIR/arch/arm/boot/zImage.bak
fi
make $DEFCONFIG
if [ $JOB_BY_PROC -eq 1 ];
	then
	make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@"
else
	make -j $JOB_NUMBERS
fi
if ! [ -a $E_ZIMAGE ];
	then
	echo -e "$red E: Kernel compilation failed $nocol"
	exit 1
fi
}

case $1 in
clean)
make -j `cat /proc/cpuinfo | grep "^processor" | wc -l` "$@" clean mrproper
rm -rf include/linux/autoconf.h
;;
*)
compile_kernel
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
if ! [ -e $E_ZIMAGE ];
	then
	echo -e "$red E: Module compilation failed $nocol"
fi	
cp $E_ZIMAGE $ZIP_DIR/tools
cd $ZIP_DIR
if [ -e *.zip ];
	then
	rm -f *.zip
fi
zip -r $ZIP_NAME * > /dev/null
echo -e "$cyan I: Output created at $ZIP_DIR/$ZIP_NAME $nocol"
echo -e "$yellow I: Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"