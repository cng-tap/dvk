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
# Build source
function source-build() {

	. build/envsetup.sh

	lunch x86-eng
	
	make pm
	make libjavacore
	make libjavacore-host

	cd dalvik 
	. ../build/envsetup.sh
	lunch x86-eng

	mm iso_img
}

###########################################################################
# Copy source files for x86gen
function source-extract(){
		tar -xvf dvkpatch/x86gen.tar
}

###########################################################################
# Main
if [ $# -eq 1 ] && [ $1_ = extract_ ]; then
	source-extract
	if [ $2_ = extact_ ]; then
		source-extract
	fi
else
	source-build
fi

exit
