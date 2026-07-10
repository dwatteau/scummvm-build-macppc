#! /bin/sh

GIFLIB_VERSION=5.2.2
#GIFLIB_SHA256=34a7377ba834397db019e8eb122e551a49c98f49df75ec3fcc92b9a794a4f6d1

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../helpers
. $HELPERS_DIR/_functions.sh

do_make_bdir

do_http_fetch giflib "https://download.sourceforge.net/project/giflib/giflib-${GIFLIB_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${GIFLIB_SHA256}"

# -Wno-format-truncation is a recent addition to GCC remove it as we don't care about the warning
sed -i'.orig' -e 's/-Wno-format-truncation //' Makefile

CC="$CC" \
do_make libgif.a CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32 -std=gnu99 -Wall'

do_make install-include PREFIX=${PREFIX}
install -m 0644 libgif.a "$PREFIX/lib/"

do_clean_bdir
