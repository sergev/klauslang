#!/bin/bash

# Version number must be passed in $1
# Directory ../build must exist
# Directory ../build/v$1 must NOT exist
# Directories ../build/v$1-klauslang-build and ../build/v$1-teacher-build must NOT exist
# Compiled binaries of the $1 version must exist in ../compiled
# NSIS 3.10 must be installed under Wine in %ProgramFiles%\NSIS\ 
# RPM packages for ALT Linux must exist in ../compiled

set -e
set -u

cd ../build

VER="$1"

if [ -d "v$VER" ]; then
  echo "Directory already exists: v$VER"
  exit 1
fi
mkdir v$VER

BD1="v$VER-klauslang-build"
if [ -d "$BD1" ]; then
  echo "Directory already exists: $BD1"
  exit 1
fi

BD2="v$VER-teacher-build"
if [ -d "$BD2" ]; then
  echo "Directory already exists: $BD2"
  exit 1
fi

# DEBIAN package klauslang

mkdir "$BD1" && cd "$BD1"

mkdir -p ./opt/klauslang/amd64
cp ../../compiled/klaus ./opt/klauslang/amd64/
cp ../../compiled/klaus-ide ./opt/klauslang/amd64/

mkdir -p ./opt/klauslang/samples
cp -r ../../samples/* ./opt/klauslang/samples/

mkdir -p ./opt/klauslang/test
cp -r ../../test/* ./opt/klauslang/test/

mkdir -p ./opt/klauslang/doc
cp -r ../../doc/* ./opt/klauslang/doc/

mkdir -p ./opt/klauslang/practicum
cp -r ../../practicum/* ./opt/klauslang/practicum/

mkdir ./usr
rsync -r ../../src/assets/klauslang/usr/ ./usr/

mkdir -p ./usr/bin
ln -s /opt/klauslang/amd64/klaus ./usr/bin/klaus
ln -s /opt/klauslang/amd64/klaus-ide ./usr/bin/klaus-ide

cp ../../installer/what-s-new.txt ./opt/klauslang/

SIZE=$(du -s ../$BD1 | grep -Eo "^[0-9]+")

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

fakeroot dpkg-deb --build $BD1 ./v$VER/klauslang_${VER}_amd64.deb

rm -r $BD1

# DEBIAN package klauslang-teacher

mkdir "$BD2" && cd "$BD2"

mkdir -p ./opt/klauslang/amd64
cp ../../compiled/klaus-course-edit ./opt/klauslang/amd64/

mkdir ./usr
rsync -r ../../src/assets/klauslang-teacher/usr/ ./usr/

mkdir -p ./usr/bin
ln -s /opt/klauslang/amd64/klaus-course-edit ./usr/bin/klaus-course-edit

SIZE=$(du -s ../$BD2 | grep -Eo "^[0-9]+")

mkdir DEBIAN

echo "Package: klauslang-teacher
Version: $VER
Section: devel
Priority: optional
Maintainer: Konstantin Zakharoff <mail@czaerlag.ru>
Homepage: https://gitflic.ru/project/czaerlag/klauslang
Architecture: amd64
Depends: libgtk2.0-0, klauslang (= $VER)
Installed-Size: $SIZE
Description: Klaus training course editor (for teachers and methodologists)" > DEBIAN/control

cd ..

fakeroot dpkg-deb --build $BD2 ./v$VER/klauslang-teacher_${VER}_amd64.deb

rm -r $BD2

# Windows installer

cd ../installer

echo "!define PRODUCT_VERSION \"$VER\"" > version.nsi

wine "$(wine cmd /c echo %ProgramFiles% | tr -d \\r)\NSIS\makensis.exe" klaus.nsi

rm version.nsi

# ZIP them...

cd ../build/v$VER
zip klauslang-${VER}-1.x86_64-alt.zip ../../compiled/klauslang-${VER}-1.x86_64.rpm ../../compiled/klauslang-teacher-${VER}-1.x86_64.rpm
zip klauslang_${VER}_amd64-debian.zip klauslang_${VER}_amd64.deb klauslang-teacher_${VER}_amd64.deb
zip klauslang_${VER}_x64-windows.zip klauslang_${VER}_x64.exe
