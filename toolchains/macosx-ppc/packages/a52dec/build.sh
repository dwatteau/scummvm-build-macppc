#! /bin/sh

# use a newer snapshot with fixes; from OpenBSD
A52DEC_VERSION=0.7.5-cvs
A52DEC_SHA256=XXX

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch a52dec "https://comstyle.com/source/a52dec-snapshot.tar.gz" \
	'tar xzf' #"sha256:${LIBMAD_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

sed -i'.orig' \
-e 's|-O3|-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32|g' \
-e 's|-g -O2|-O2|g' \
configure

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure --disable-debug

do_make -C liba52
do_make -C liba52 install
# No need to build includes
do_make -C include install

do_clean_bdir
