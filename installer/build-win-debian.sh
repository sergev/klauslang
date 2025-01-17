#!/bin/bash
#
# Requires: Ubuntu (>= 22.04)
#
# This will build klauscon.lpi, klauside.lpi and klauscourseedit.lpi for Ubuntu and Win10,
# build DEB packages, make Windows installer and ZIP them all.
#
# Version number MAY be passed in $1 -- the new version will be set for all the projects.
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

mkdir -p ../compiled
mkdir -p ../build && cd ../build

if [ -d "v$VER" ]; then
  echo "Directory already exists: build/v$VER"
  exit 1
fi
mkdir v$VER

###################################
# Build Lazarus projects
###################################

mkdir -p ../compiled/klauscon/x86_64-linux
mkdir -p ../compiled/klauscon/x86_64-win64
lazbuild --build-all --build-mode=Release ../src/klaus/klauscon.lpi
lazbuild --build-all --build-mode=Win64 ../src/klaus/klauscon.lpi

mkdir -p ../compiled/klauside/x86_64-linux
mkdir -p ../compiled/klauside/x86_64-win64
lazbuild --build-all --build-mode=Release ../src/ide/klauside.lpi
lazbuild --build-all --build-mode=Win64 ../src/ide/klauside.lpi

mkdir -p ../compiled/klauscourseedit/x86_64-linux
mkdir -p ../compiled/klauscourseedit/x86_64-win64
lazbuild --build-all --build-mode=Release ../src/course-edit/klauscourseedit.lpi
lazbuild --build-all --build-mode=Win64 ../src/course-edit/klauscourseedit.lpi

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
# DEBIAN package klauslang
###################################

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
cp -r ../../practicum/*.klaus-course ./opt/klauslang/practicum/

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

###################################
# DEBIAN package klauslang-teacher
###################################

mkdir "$BD2" && cd "$BD2"

mkdir -p ./opt/klauslang/amd64
cp ../../compiled/klaus-course-edit ./opt/klauslang/amd64/

mkdir ./usr
rsync -r ../../src/assets/klauslang-teacher/usr/ ./usr/

mkdir -p ./usr/bin
ln -s /opt/klauslang/amd64/klaus-course-edit ./usr/bin/klaus-course-edit

mkdir -p ./opt/klauslang/practicum
cp -r ../../practicum/*.zip ./opt/klauslang/practicum/

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
# cp ../../compiled/klauslang-${VER}-1.x86_64.rpm ./
# cp ../../compiled/klauslang-teacher-${VER}-1.x86_64.rpm ./
# zip klauslang-${VER}-1.x86_64-alt.zip klauslang-${VER}-1.x86_64.rpm klauslang-teacher-${VER}-1.x86_64.rpm
zip klauslang_${VER}_amd64-debian.zip klauslang_${VER}_amd64.deb klauslang-teacher_${VER}_amd64.deb
zip klauslang_${VER}_x64-windows.zip klauslang_${VER}_x64.exe
