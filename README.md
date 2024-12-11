# Building ScummVM on OSX PPC (Tiger, Leopard)

This repository hosts the scripts used to build current releases of ScummVM for OSX PPC (10.4, 10.5), and its required libraries.

## Requirements

- An OSX 10.4 or 10.5 PPC system. (Cross-compiling from i386 10.4/10.5 is untested and unsupported. Same thing applies to Sorbet Leopard.)
    - **IMPORTANT:** If you want to have a build that's going to work on both OSX 10.4 and 10.5, you need to build from a 10.4 box. That's because the libstdc++ C++11 library that's part of the toolkit is only built for the current system. So, even though the dependencies and ScummVM itself will properly target OSX 10.4, you won't be able to run it on OSX 10.4 if you use the C++11 toolkit made for 10.5.
    - If you're just doing a build for yourself on your own OSX 10.5 machine, you don't care, and you *can* build from OSX 10.5. Just don't redistribute it to 10.4 users.
- Reasonnable knowledge of the Terminal and the Unix shell
- Xcode 2.4.1/2.5 for Tiger or 3.0/3.1 for Leopard (available from the [Apple Developer website](https://developer.apple.com/downloads/))
- Downloading and installing the *Unofficial TenFourFox Development Toolkit*
    - (A quick online search should tell you how to get and install it)
    - WARNING: I use the toolkit dated from 2021, not the newer ones. There's no particular reason for me not to upgrade it, except that it works. If you install a newer toolkit, you may run into some issues.
- Installing [the required dependencies](#installing-the-required-dependencies)
- Fetching the [ScummVM source code](#fetching-the-scummvm-source-code)
- Doing your [own build of ScummVM](#doing-your-own-scummvm-build)

## Build procedure

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

## With which CPUs and OSX releases are supported?

OSX 10.4 (Tiger) and OSX 10.5 (Leopard), on PowerPC systems. (It should also work for users of so-called "Sorbet Leopard", but it's untested.)

It can also be made to run on Intel/i386 Snow Leopard (OSX 10.5) through Rosetta 1. It's not officially supported, though.

The resulting app should be compatible with G3, G4 and G5 processors. Yes, I try to take care of not breaking G3 (or non-Altivec) compatibility (although my own testing on G3 is lightweight).

## Do you plan on adding support for older OSX releases, such as 10.2 or 10.3?

Very unlikely. Building for OSX 10.4 is already quite difficult; going back to 10.3 would mean even more work, and I don't have much interest in that myself. I do know that older OSX releases run better on G3s. But unless someone wants to contribute on this, I don't think I will do that myself.

The biggest problem is that there's no C++11 toolchain for OSX 10.3, AFAICS.

[ScummVM 1.6.0](https://downloads.scummvm.org/frs/scummvm/1.6.0/scummvm-1.6.0-macosx.dmg) (2013) has been confirmed to work on OSX 10.3. Maybe some releases between ScummVM 1.6.0 and ScummVM 2.5.0 still worked on OSX 10.3; but this has been untested.

ScummVM 2.5.x (2021; the last release not requiring a C++11 compiler) *could* be made to work on OSX 10.3 without too much work, in theory. I don't have any OSX 10.3 system to do this, and it's not in my priorities either to work on this. But if someone can lend me access to an OSX 10.3 system, I could maybe try working on doing a "final" build of ScummVM for Panther, *if time permits*.

## Do you plan on doing an optimized build for G4s/Altivec/G5s or 10.4-10.6 Intel?

Since ScummVM mostly (but not only!) targets "old games", I haven't seen any reason to spend time on this, so far. I don't think there were could be much performance improvement. Building a multi-architecture binary would require even more work, so my time is probably better spent on other areas, for the moment.

The performance improvements between late PPC systems and OSX 10.4/10.5/10.6 Intel means that most of the games appear to work fine, even when using Rosetta 1 to translate the PowerPC code to x86 code. So, I don't see the point in doing an i386 build for i386 Tiger/Leopard/Snow Leopard either.

Also, it appears (from some MacRumors forum discussions) that the GCC 7.5 compiler that's used to build ScummVM may have various unfixed bugs when targeting ppc64 (which is necessary for a G5-optimized build). So if someone wants a G5 build, it may need necessary to either downgrade to the GCC 4.8 compiler included the toolkit (which was used to build OSXPPC releases for ScummVM 2.6 to 2.8), or upgrade to a newer compiler, such as GCC ≥ 10. For now (2024), a unique, stable and (mostly) reproducible build is preferred.

## When aren't you using MacPorts for the toolchain/dependencies?

The work done by MacPorts for preserving OSX 10.4/10.5 PPC compatibility is amazing. But it's a moving target; what works in January may not build anymore in March, because the whole MacPorts tree is always being updated, and regressions happen. Also, bootstraping the full C++11 toolchain (and some other tools such as `cmake`, `git`…) is really, really slow.

The Unofficial TenFourFox Development Toolkit just works out of the box, and its results are reproducible.

## How to run a debugger on ScummVM for OSX PPC?

Get a [newer GDB from the old TenFourFox files](https://sourceforge.net/projects/tenfourfox/files/tools/), called `gdb768-104fx-3.tar.gz`. Get *exactly* this one.

Using your own GDB binary requires special permissions, documented here for example:

* <https://sourceware.org/gdb/wiki/PermissionsDarwin>
* <http://gridlab-d.shoutwiki.com/wiki/Mac_OSX/Setup>

It looks like trying to make this work on OSX 10.5 is pointless. So OSX 10.4 may be a hard requirement!

Ensure there's a `-p` option set up in the file below:
```sh
cat /System/Library/LaunchDaemons/com.apple.taskgated.plist
```

And then allow your current user to run this GDB binary with particular privileges:

```sh
sudo dseditgroup -o edit -a YOURUSERNAMEHERE -t user procmod
sudo chgrp procmod /path/to/extracted/archive/above/gdb # parent directory may also need 'chmod g+s'?
```

and then reboot for the changes to take effect.

Then, after doing an `--disable-optimizations --enable-debug` build (warning: if you don't use `--enable-plugins --default-dynamic`, building too many engines will trigger internal linker errors. So, if you need to particular a particular engine, do your ScummVM debug build with `--disable-detection-full --disable-all-engines --enable-engine=your-engine-name`):

```sh
/path/to/extracted/archive/above/gdb -q ./path/to/debug/scummvm
(gdb) run

(gdb) bt
(gdb) bt full
```

Running GDB on the official releases for OSX PPC is not going to be really helpful, because they're built with optimizations and no debug information.

## About this repository

This started as a quick'n'dirty fork of <https://github.com/scummvm/dockerized-bb>, in order to build the ScummVM dependencies as closely as what's used for the automated builds of ScummVM. The build scripts remain similar to what's used in the upstream `dockerized-bb` repo, and they mostly follow the patches, releases and build options used for building the other ScummVM ports, whenever possible. The scripts hosted here do *not* use the real `dockerized-bb` infrastructure; they're native builds.
