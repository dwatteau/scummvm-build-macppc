#! /bin/sh
# This library only needs to be compiled if you are planning on using a
# precompiled FreeType that expects it to exist. Otherwise, it is used only for
# an obsolete X11 bitmap font format that ScummVM will never use.

# This is also used when ScummVM expects the library to be here (iphone platform)

BZIP2_VERSION=1.0.8
BZIP2_SHA256=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch bzip2 "https://sourceware.org/pub/bzip2/bzip2-${BZIP2_VERSION}.tar.gz" 'tar xzf' #"sha256:${BZIP2_SHA256}"

# Manually build and install only the static library and header

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

# bzip2 Makefile redefines these variables so override them here
sed -i'.orig' -e 's|-O2 -g|-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32|g' Makefile
do_make libbz2.a CC=/opt/macports-tff/bin/gcc-mp-7 #AR=$AR RANLIB=$RANLIB

mkdir -p "$PREFIX/lib"
cp -f libbz2.a "$PREFIX/lib"
chmod a+r "$PREFIX/lib/libbz2.a"
mkdir -p "$PREFIX/include"
cp -f bzlib.h "$PREFIX/include"
chmod a+r "$PREFIX/include/bzlib.h"

do_clean_bdir
