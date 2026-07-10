#! /bin/sh

SDL_NET_VERSION=cd5a2ebdea1a15b27f503cc7ffdcaf056d047b73

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch SDL_net "https://github.com/libsdl-org/SDL_net/archive/${SDL_NET_VERSION}.tar.gz" 'tar xzf'

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

# Without --enable-shared, it fails to build its useless programs
CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
do_configure --with-sdl-prefix=$PREFIX --disable-sdltest --enable-shared --disable-gui

do_make

# Don't embed static archives inside a static archive
if ar t .libs/libSDL_net.a libSDL.a >/dev/null 2>&1 ; then
	ar ds .libs/libSDL_net.a libSDL.a libSDLmain.a
fi

# Don't install anything related to the dynamic lib
do_make install-libSDL_netincludeHEADERS install-pkgconfigDATA
/bin/sh ./libtool --mode=install /usr/bin/install -c .libs/libSDL_net.a "$PREFIX/lib"

do_clean_bdir
