#!/bin/sh
#
# TODO: separate config/build/bundle/dmg phases, or at least add options
# to this script for that? But it's a short one, just I just tend to
# edit it on the fly...
#
set -eu

# Not having /opt/macports-tff/bin in $PATH is done on purpose, as we want
# to have precise control of what's being used outside of the base system
export PATH=/staticscummvm/bin:/usr/bin:/bin:/usr/sbin:/sbin

# If you want the 'git' command to be available to the build scripts (e.g.
# for proper display of the current Git revision for development builds),
# do this:
#sudo ln -sf /opt/macports-tff/bin/git /usr/bin/git

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

BUILD_MODE=${BUILD_MODE:-release}
WITH_DEBUG=${WITH_DEBUG:-yes}
WITH_OPTIM=${WITH_OPTIM:-yes}
USE_CCACHE=${USE_CCACHE:-yes}

if [ "$BUILD_MODE" = "release" ]; then
	WITH_DEBUG=no
	WITH_OPTIM=yes
fi

CCACHE_PREFIX=
if [ "$USE_CCACHE" = yes ]; then
	if [ ! -e /usr/local/bin/ccache ]; then
		echo "WARNING: /usr/local/bin/ccache not found, not using it..." >&2
	else
		CCACHE_PREFIX='/usr/local/bin/ccache '
	fi
fi

DEBUG_CXXFLAGS=
DEBUG_CONFIG_OPT=--disable-debug
if [ "$WITH_DEBUG" = "yes" ]; then
	DEBUG_CXXFLAGS='-g'
	DEBUG_CONFIG_OPT=--enable-debug
fi

OPTIM_CXXFLAGS='-O0'
OPTIM_CONFIG_OPT=--enable-optimizations
if [ "$WITH_OPTIM" = "yes" ]; then
	# XXX: -Os used to be recommended for G3s, but that was in the GCC 3.x
	# years. Unless there is a need for it, and real measurements, I'd rather
	# keep the most tested and most reliable default flag: -O2
	OPTIM_CXXFLAGS='-O2'
	OPTIM_CONFIG_OPT=--enable-optimizations
fi

# Notes:
#
# `-Wl,-headerpad_max_install_names` is required for the install_name_tool
# tricks happening later on.
#
# Using updated ar/ld/randlib/strings/strip for their bugfixes and improved
# support for C++11 content.
#
# Fluidlite support currently disabled because of problems on big-endian.
CXX="${CCACHE_PREFIX}/opt/macports-tff/bin/g++-mp-7" \
AR=/opt/macports-tff/bin/ar \
LD=/opt/macports-tff/bin/ld-97 \
RANLIB=/opt/macports-tff/bin/ranlib \
STRINGS=/opt/macports-tff/bin/strings \
STRIP=/opt/macports-tff/bin/strip \
CPPFLAGS='-I/staticscummvm/include' \
CXXFLAGS="$OPTIM_CXXFLAGS $DEBUG_CXXFLAGS -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -m32" \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-headerpad_max_install_names -L/staticscummvm/lib' \
./configure \
--with-staticlib-prefix=/staticscummvm \
--with-xcodetools-path=/Developer/Tools \
--enable-release \
$DEBUG_CONFIG_OPT \
$OPTIM_CONFIG_OPT \
--enable-static \
--enable-plugins \
--default-dynamic \
--disable-cloud \
--disable-discord \
--disable-gtk \
--disable-libcurl \
--disable-nasm \
--disable-osx-dock-plugin \
--disable-readline \
--disable-sdlnet \
--disable-sparkle \
--disable-tts \
--disable-updates \
--disable-fluidlite \
--disable-fluidsynth \
--enable-taskbar

# USE_CURL= because we don't trust this on old macOS
/opt/macports-tff/bin/gmake USE_CURL=
#exit 0

/opt/macports-tff/bin/gmake USE_CURL= bundle

# No C++11 library present in default OSX 10.4/10.5, so we need to bundle the one
# that's part of the toolkit, and adjust the paths with install_name_tool.
#
# Note: we can't use @rpath, as it's not available in OSX 10.4, see:
# https://www.mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html
mkdir -p ScummVM.app/Contents/Frameworks
cp -p /opt/macports-tff/lib/libgcc/libstdc++.6.dylib /opt/macports-tff/lib/libgcc/libgcc_s.1.dylib ScummVM.app/Contents/Frameworks/
for file in ScummVM.app/Contents/MacOS/scummvm ScummVM.app/Contents/Resources/*.plugin ; do
	/opt/macports-tff/bin/install_name_tool -change /opt/macports-tff/lib/libgcc/libstdc++.6.dylib "@executable_path/../Frameworks/libstdc++.6.dylib" "$file"
	/opt/macports-tff/bin/install_name_tool -change /opt/macports-tff/lib/libgcc/libgcc_s.1.dylib "@executable_path/../Frameworks/libgcc_s.1.dylib" "$file"
	# XXX: system /usr/lib/libgcc_s.1.dylib appears before ours in otool output, which may cause issues.
	# The following line could fix that, but since I'm not aware of any real problem so far, it's unused for now.
	#/opt/macports-tff/bin/install_name_tool -change /usr/lib/libgcc_s.1.dylib "@executable_path/../Frameworks/libgcc_s.1.dylib" "$file"
done

# Don't rebuild the bundle, since we're modifying it just below
/opt/macports-tff/bin/gmake -o bundle USE_CURL= osxsnap
