#! /bin/sh

FAAD2_VERSION=2_11_2

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch faad2 "https://github.com/knik0/faad2/archive/2.11.2/faad-${FAAD2_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${FAAD2_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

# Avoid compiling and installing DRM and fixed-point versions
sed -i'.orig' -e 's/faad\(_drm\(_fixed\)\?\|_fixed\)//g' CMakeLists.txt

do_cmake -DFAAD_BUILD_CLI=no -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32" -DCMAKE_C_COMPILER=/opt/macports-tff/bin/gcc-mp-7 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.4 -DCMAKE_OSX_SYSROOT=/Developer/SDKs/MacOSX10.4u.sdk

do_make
do_make install

do_clean_bdir
