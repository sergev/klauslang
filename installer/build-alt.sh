#!/bin/bash
#
# Requires: ALT Linux (>= 10.4)
#
# This will create a source tarball and build RPM packages for ALT Linux.
# rpm --eval %{_topdir} must return a sane RPM top directory.
#
# Make sure you have checked out the correct branch (e.g. git checkout v2.5.8)
#

set -e
set -u

VER=$(cat ../src/ver)
TOP=$(rpm --eval %{_topdir})

mkdir -p $TOP/SPECS
cat <(echo 'Version: ' | tr -d '\n') ../src/ver klauslang-alt.spec > $TOP/SPECS/klauslang-$VER.spec

cd ..

mkdir -p $TOP/SOURCES
rm -f $TOP/SOURCES/klauslang.tar.bz2
tar --exclude='.git*' --exclude='./compiled' --exclude='./build' -cjvf $TOP/SOURCES/klauslang.tar.bz2 .

cd ./installer

rpmbuild -ba --define "_ver $VER" $TOP/SPECS/klauslang-$VER.spec
