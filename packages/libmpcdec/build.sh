#! /bin/sh

# from Debian
LIBMPCDEC_VERSION=0.1~r495

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch musepack "http://deb.debian.org/debian/pool/main/libm/libmpc/libmpc_${LIBMPCDEC_VERSION}.orig.tar.gz" \
        'tar xzf' #"sha256:${LIBMPCDEC_SHA256}"

/opt/macports-tff/bin/autoreconf -fi

# Debian adds/uses --enable-mpcchap, but that seems useless for our use?
CC="$CC" \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure

do_make -C include
do_make -C libmpcdec

do_make -C include install
do_make -C libmpcdec install

do_clean_bdir
