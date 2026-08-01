#! /bin/sh

FRIBIDI_VERSION=1.0.16
#FRIBIDI_SHA256=30f93e9c63ee627d1a2cedcf59ac34d45bf30240982f99e44c6e015466b4e73d

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch fribidi "https://github.com/fribidi/fribidi/releases/download/v${FRIBIDI_VERSION}/fribidi-${FRIBIDI_VERSION}.tar.xz" \
        "tar --use-compress-program=$XZ_PATH/xz -xf" #"sha256:${FRIBIDI_SHA256}"

CC="$CC" \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure --disable-silent-rules --enable-static

# Avoid compiling and installing doc, binaries and tests
sed -i'.orig' -e 's/^\(SUBDIRS.*\) bin doc test/\1/' Makefile

do_make
do_make install

do_clean_bdir
