#! /bin/sh

# TODO: look at openmpt for the next major ScummVM release?
# it has SO3 support (for sludge) engine.
LIBMIKMOD_VERSION=3.3.13
#LIBMIKMOD_SHA256=XXX

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch libmikmod "https://download.sourceforge.net/project/mikmod/libmikmod/${LIBMIKMOD_VERSION}/libmikmod-${LIBMIKMOD_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${LIBMIKMOD_SHA256}"

# TODO: disable more audio drivers?
# SIMD is marked unstable and is probably not worth it for our usage
CC="$CC" \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure \
--disable-doc \
--disable-alldrv \
--disable-threads \
--disable-dl \
--disable-simd

do_make
do_make install

do_clean_bdir
