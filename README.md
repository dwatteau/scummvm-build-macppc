# Building ScummVM on OSX PPC (Tiger, Leopard)

This repository hosts the scripts used to build current releases of ScummVM for OSX PPC (10.4, 10.5), and its required libraries.

## Requirements

- An OSX 10.4 or 10.5 PPC system. (Cross-compiling from i386 10.4/10.5 is untested and unsupported. Same thing applies to Sorbet Leopard.)
    - **IMPORTANT:** If you want to have a build that's going to work on both OSX 10.4 and 10.5, you need to build from a 10.4 box. That's because the libstdc++ C++11 library that's part of the toolkit is only built for the current system. So, even though the dependencies and ScummVM itself will properly target OSX 10.4, you won't be able to run it on OSX 10.4 if you use the C++11 toolkit made for 10.5.
    - If you're just doing a build for yourself on your own OSX 10.5 machine, you don't care, and you *can* build from OSX 10.5. Just don't redistribute it to 10.4 users.
- Reasonnable knowledge of the Terminal and the Unix shell (you can install iTerm 0.10 if you're looking for a terminal with tabs on Tiger)
- Xcode 2.4.1/2.5 for Tiger or 3.0/3.1 for Leopard (available from the [Apple Developer website](https://developer.apple.com/downloads/))
- Downloading and installing the *Unofficial TenFourFox Development Toolkit*
    - (A quick online search should tell you how to get and install it)
    - WARNING: I use the toolkit dated from 2021 (`Unofficial_TenFourFox_Developer_Toolkit_-_Tiger_2.dmg`), not the newer ones. There's no particular reason for me not to upgrade it, except that it works. If you install a newer toolkit, note that it's untested.
- Installing [the required dependencies](#installing-the-required-dependencies)
- Fetching the [ScummVM source code](#fetching-the-scummvm-source-code)
- Doing your [own build of ScummVM](#doing-your-own-scummvm-build)

## Build procedure

### Optional: install ccache

`ccache` can be used to speed up the compilation times, when you have to rebuild a source tree that hasn't changed too much since your last build. It's not part of the base system or part of the toolkit, so the easiest way is to build it from source yourself.

Download the older 3.7.12 release here: <https://github.com/ccache/ccache/releases/download/v3.7.12/ccache-3.7.12.tar.gz> (newer releases are more complex to build, and this release is just fine).

```sh
tar xzf ccache-3.7.12.tar.gz
cd ccache-3.7.12
CC=/usr/bin/gcc-4.0 ./configure --with-bundled-zlib
make && sudo make install
```

### Installing the required dependencies

You need to copy and work from *this* repository.

Check that you meet the requirements (*TODO:* very lightweight tests at the moment):
```sh
cd /path/to/this/scummvm-build-macppc
cd toolchains/macosx-ppc
./prepare.sh
```

The required libraries are going to be built as *static* libraries, put in `/staticscummvm`.

If you want to use a pre-built set of libraries, you may look at [the Releases page](https://github.com/dwatteau/scummvm-build-macppc/releases) for a `.zip` archive that should be extracted into `/staticscummvm`.

Otherwise, if you want to build things yourself: 

```sh
for lib in $(grep -vE '^\s*$|^#' packages/order.txt) ; do
  echo "About to build: $lib"
  cd "packages/$lib" && env PREFIX=/staticscummvm ./build.sh
  if [ $? -ne 0 ]; then
    echo "ERROR: Building library $lib failed!"
    break
  fi 
  cd ../..
done
```

It shouldn't take too long.

If you see any "`ERROR`" printed as the last line in the script, something went wrong. Contact me if necessary.

### Fetching the ScummVM source code

If you know about Git, use Git. It's available in `/opt/macports-tff/bin/git` (albeit an older release) once the Unofficial TenFourFox Development Toolkit is properly installed.

Of course, remember that you're doing requests to the Internet with an OS that's hasn't received any security update for more than a decade!

```sh
mkdir -p ~/git
cd ~/git
git clone https://github.com/scummvm/scummvm.git
```

It's going to take a while.

If you don't know Git, and just want to build a particular fixed ScummVM release yourself, you may fetch a *tarball* with the source code, for example:  
<https://downloads.scummvm.org/frs/scummvm/2.8.1/scummvm-2.8.1.tar.bz2>

and just extract it this way:
```sh
tar xjf /path/to/scummvm-2.8.1.tar.bz2
```

### Doing your own ScummVM build

The idea is to go the directory with the ScummVM source code, and call the `config.sh` that's at the root of this OSXPPC build repository:

```sh
cd /path/to/scummvm/source
bash /path/to/this/scummvm-build-macppc/config.sh
```

This will do a full build of ScummVM with all its stable engines, and compiler optimizations turned on. If built from OSX 10.4, compatibility with OSX 10.4/10.5 and G3 to G5 systems should work out of the box.

Build time for a full optimized build can take several hours, depending on the machine you have. You can change the `gmake` call to `gmake -j2` if you have a Dual G5, `gmake -j4` if you have a Quad G5, etc.

The build script should produce a `ScummVM-snapshot.dmg` image as a final output.

If you know what you're doing, you can have a look at that `config.sh` script and adjust it to your needs.

## FAQ

Read the [FAQ](FAQ.md) page for more technical matters.

## About this repository

This started as a quick'n'dirty fork of <https://github.com/scummvm/dockerized-bb>, in order to build the ScummVM dependencies as closely as what's used for the automated builds of ScummVM. The build scripts remain similar to what's used in the upstream `dockerized-bb` repo, and they mostly follow the patches, releases and build options used for building the other ScummVM ports, whenever possible. The scripts hosted here do *not* use the real `dockerized-bb` infrastructure; they're native builds.
