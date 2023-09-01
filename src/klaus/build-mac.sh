#!/bin/sh

set -x

mkdir -p ../../compiled/klauscon/x86_64-darwin

/usr/local/bin/fpc \
-MObjFPC \
-Scghi \
-O2 \
-l \
-vewnhibq \
-Fi../../compiled/klauscon/x86_64-darwin \
-Fu../lib \
-Fu/Applications/Lazarus/lcl/units/x86_64-darwin \
-Fu/Applications/Lazarus/components/freetype/lib/x86_64-darwin \
-Fu/Applications/Lazarus/components/lazutils/lib/x86_64-darwin \
-Fu/Applications/Lazarus/packager/units/x86_64-darwin \
-Fu. \
-FU../../compiled/klauscon/x86_64-darwin \
-FE../../compiled \
-o../../compiled/klaus \
klauscon.lpr
