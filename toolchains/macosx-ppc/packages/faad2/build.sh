#! /bin/sh

FAAD2_VERSION=2_10_1
#FAAD2_SHA256=985c3fadb9789d2815e50f4ff714511c79c2710ac27a4aaaf5c0c2662141426d

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch faad2 "https://github.com/knik0/faad2/archive/2.10.1/faad-${FAAD2_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${FAAD2_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

/opt/macports-tff/bin/autoreconf -vif

CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
ac_cv_prog_cc_c11=no \
do_configure --with-drm=no

# Avoid compiling and installing libfaad2_drm
sed -i'.orig' -e 's/^\(lib_LTLIBRARIES.*\) libfaad_drm.la/\1/' libfaad/Makefile

do_make -C libfaad
do_make -C libfaad install

do_clean_bdir
