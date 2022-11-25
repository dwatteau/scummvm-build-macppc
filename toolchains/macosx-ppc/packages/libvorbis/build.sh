#! /bin/sh

LIBVORBIS_VERSION=1.3.7
#LIBVORBIS_SHA256=XXX

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libvorbis "http://ftp.oregonstate.edu/.1/xiph/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${LIBVORBIS_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

sed -i'.orig' -e 's/-g -O3//g' configure

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure \
--disable-docs --disable-examples --with-ogg=${PREFIX}

# Avoid compiling and installing useless stuff
sed -i'.orig' -e 's/^\(SUBDIRS.*\) test doc/\1/' Makefile

do_make V=1
do_make install

do_clean_bdir
