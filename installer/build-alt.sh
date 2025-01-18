#!/bin/bash

set -e
set -u

VER=$(cat ../src/ver)
TOP=$(rpmbuild --eval %{_topdir})
TOP=${TOP/'%homedir'/"$HOME"}

echo $TOP

cd ..

mkdir -p $TOP/SOURCES
rm -f $TOP/SOURCES/klauslang-$VER.tar.bz2
tar --exclude='.git*' --exclude='./compiled' --exclude='./build' -cjvf $TOP/SOURCES/klauslang.tar.bz2 .

cd ./installer

rpmbuild -bb --define "_ver $VER" klauslang-alt.spec
