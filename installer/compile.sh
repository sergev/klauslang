#!/bin/bash
#
# Requires: Ubuntu (>= 22.04) or ALT Education (>= 10.4)
#
# This will compile klauscon.lpi, klauside.lpi and klauscourseedit.lpi.
#
# Build target (either Linux or Windows) MUST be passed in $1.
# Version number (e.g. 1.2.3) MAY be passed in $2 -- if so, the new version will be set for all the projects.
#
# lazbuild (>= 3.4) must exist on the path

set -e

if [[ -z "$1" ]]; then
  echo "Please specify build target: either Linux or Windows"
  exit 1
fi

if [[ -n "$2" ]]; then
  VER=$2
  ./set-version.sh $VER
else
  VER=$(cat ../src/ver)
fi

set -u

case $1 in
  Linux)
    mkdir -p ../compiled/klauscon/x86_64-linux
    mkdir -p ../compiled/klauside/x86_64-linux
    mkdir -p ../compiled/klauscourseedit/x86_64-linux
    lazbuild --build-all --build-mode=Release ../src/klaus/klauscon.lpi
    lazbuild --build-all --build-mode=Release ../src/ide/klauside.lpi
    lazbuild --build-all --build-mode=Release ../src/course-edit/klauscourseedit.lpi
  ;;
  Windows)
    mkdir -p ../compiled/klauscon/x86_64-win64
    mkdir -p ../compiled/klauside/x86_64-win64
    mkdir -p ../compiled/klauscourseedit/x86_64-win64
    lazbuild --build-all --build-mode=Win64 ../src/klaus/klauscon.lpi
    lazbuild --build-all --build-mode=Win64 ../src/ide/klauside.lpi
    lazbuild --build-all --build-mode=Win64 ../src/course-edit/klauscourseedit.lpi
  ;;
  *)
    echo "Invalid build target: $1."
    exit 1
  ;;
esac
