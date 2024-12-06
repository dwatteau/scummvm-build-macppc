#! /bin/sh

SONIVOX_VERSION=3.6.14
#SONIVOX_SHA256=d625ad6b3375a036bf30cd3b0b40e8dde08f0891bfd3a2960650654bdb50318c

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch sonivox \
	"https://github.com/pedrolcl/sonivox/archive/refs/tags/v${SONIVOX_VERSION}.tar.gz" 'tar xzf' #"sha256:${SONIVOX_SHA256}"

# XXX: uses __builtin_mul_overflow/__builtin_add_overflow which were added in GCC 5.0
do_cmake -DBUILD_SONIVOX_SHARED=OFF -DBUILD_TESTING=OFF -DBUILD_EXAMPLE=OFF -DCMAKE_C_FLAGS="-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32" -DCMAKE_C_COMPILER=/opt/macports-tff/bin/gcc-mp-7 -DCMAKE_CXX_COMPILER=/opt/macports-tff/bin/g++-mp-7 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.4 -DCMAKE_OSX_SYSROOT=/Developer/SDKs/MacOSX10.4u.sdk "$@"

do_make VERBOSE=1

do_make install

do_clean_bdir
