#! /bin/sh

LIBTHEORA_VERSION=1.1.1
LIBTHEORA_SHA256=b6ae1ee2fa3d42ac489287d3ec34c5885730b1296f0801ae577a35193d3affbc

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libtheora "http://downloads.xiph.org/releases/theora/libtheora-${LIBTHEORA_VERSION}.tar.bz2" \
	'tar xjf' #"sha256:${LIBTHEORA_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

sed -i'.orig' -e 's/-O3 -fforce-addr -fomit-frame-pointer -finline-functions -funroll-loops//g' configure

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
SDL_CONFIG=/usr/bin/false \
HAVE_DOXYGEN=/usr/bin/false \
do_configure \
	--disable-oggtest \
	--disable-vorbistest \
	--disable-sdltest \
	--disable-examples \
	--disable-spec \
	--disable-encode \
	--with-ogg=$PREFIX \
	--with-vorbis=$PREFIX

# Avoid compiling and installing doc
sed -i'.orig' -e 's/^\(SUBDIRS.*\) doc/\1/' Makefile

do_make
do_make install

do_clean_bdir
