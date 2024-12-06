#! /bin/sh

LIBPNG_VERSION=1.6.44
#LIBPNG_SHA256=af4fb7f260f839919e5958e5ab01a275d4fe436d45442a36ee62f73e5beb75ba

PACKAGE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
HELPERS_DIR=$PACKAGE_DIR/../../../common
. $HELPERS_DIR/functions.sh

do_make_bdir

do_http_fetch libpng "https://download.sourceforge.net/project/libpng/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.gz" \
	'tar xzf' #"sha256:${LIBPNG_SHA256}"

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CC=/opt/macports-tff/bin/gcc-mp-7 \
CFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -Wa,-force_cpusubtype_ALL -m32' \
LDFLAGS="-Wl,-macosx_version_min,10.4 -Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -Wl,-search_paths_first -L$PREFIX/lib" \
CPPFLAGS="-I$PREFIX/include" \
ac_cv_prog_cc_c11=no \
do_configure --disable-powerpc-vsx --with-zlib-prefix=$PREFIX # requires POWER7

do_make

# Don't install man pages and binaries
do_make install-libLTLIBRARIES \
	install-binSCRIPTS \
	install-pkgconfigDATA \
	install-pkgincludeHEADERS \
	install-nodist_pkgincludeHEADERS

# As we install everything manually we must handle dependencies ourselves
# Run these after the other ones as they depend on them
do_make install-header-links \
	install-library-links \
	install-libpng-pc \
	install-libpng-config

do_clean_bdir
