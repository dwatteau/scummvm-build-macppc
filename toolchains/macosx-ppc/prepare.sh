#!/bin/sh
set -eu

case "$(sw_vers -productVersion)" in
10.4.*|10.5.*)
	case "$(arch)" in
	ppc*)
		if ! port version >/dev/null 2>&1 ; then
			echo "MacPorts wasn't found in your current \$PATH." >&2
			echo "Please install it from: https://www.macports.org/install.php" >&2
			exit 1
		fi
		;;
	*)
		echo "This script can only be run on a ppc host" >&2
		exit 1
	esac
	;;
*)
	echo "This script can only be run on Mac OS X 10.4 or 10.5" >&2
	exit 1
	;;
esac

if [ ! -e /opt/macports-tff ]; then
	echo "/opt/macports-tff/ wasn't found. Please install the" >&2
	echo "\"Unofficial TenFourFox Development Toolkit\" and Xcode 2.5 (Tiger)" >&2
	echo "or Xcode 3.14 (Leopard) in order to build ScummVM." >&2
	exit 1
fi
