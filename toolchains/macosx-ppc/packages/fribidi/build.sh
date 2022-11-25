#! /bin/sh

FRIBIDI_VERSION=1.0.12
#FRIBIDI_SHA256=30f93e9c63ee627d1a2cedcf59ac34d45bf30240982f99e44c6e015466b4e73d

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch fribidi "https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VERSION}/fribidi-${FRIBIDI_VERSION}.tar.xz" \
        'tar --use-compress-program=/opt/local/bin/xz -xf' #"sha256:${FRIBIDI_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-4.8 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure --disable-silent-rules

# Avoid compiling and installing doc, binaries and tests
sed -i'.orig' -e 's/^\(SUBDIRS.*\) bin doc test/\1/' Makefile

do_make
do_make install

do_clean_bdir
