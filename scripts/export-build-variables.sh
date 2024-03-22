#!/usr/bin/env bash

function max() {
  [ $1 -ge $2 ] && echo "$1" || echo "$2"
}

export ANDROID_ABI=$1

if [ $ANDROID_ABI = "arm64-v8a" ] || [ $ANDROID_ABI = "x86_64" ] ; then
  # For 64bit we use value not less than 21
  export ANDROID_PLATFORM=$(max ${DESIRED_ANDROID_API_LEVEL} 21)
else
  export ANDROID_PLATFORM=${DESIRED_ANDROID_API_LEVEL}
fi

export TOOLCHAIN_PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}
export SYSROOT_PATH=${TOOLCHAIN_PATH}/sysroot

TARGET_TRIPLE_MACHINE_CC=
CPU_FAMILY=
export TARGET_TRIPLE_OS="android"

case $ANDROID_ABI in
  armeabi-v7a)
    #cc       armv7a-linux-androideabi16-clang
    export TARGET_TRIPLE_MACHINE_ARCH=arm
    TARGET_TRIPLE_MACHINE_CC=armv7a
    export TARGET_TRIPLE_OS=androideabi
    ;;
  arm64-v8a)
    #cc       aarch64-linux-android21-clang
    export TARGET_TRIPLE_MACHINE_ARCH=aarch64
    ;;
  x86)
    #cc       i686-linux-android16-clang
    export TARGET_TRIPLE_MACHINE_ARCH=i686
    CPU_FAMILY=x86
    ;;
  x86_64)
    #cc       x86_64-linux-android21-clang
    export TARGET_TRIPLE_MACHINE_ARCH=x86_64
    ;;
esac

# If the cc-specific variable isn't set, we fallback to binutils version
[ -z "${TARGET_TRIPLE_MACHINE_CC}" ] && TARGET_TRIPLE_MACHINE_CC=${TARGET_TRIPLE_MACHINE_ARCH}

[ -z "${CPU_FAMILY}" ] && CPU_FAMILY=${TARGET_TRIPLE_MACHINE_ARCH}
export CPU_FAMILY=$CPU_FAMILY

# Common prefix for ld, as, etc.
export CROSS_PREFIX_WITH_PATH=${TOOLCHAIN_PATH}/bin/llvm-

# Exporting Binutils paths, if passing just CROSS_PREFIX_WITH_PATH is not enough
# The FAM_ prefix is used to eliminate passing those values implicitly to build systems
export FAM_ADDR2LINE=${CROSS_PREFIX_WITH_PATH}addr2line
export        FAM_AR=${CROSS_PREFIX_WITH_PATH}ar
export        FAM_AS=${CROSS_PREFIX_WITH_PATH}as
export        FAM_NM=${CROSS_PREFIX_WITH_PATH}nm
export   FAM_OBJCOPY=${CROSS_PREFIX_WITH_PATH}objcopy
export   FAM_OBJDUMP=${CROSS_PREFIX_WITH_PATH}objdump
export    FAM_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
export   FAM_READELF=${CROSS_PREFIX_WITH_PATH}readelf
export      FAM_SIZE=${CROSS_PREFIX_WITH_PATH}size
export   FAM_STRINGS=${CROSS_PREFIX_WITH_PATH}strings
export     FAM_STRIP=${CROSS_PREFIX_WITH_PATH}strip

export TARGET=${TARGET_TRIPLE_MACHINE_CC}-linux-${TARGET_TRIPLE_OS}${ANDROID_PLATFORM}
# The name for compiler is slightly different, so it is defined separately.
export FAM_CC=${TOOLCHAIN_PATH}/bin/${TARGET}-clang
export FAM_CXX=${FAM_CC}++
export FAM_LD=${FAM_CC}

# TODO consider abondaning this strategy of defining the name of the clang wrapper
# in favour of just passing -mstackrealign and -fno-addrsig depending on
# ANDROID_ABI, ANDROID_PLATFORM and NDK's version

# Special variable for the yasm assembler
export FAM_YASM=${TOOLCHAIN_PATH}/bin/yasm

# A variable to which certain dependencies can add -l arguments during build.sh
export FFMPEG_EXTRA_LD_FLAGS=


FFMPEG_CONFIGURE_FLAGS=(
    --enable-pic

    --disable-doc
    --disable-debug
    --disable-avdevice
    --disable-swscale
    --disable-programs
    --enable-rdft
    --enable-ffmpeg
    --enable-ffprobe
    --disable-network
    --disable-muxers
    --disable-demuxers
    --disable-zlib
    --disable-bzlib
    --disable-iconv
    --disable-bsfs
    --disable-filters
    --disable-parsers
    --disable-indevs
    --disable-outdevs
    --disable-encoders
    --disable-decoders
    --disable-hwaccels
    --disable-nvenc
    --disable-videotoolbox
    --disable-audiotoolbox

    --disable-filters
    --enable-filter=aformat
    --enable-filter=anull
    --enable-filter=atrim
    --enable-filter=format
    --enable-filter=null
    --enable-filter=setpts
    --enable-filter=trim

    --disable-protocols
    --enable-protocol=file
    --enable-protocol=pipe

    --enable-demuxer=image2
    --enable-demuxer=aac
    --enable-demuxer=ac3
    --enable-demuxer=aiff
    --enable-demuxer=ape
    --enable-demuxer=asf
    --enable-demuxer=au
    --enable-demuxer=avi
    --enable-demuxer=flac
    --enable-demuxer=flv
    --enable-demuxer=matroska
    --enable-demuxer=mov
    --enable-demuxer=m4v
    --enable-demuxer=mp3
    --enable-demuxer=mpc
    --enable-demuxer=mpc8
    --enable-demuxer=ogg
    --enable-demuxer=pcm_alaw
    --enable-demuxer=pcm_mulaw
    --enable-demuxer=pcm_f64be
    --enable-demuxer=pcm_f64le
    --enable-demuxer=pcm_f32be
    --enable-demuxer=pcm_f32le
    --enable-demuxer=pcm_s32be
    --enable-demuxer=pcm_s32le
    --enable-demuxer=pcm_s24be
    --enable-demuxer=pcm_s24le
    --enable-demuxer=pcm_s16be
    --enable-demuxer=pcm_s16le
    --enable-demuxer=pcm_s8
    --enable-demuxer=pcm_u32be
    --enable-demuxer=pcm_u32le
    --enable-demuxer=pcm_u24be
    --enable-demuxer=pcm_u24le
    --enable-demuxer=pcm_u16be
    --enable-demuxer=pcm_u16le
    --enable-demuxer=pcm_u8
    --enable-demuxer=rm
    --enable-demuxer=shorten
    --enable-demuxer=tak
    --enable-demuxer=tta
    --enable-demuxer=wav
    --enable-demuxer=wv
    --enable-demuxer=xwma
    --enable-demuxer=dsf

    --enable-decoder=aac
    --enable-decoder=aac_latm
    --enable-decoder=ac3
    --enable-decoder=alac
    --enable-decoder=als
    --enable-decoder=ape
    --enable-decoder=atrac1
    --enable-decoder=atrac3
    --enable-decoder=eac3
    --enable-decoder=flac
    --enable-decoder=gsm
    --enable-decoder=gsm_ms
    --enable-decoder=mp1
    --enable-decoder=mp1float
    --enable-decoder=mp2
    --enable-decoder=mp2float
    --enable-decoder=mp3
    --enable-decoder=mp3adu
    --enable-decoder=mp3adufloat
    --enable-decoder=mp3float
    --enable-decoder=mp3on4
    --enable-decoder=mp3on4float
    --enable-decoder=mpc7
    --enable-decoder=mpc8
    --enable-decoder=opus
    --enable-decoder=ra_144
    --enable-decoder=ra_288
    --enable-decoder=ralf
    --enable-decoder=shorten
    --enable-decoder=tak
    --enable-decoder=tta
    --enable-decoder=vorbis
    --enable-decoder=wavpack
    --enable-decoder=wmalossless
    --enable-decoder=wmapro
    --enable-decoder=wmav1
    --enable-decoder=wmav2
    --enable-decoder=wmavoice

    --enable-decoder=pcm_alaw
    --enable-decoder=pcm_bluray
    --enable-decoder=pcm_dvd
    --enable-decoder=pcm_f32be
    --enable-decoder=pcm_f32le
    --enable-decoder=pcm_f64be
    --enable-decoder=pcm_f64le
    --enable-decoder=pcm_lxf
    --enable-decoder=pcm_mulaw
    --enable-decoder=pcm_s8
    --enable-decoder=pcm_s8_planar
    --enable-decoder=pcm_s16be
    --enable-decoder=pcm_s16be_planar
    --enable-decoder=pcm_s16le
    --enable-decoder=pcm_s16le_planar
    --enable-decoder=pcm_s24be
    --enable-decoder=pcm_s24daud
    --enable-decoder=pcm_s24le
    --enable-decoder=pcm_s24le_planar
    --enable-decoder=pcm_s32be
    --enable-decoder=pcm_s32le
    --enable-decoder=pcm_s32le_planar
    --enable-decoder=pcm_u8
    --enable-decoder=pcm_u16be
    --enable-decoder=pcm_u16le
    --enable-decoder=pcm_u24be
    --enable-decoder=pcm_u24le
    --enable-decoder=pcm_u32be
    --enable-decoder=pcm_u32le
    --enable-decoder=pcm_zork
    --enable-decoder=dsd_lsbf
    --enable-decoder=dsd_msbf
    --enable-decoder=dsd_lsbf_planar
    --enable-decoder=dsd_msbf_planar

    --enable-parser=aac
    --enable-parser=aac_latm
    --enable-parser=ac3
    --enable-parser=cook
    --enable-parser=dca
    --enable-parser=flac
    --enable-parser=gsm
    --enable-parser=mpegaudio
    --enable-parser=tak
    --enable-parser=vorbis
)

# A variable to which certain dependencies can add addtional arguments during ffmpeg build.sh
export EXTRA_BUILD_CONFIGURATION_FLAGS=${FFMPEG_CONFIGURE_FLAGS[@]}

export INSTALL_DIR=${BUILD_DIR_EXTERNAL}/${ANDROID_ABI}

# Forcing FFmpeg and its dependencies to look for dependencies
# in a specific directory when pkg-config is used
export PKG_CONFIG_LIBDIR=${INSTALL_DIR}/lib/pkgconfig
