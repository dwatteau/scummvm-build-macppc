#! /bin/sh

LIBOGG_VERSION=1.3.5
LIBOGG_SHA256=0eb4b4b9420a0f51db142ba3f9c64b333f826532dc0f48c6410ae51f4799b664

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libogg "http://ftp.oregonstate.edu/.1/xiph/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${LIBOGG_SHA256}"

# Avoid compiling and installing doc
sed -i'.orig' -e 's/^\(SUBDIRS.*\) doc/\1/' Makefile.in

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure

do_make
do_make install

do_clean_bdir
