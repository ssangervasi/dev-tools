#!/bin/bash

export FUTILITY_VERSION='0.1.2'

load_futility_package() {
  FUTILITY_PACKAGE_ROOT=$(dirname $BASH_SOURCE)

  FUTILITY_PACKAGE_CORE="$FUTILITY_PACKAGE_ROOT/core.sh"
  source "$FUTILITY_PACKAGE_CORE"

  FUTILITY_PACKAGE_ROOT=$(eval $(current_dir_command))
  FUTILITY_PACKAGE_LIB="$FUTILITY_PACKAGE_ROOT/lib"

  load_futility_bin
  load_futility_lib
}

load_futility_lib() {
  # Yes this tempfile deal is hacky,
  #   but handles files with spaces and other odd things.
  local lib_file_list=$(mktemp)
  ls -1 "$FUTILITY_PACKAGE_LIB" | grep '.sh' > ${lib_file_list}

  local lib_file
  while read lib_file; do
    source_if_exists "$FUTILITY_PACKAGE_LIB/$lib_file" --log
  done < ${lib_file_list}
  rm ${lib_file_list}
}

load_futility_bin() {
  FUTILITY_PACKAGE_BIN="$FUTILITY_PACKAGE_ROOT/bin"
  add_to_path "$FUTILITY_PACKAGE_BIN"
}

futility_help() {
  format_contents() {
    ls -1F $1 | sed 's/^/    /'
  }

  cat <<HELP_TEXT
futility v${FUTILITY_VERSION}

Paths used by this package:
  FUTILITY_PACKAGE_ROOT : $FUTILITY_PACKAGE_ROOT/
  FUTILITY_PACKAGE_LIB  : $FUTILITY_PACKAGE_LIB/
  FUTILITY_PACKAGE_BIN  : $FUTILITY_PACKAGE_BIN/

Lib contents:
$(format_contents $FUTILITY_PACKAGE_LIB)

Bin contents:
$(format_contents $FUTILITY_PACKAGE_BIN)

HELP_TEXT
}

load_futility_package
