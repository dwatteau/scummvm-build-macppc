#! /bin/sh

FLAC_VERSION=1.3.4 # XXX: maybe time to update to 1.4?
#FLAC_SHA256=213e82bd716c9de6db2f98bcadbc4c24c7e2efe8c75939a1a84e28539c4e1748

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch flac "http://downloads.xiph.org/releases/flac/flac-${FLAC_VERSION}.tar.xz" \
        'tar --use-compress-program=/opt/local/bin/xz -xf' #"sha256:${FLAC_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

# If building with one of the base compilers
#HAVE_BSWAP16=0 HAVE_BSWAP32=0 \
#ac_cv_c_bswap16=no ac_cv_c_bswap32=no \

# stack protection will cause undefined symbols when linking against FLAC for 10.4
CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure \
--disable-altivec --disable-vsx --disable-sse --disable-avx \
--disable-stack-smash-protection --disable-rpath \
--disable-thorough-tests --disable-doxygen-docs --disable-xmms-plugin --disable-cpplibs --disable-ogg

# We don't want any Altivec code, because the one that's left is meant for POWER8/9,
# not PowerPC. There used to have Altivec code for G4/G5s, but is was dropped in
# FLAC 1.3.1 (2014, not mentionned in its changelog), citing "old/broken" code.
sed -i'.orig' -e 's/-faltivec//g' src/libFLAC/Makefile

do_make -C src/libFLAC V=1

do_make -C src/libFLAC install
# No need to build includes
do_make -C include install

do_clean_bdir
