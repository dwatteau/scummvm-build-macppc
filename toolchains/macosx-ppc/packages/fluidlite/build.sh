#! /bin/sh

FLUIDLITE_VERSION=d59d2328818f913b7d1a6a59aed695c47a8ce388

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch FluidLite \
	"https://github.com/divideconcept/FluidLite/archive/${FLUIDLITE_VERSION}.tar.gz" 'tar xzf'

# Not relying on the automated patches/ future here, because the original
# patch relies on a Git format that older OSX patch(1) doesn't understand
cp -p include/fluidlite.h include/fluidlite.h.in
patch -N -t -p1 < $PACKAGE_DIR/manual-patches/0001-Fix-static-build.patch

do_cmake -DFLUIDLITE_BUILD_SHARED=OFF -DCMAKE_C_FLAGS="-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32" -DCMAKE_C_COMPILER=/opt/macports-tff/bin/gcc-mp-7 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.4 -DCMAKE_OSX_SYSROOT=/Developer/SDKs/MacOSX10.4u.sdk

do_make VERBOSE=1

do_make install

do_clean_bdir
