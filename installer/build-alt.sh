#!/bin/bash

# Version number must be passed in $1
# Compiled binaries must exist in ../compiled

set -e
set -u

VER="$1"

rpmbuild -bb --define "_ver $VER" --define "_pwd $(pwd)" klauslang-alt.spec
rpmbuild -bb --define "_ver $VER" --define "_pwd $(pwd)" klauslang-teacher-alt.spec