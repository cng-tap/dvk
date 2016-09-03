
$(warning Avtar>> Using ONE_SHOT_MAKEFILE)
$(warning Avtar>> Value $(ONE_SHOT_MAKEFILE))

$(warning Avtar>> Including additional makefiles...)
include build/tools/acp/Android.mk
include build/libs/host/Android.mk
include system/core/liblog/Android.mk
include system/core/libcutils/Android.mk
include frameworks/base/tools/aapt/Android.mk
include frameworks/base/libs/utils/Android.mk
include external/expat/Android.mk
include external/libpng/Android.mk
include bionic/libc/Android.mk
include bionic/libdl/Android.mk

include build/tools/apriori/Android.mk
include external/elfcopy/Android.mk
include external/elfutils/Android.mk

include build/tools/soslim/Android.mk
include bionic/libstdc++/Android.mk
include bionic/libm/Android.mk
include external/openssl/Android.mk
include external/zlib/Android.mk
include external/icu4c/Android.mk

include build/tools/bin2asm/Android.mk

include external/sqlite/dist/Android.mk
include external/sqlite/android/Android.mk
include external/fdlibm/Android.mk

# for x86 only - Avtar
# sh and toolbox form the basic shell and commands
# linker is required at runtime
# rest all are related to installer/bootloader
include external/grub/Android.mk
include external/genext2fs/Android.mk
include system/core/cpio/Android.mk
include bootable/diskinstaller/Android.mk

ifeq ($(TARGET_ARCH), x86)
include vendor/idvk/$(TARGET_PRODUCT)/Android.mk
endif

include system/core/sh/Android.mk
include system/core/toolbox/Android.mk
include system/core/init/Android.mk
include bionic/linker/Android.mk
include external/e2fsprogs/Android.mk

# for dalvik runtime debugging and running - Avtar
include system/core/logcat/Android.mk
$(warning Avtar>> Done)

