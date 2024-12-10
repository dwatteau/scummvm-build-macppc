#!/bin/sh
set -eu

export PATH=/staticscummvm/bin:/usr/bin:/bin:/usr/sbin:/sbin
#command -v xattr >/dev/null 2>&1 || ln -sf /usr/bin/true /staticscummvm/bin/xattr
#ln -sf /usr/bin/false /staticscummvm/bin/hdiutil
#ln -sf /opt/macports-tff/bin/git /usr/bin/git

export MACOSX_DEPLOYMENT_TARGET=10.4
export SDKROOT=/Developer/SDKs/MacOSX10.4u.sdk

CXX='/usr/local/bin/ccache /opt/macports-tff/bin/g++-mp-7' \
AR=/opt/macports-tff/bin/ar \
LD=/opt/macports-tff/bin/ld-97 \
RANLIB=/opt/macports-tff/bin/ranlib \
STRINGS=/opt/macports-tff/bin/strings \
STRIP=/opt/macports-tff/bin/strip \
CPPFLAGS='-I/staticscummvm/include' \
CXXFLAGS='-O2 -mmacosx-version-min=10.4 -isysroot /Developer/SDKs/MacOSX10.4u.sdk -m32' \
LDFLAGS='-Wl,-macosx_version_min,10.4 -Wl,-headerpad_max_install_names -L/staticscummvm/lib' \
./configure \
--with-staticlib-prefix=/staticscummvm \
--with-xcodetools-path=/Developer/Tools \
--enable-release \
--disable-debug \
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

#perl -pi -e 's/-O2 /-O0 /g' config.mk

# USE_CURL= because we don't trust this on old macOS
/opt/macports-tff/bin/gmake USE_CURL=
#exit 0

/opt/macports-tff/bin/gmake USE_CURL= bundle

cp -p /opt/macports-tff/lib/libgcc/libstdc++.6.dylib /opt/macports-tff/lib/libgcc/libgcc_s.1.dylib ScummVM.app/Contents/MacOS/ 
for file in ScummVM.app/Contents/MacOS/scummvm ScummVM.app/Contents/Resources/*.plugin ; do
	/opt/macports-tff/bin/install_name_tool -change /opt/macports-tff/lib/libgcc/libstdc++.6.dylib "@executable_path/libstdc++.6.dylib" "$file"
	/opt/macports-tff/bin/install_name_tool -change /opt/macports-tff/lib/libgcc/libgcc_s.1.dylib  "@executable_path/libgcc_s.1.dylib" "$file"
done

/opt/macports-tff/bin/gmake -o bundle USE_CURL= osxsnap
