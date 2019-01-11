#!/bin/bash

load_futility_package() {
  FUTILITY_PACKAGE_ROOT=$(dirname $BASH_SOURCE)

  source $FUTILITY_PACKAGE_ROOT/core.sh

  FUTILITY_PACKAGE_ROOT=$(current_dir)
  FUTILITY_PACKAGE_LIB="$FUTILITY_PACKAGE_ROOT/lib"

  load_futility_bin
  load_futility_lib
}

load_futility_lib() {
  local lib_file
  for lib_file in $(ls "$FUTILITY_PACKAGE_LIB"); do
    source_if_exists "$FUTILITY_PACKAGE_LIB/$lib_file" --log
  done
}

load_futility_bin() {
  add_to_path $FUTILITY_PACKAGE_ROOT/bin
}

load_futility_package
