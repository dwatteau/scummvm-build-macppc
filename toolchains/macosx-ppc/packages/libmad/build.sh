#! /bin/sh

LIBMAD_VERSION=0.15.1b
LIBMAD_SHA256=bbfac3ed6bfbc2823d3775ebb931087371e142bb0e9bb1bee51a76a6e0078690

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libmad "https://download.sourceforge.net/project/mad/libmad/${LIBMAD_VERSION}/libmad-${LIBMAD_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${LIBMAD_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure --enable-fpm=ppc

do_make
do_make install

do_clean_bdir
