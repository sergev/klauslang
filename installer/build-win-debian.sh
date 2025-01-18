#!/bin/bash
#
# Requires: Ubuntu (>= 22.04)
#
# This will compile klauscon.lpi, klauside.lpi and klauscourseedit.lpi for Ubuntu and Win10,
# build DEB packages, make Windows installer and ZIP them all.
#
# Version number MAY be passed in $1 -- if so, the new version will be set for all the projects.
#
# Directory ../build/v$1 must NOT exist
# Directories ../build/v$1-klauslang-build and ../build/v$1-teacher-build must NOT exist
# lazbuild (>= 3.4) must exist on the path
# NSIS (>= 3.10) must be installed under Wine in %ProgramFiles%\NSIS\ 

set -e

###################################
# Set up
###################################

if [[ -n "$1" ]]; then
  VER=$1
  ./set-version.sh $VER
else
  VER=$(cat ../src/ver)
fi

set -u

mkdir -p ../build && cd ../build

if [ -d "v$VER" ]; then
  echo "Directory already exists: build/v$VER"
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

###################################
# Build Lazarus projects
###################################

../installer/compile.sh Linux
../installer/compile.sh Windows

###################################
# DEBIAN package klauslang
###################################

mkdir "$BD1"
cd ../installer
./install.sh klauslang "../build/$BD1"

cd ../build/$BD1

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

###################################
# DEBIAN package klauslang-teacher
###################################

mkdir "$BD2"
cd ../installer
./install.sh klauslang-teacher "../build/$BD2"

cd ../build/$BD2

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

###################################
# Windows installer
###################################

cd ../installer

echo "!define PRODUCT_VERSION \"$VER\"" > version.nsi

wine "$(wine cmd /c echo %ProgramFiles% | tr -d \\r)\NSIS\makensis.exe" klaus.nsi

rm version.nsi

###################################
# ZIP them
###################################

cd ../build/v$VER
zip klauslang_${VER}_amd64-debian.zip klauslang_${VER}_amd64.deb klauslang-teacher_${VER}_amd64.deb
zip klauslang_${VER}_x64-windows.zip klauslang_${VER}_x64.exe
