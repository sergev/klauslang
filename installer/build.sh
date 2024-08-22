#!/bin/bash

set -e # fail on any error
set -u # treat unset variables as errors

VER="$1"
DIRNAME="v$VER-build"

cd ../build

if [ -d "$DIRNAME" ]; then
  echo "Directory already exists: $DIRNAME"
  exit 1
fi

mkdir "$DIRNAME" && cd "$DIRNAME"

mkdir -p ./opt/klauslang/amd64
cp ../../compiled/klaus ./opt/klauslang/amd64/
cp ../../compiled/klaus-ide ./opt/klauslang/amd64/
cp ../../compiled/klaus-course-edit ./opt/klauslang/amd64/

mkdir -p ./opt/klauslang/samples
cp -r ../../samples/* ./opt/klauslang/samples/

mkdir -p ./opt/klauslang/test
cp -r ../../test/* ./opt/klauslang/test/

mkdir -p ./opt/klauslang/doc
cp -r ../../doc/* ./opt/klauslang/doc/

mkdir -p ./opt/klauslang/practicum
cp -r ../../practicum/* ./opt/klauslang/practicum/

mkdir ./usr
rsync -r ../../src/assets/usr/ ./usr/

mkdir -p ./usr/bin
ln -s /opt/klauslang/amd64/klaus ./usr/bin/klaus
ln -s /opt/klauslang/amd64/klaus-ide ./usr/bin/klaus-ide
ln -s /opt/klauslang/amd64/klaus-course-edit ./usr/bin/klaus-course-edit

cp ../../installer/what-s-new.txt ./opt/klauslang/

SIZE=$(du -s ../$DIRNAME | grep -Eo "^[0-9]+")

mkdir DEBIAN

echo "Package: klauslang
Version: $VER
Section: devel
Priority: optional
Maintainer: Konstantin Zakharoff <mail@czaerlag.ru>
Homepage: https://gitflic.ru/project/czaerlag/klauslang
Architecture: amd64
Depends: libc6
Installed-Size: $SIZE
Description: Klaus -- educational programming language and development environment" > DEBIAN/control

cd ..
mkdir v$VER

fakeroot dpkg-deb --build $DIRNAME ./v$VER/klauslang_${VER}_amd64.deb

cp ../compiled/klaus.exe /mnt/ntfs/working/dev/klauslang/compiled/
cp ../compiled/klaus-ide.exe /mnt/ntfs/working/dev/klauslang/compiled/
cp ../compiled/klaus-course-edit.exe /mnt/ntfs/working/dev/klauslang/compiled/
