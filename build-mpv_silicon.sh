#!/usr/bin/env bash

# builds mpv & mpv.app on Apple silicon (M1 / M2) Macs
# run this script from the root directory of the mpv repo

set -x

brew install --only-dependencies mpv
git clone https://github.com/mpv-player/mpv

# use standalone tools, not Xcode's (avoids xcrun errors)
export DEVELOPER_DIR="/Library/Developer/CommandLineTools/"

LUAJIT_PATH="$(brew --prefix --installed luajit-openresty)" || exit 1
LUAJIT_PKG_CONFIG_PATH="$LUAJIT_PATH/lib/pkgconfig"
export PKG_CONFIG_PATH="$LUAJIT_PKG_CONFIG_PATH"

# if we don't have the latest ffmpeg...
if ! brew --prefix --installed ffmpeg; then
	# ...but we do have ffmpeg@4, use it instead
	if FFMPEG4_PATH="$(brew --prefix --installed ffmpeg@4)"; then
		FFMPEG4_PKG_CONFIG_PATH="$FFMPEG4_PATH/lib/pkgconfig"
		export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:$FFMPEG4_PKG_CONFIG_PATH"
	# if we have neither version, gtfo
	else
		exit 1
	fi
fi

set -e # if any of the following fail, immediately gtfo

./bootstrap.py
./waf configure --lua=luajit
./waf build
# test the binary we just built
./build/mpv --version
./TOOLS/osxbundle.py --skip-deps build/mpv
