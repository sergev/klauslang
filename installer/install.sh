#!/bin/bash
#
# This will copy all necessary files into subdirectories
# of the specified root directory.
#
# Package name (either klauslang or klauslang-teacher) MUST be passed in $1.
#
# The root directory MAY be passed in $2.
# If not specified, defaults to the file system root.
#

set -e

if [[ -z "$1" ]]; then
  echo "Package name not specified."
  exit 1
fi

if [[ -n "$2" ]]; then
  INST=$(readlink -f $2)
  INST=${INST%/}
fi

case $1 in
  klauslang)
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

    mkdir -p $INST/usr
    rsync -r ../src/assets/klauslang/usr/ $INST/usr/

    mkdir -p $INST/usr/bin
    ln -s /opt/klauslang/amd64/klaus $INST/usr/bin/klaus
    ln -s /opt/klauslang/amd64/klaus-ide $INST/usr/bin/klaus-ide

    cp ../installer/what-s-new.txt $INST/opt/klauslang/
  ;;
  klauslang-teacher)
    mkdir -p $INST/opt/klauslang/amd64
    cp ../compiled/klaus-course-edit $INST/opt/klauslang/amd64/

    mkdir -p $INST/usr
    rsync -r ../src/assets/klauslang-teacher/usr/ $INST/usr/

    mkdir -p $INST/usr/bin
    ln -s /opt/klauslang/amd64/klaus-course-edit $INST/usr/bin/klaus-course-edit

    mkdir -p $INST/opt/klauslang/practicum
    cp -r ../practicum/*.zip $INST/opt/klauslang/practicum/
  ;;
  *)
    echo "invalid package name: $1".
    exit 1
  ;;
esac
