#! /bin/sh

# XXX: the 2.10.x to 2.11.x upgrade results in a (several times)
# larger library...
FAAD2_VERSION=2_11_2

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch faad2 "https://github.com/knik0/faad2/archive/2.11.2/faad-${FAAD2_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${FAAD2_SHA256}"

# Avoid compiling and installing DRM and fixed-point versions
# FIXME: the following replacement has no effect anymore?
sed -i'.orig' -e 's/faad\(_drm\(_fixed\)\?\|_fixed\)//g' CMakeLists.txt

do_cmake -DFAAD_BUILD_CLI=no -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32" -DCMAKE_C_COMPILER="$CC"

do_make
do_make install

do_clean_bdir
