#!/bin/bash

###########################################################################
# Author: Avtar Singh, s.avtar@gmail.com
# Last updated:
#	05-Sept-2016	1.0 Release
# Modified by CnG
#
# 1.
# Gets only code specific to Dalvik project and its dependencies from
# the git repositories of the complete Android project.
#
# 2.
# Builds the code, patching if necessary
#
#
###########################################################################


###########################################################################
# Paths
GIT_ANDROID_ROOT=https://android.googlesource.com/platform/
branch=gingerbread-mr4-release
#echo $GIT_ANDROID_ROOT
Android=https://github.com/CyanogenMod/
xbranch=gb-release-7.2
#echo $Android

# Names of projects used by the Dalvik build
# Do NOT change the order below; even though the order below has no effect
# on final make; remove dependencies further one by one starting from the bottom
X86="\
	android_bionic\;bionic\
	android_build\;build\
	android_prebuilt\
"
# From android repository
PROJECTS="\
	dalvik\
	development\
	external/apache-http\;external/apache-http\
	external/nist-sip\;external/nist-sip\
	external/tagsoup\;external/tagsoup\
	external/xmlwriter\;external/xmlwriter\
	external/safe-iop\;external/safe-iop\
	external/expat\;external/expat\
	external/libpng\;external/libpng\
	external/zlib\;external/zlib\
	external/elfutils\;external/elfutils\
	external/elfcopy\;external/elfcopy\
	external/openssl\;external/openssl\
	external/icu4c\;external/icu4c\
	external/sqlite\;external/sqlite\
	external/svox\;external/svox\
	external/fdlibm\;external/fdlibm\
	frameworks_base\;frameworks/base\
	libcore\
	system/core\;system/core\
	systemextras\;system/extras\
"
# Additional projects to support x86 compilation
PROJECTS+="\
	external/grub\;external/grub\
	external/genext2fs\;external/genext2fs\
	external/e2fsprogs\;external/e2fsprogs\
	bootable/diskinstaller\;bootable/diskinstaller\
"
#echo $PROJECTS

CORE_MAKEFILE=build/core/root.mk
#echo $CORE_MAKEFILE

VENDOR=idvk

###########################################################################
# Build code for x86
function dalvik-buildx86() {
	#ensure that product makefiles and other configuration files are present
	copy-product-files-x86

	. build/envsetup.sh

	# set up environment variables for x86 target
	export TARGET_ARCH=x86
	export TARGET_PRODUCT=$PRODUCT
	export DISABLE_DEXPREOPT=true

	# run android environment setup, change directory and do a make
	cd dalvik
	mm
	if (( $? )) ; then
		echo "Build error: Stopping here."
		exit
	fi

	# go back to main directory
	cd ..

	# patch files related to installer
	patch-installer-files-x86

	# build sample test program
	javac dvkpatch/samples/BasicTest.java
	out/host/linux-x86/bin/dx --dex --output=dvkpatch/samples/BasicTest.jar dvkpatch/samples/BasicTest.class
	if (( $? )) ; then
		echo "Could not build sample program correctly"
		exit
	else
		# put the sample program in output directory
		cp -av dvkpatch/samples/BasicTest.jar out/target/product/$PRODUCT/system/framework
	fi
	
	# create the installer image
	cd dalvik
	mm installer_img
}

###########################################################################
# Clean build for x86
function dalvik-cleanx86() {
	# set up environment variables for x86 target
	export TARGET_ARCH=x86
	export TARGET_PRODUCT=$PRODUCT
	export DISABLE_DEXPREOPT=true

	make clean
}

###########################################################################
# Patch installer related files for x86gen
function patch-installer-files-x86() {

# patch external/e2fsprogs/Android.mk so that it compiles everything in e2fsprogs
	
	# backup before patching, don't overwrite original file
	if [ ! -e external/e2fsprogs/Android.mk.orig ] ; then		
		cp -av external/e2fsprogs/Android.mk external/e2fsprogs/Android.mk.orig
	fi
	#not much of a hack
	sed s/#// <external/e2fsprogs/Android.mk.orig >external/e2fsprogs/Android.mk
}

###########################################################################
# Copy product files for x86gen
function copy-product-files-x86() {

	# create directory for our product and board files, if not already existing
	if [ ! -e vendor/$VENDOR/$PRODUCT ] ; then
		mkdir -p vendor/$VENDOR/$PRODUCT
		tar -xvf dvkpatch/$PRODUCT.tar
	fi
}

###########################################################################
# Get code
function dalvik-get() {
	for x86 in $X86
	do
	    unset command x
		x=`expr index "$x86" \;`	#; echo $x
		if ((x)) ; then
			command="git clone $Android${x86/\\;/.git } -b $xbranch"
			project=`expr substr $x86 1 $((i - 2))` #; echo $x86
		else
			command="git clone $Android${x86}.git -b $xbranch"
		fi
		
		if [ -d $x86 ] ; then
			echo "Folder \"$x86\" already exists. Skipping."
		else
			$command
			if (( $? )) ; then
				echo "Get error: git command failure"
				exit
			fi
		fi
	done
	for project in $PROJECTS
	do
		unset command i
		i=`expr index "$project" \;`	#; echo $i
		if ((i)) ; then
			command="git clone $GIT_ANDROID_ROOT${project/\\;/.git } -b $branch"
			project=`expr substr $project 1 $((i - 2))` #; echo $project
		else
			command="git clone $GIT_ANDROID_ROOT${project}.git -b $branch"
		fi
		
		if [ -d $project ] ; then
			echo "Folder \"$project\" already exists. Skipping."
		else
			$command
			if (( $? )) ; then
				echo "Get error: git command failure"
				exit
			fi
		fi
	done

	if [ -e $CORE_MAKEFILE ] ; then
		# copy makefile to "root"
		cp -av $CORE_MAKEFILE ./Makefile
	else
		echo "Get error: Unable to locate core makefile"		
	fi
	
	# patch the main make file
	if [ -e dvkpatch/build-core.main.mk ] ; then
		# backup before patching, don't overwrite original file
		if [ ! -e build/core/main.mk.orig ] ; then		
			cp -av build/core/main.mk build/core/main.mk.orig
		fi
		cp -av dvkpatch/build-core.main.mk build/core/main.mk
	else
		echo "Get error: Unable to locate patch file build-core.main.mk"		
	fi
}

###########################################################################
# Help
function dalvik-help() {
	echo -n -e "\n \
Create a \"root\" directory under which you want to keep all code and\n \
invoke the script again with the following arguments:\n \
\t\tidvk <command> [architecture]\n\n \
\tCommands:\n \
\t---------\n \
\tget\t\t: to get Dalvik and related code from GIT repositories\n \
\tbuild\t\t: build code for the specified architecture\n \
\tclean\t\t: clean build for the specified architecture\n\n \
\tArchitecture:\n \
\t-------------\n \
\tx86\t\t: for x86 generic\n"
}

###########################################################################
# Main
if [ $# -eq 1 ] && [ $1_ = get_ ]; then
	dalvik-get
elif [ $# -eq 2 ] && [ $1_ = get_ ]; then
	dalvik-get
elif [ $# -eq 2 ] && [ $1_ = build_ ]; then
	if [ $2_ = x86_ ]; then
		PRODUCT=x86gen	#; echo $PRODUCT
		dalvik-buildx86
	else
		echo "Unsupported architecture! Try using \"x86\"."
	fi
elif [ $# -eq 2 ] && [ $1_ = clean_ ]; then
	if [ $2_ = x86_ ]; then
		PRODUCT=x86gen
		dalvik-cleanx86
	else
		echo "Unsupported architecture! Try using \"x86\"."
	fi
else
	dalvik-help
fi

# get dvk specific product and board files into appropriate directory
# vendor/idvk/x86gen

unset GIT_ANDROID_ROOT PROJECTS
unset Android X86

exit

