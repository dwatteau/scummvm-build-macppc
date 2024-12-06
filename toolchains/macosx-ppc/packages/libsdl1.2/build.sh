#! /bin/sh

SDL_VERSION=0237f339e6bec39c56e1364787fabdb0245d478f

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch SDL "https://github.com/libsdl-org/SDL-1.2/archive/${SDL_VERSION}.tar.gz" 'tar xzf'

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

# If building with a newer GCC, remove this ancient Apple-only flag
#sed -i'.orig' -e 's/-fpascal-strings//g' configure

# --enable-altivec=yes does proper runtime detection with sysctl() and
# -faltivec on OS X, but somehow -faltivec behaves differently in gcc-mp (4.8/7)
# because some Altivec instructions are still called on G3 processors (i.e.
# -faltivec behaves like -maltivec). Ideally, non-Altivec code should
# never appear in a -maltivec compilation unit, but SDL1.2 does this.
#
# So, force a compilation with the old Apple compiler (which doesn't have
# this issue) as long as we can, since the Altivec speedup is probably
# higher than the compiler update gains for this type of code(?)
CC=gcc-4.0 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure \
--without-x --disable-shared --enable-rpath=no --enable-altivec=yes
do_make

# No man pages
do_make install-bin install-hdrs install-lib install-data 

do_clean_bdir
