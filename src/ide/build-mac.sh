#!/bin/sh

set -x

mkdir -p ../../compiled/klauside/x86_64-darwin

/usr/local/bin/fpc \
-MObjFPC \
-Schi \
-O3 \
-k-framework \
-kCocoa \
-l \
-vewnhibq \
-Fi../../compiled/klauside/x86_64-darwin \
-Fu../lib \
-Fu../klaus \
-Fu../lib/edit \
-Fu../lib/console \
-Fu/Applications/Lazarus/components/synedit/units/x86_64-darwin/cocoa \
-Fu/Applications/Lazarus/components/anchordocking/units/x86_64-darwin/cocoa \
-Fu/Applications/Lazarus/lcl/units/x86_64-darwin/cocoa \
-Fu/Applications/Lazarus/lcl/units/x86_64-darwin \
-Fu/Applications/Lazarus/components/freetype/lib/x86_64-darwin \
-Fu/Applications/Lazarus/components/lazutils/lib/x86_64-darwin \
-Fu/Applications/Lazarus/packager/units/x86_64-darwin \
-Fu. \
-FU../../compiled/klauside/x86_64-darwin \
-FE../../compiled \
-o../../compiled/klaus-ide \
-dLCL \
-dLCLcocoa \
klauside.lpr
