#! /bin/sh

FREETYPE_VERSION=2.12.1
FREETYPE_SHA256=XXX

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch freetype "http://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${FREETYPE_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS='-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk' \
ZLIB_CFLAGS="-I$PREFIX/include" \
ZLIB_LIBS="-Wl,-macosx_version_min,10.4 -Wl,-search_paths_first -L$PREFIX/lib -lz" \
ac_cv_prog_cc_c11=no \
do_configure \
--enable-freetype-config --with-zlib=yes --with-bzip2=yes \
--with-png=no --with-harfbuzz=no --with-brotli=no \
--with-old-mac-fonts

do_make
do_make install

do_clean_bdir
