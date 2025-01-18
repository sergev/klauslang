#!/bin/bash
#
# This will copy all necessary files into subdirectories
# of the specified root directory.
#
# The root directory MAY be passed in $1.
# If not specified, defaults to the filesystem root.
#

set -e

if [[ -n "$1" ]]; then
  INST=$(readlink -f $1)
  INST=${INST%/}
fi

mkdir -p $INST/opt/klauslang/amd64
cp ../compiled/klaus $INST/opt/klauslang/amd64/
cp ../compiled/klaus-ide $INST/opt/klauslang/amd64/

mkdir -p $INST/opt/klauslang/samples
cp -r ../samples/* $INST/opt/klauslang/samples/

mkdir -p $INST/opt/klauslang/test
cp -r ../test/* $INST/opt/klauslang/test/

mkdir -p $INST/opt/klauslang/doc
cp -r ../doc/* $INST/opt/klauslang/doc/

mkdir -p $INST/opt/klauslang/practicum
cp -r ../practicum/*.klaus-course $INST/opt/klauslang/practicum/

mkdir $INST/usr
rsync -r ../src/assets/klauslang/usr/ $INST/usr/

mkdir -p $INST/usr/bin
ln -s $INST/opt/klauslang/amd64/klaus $INST/usr/bin/klaus
ln -s $INST/opt/klauslang/amd64/klaus-ide $INST/usr/bin/klaus-ide

cp ../installer/what-s-new.txt $INST/opt/klauslang/
