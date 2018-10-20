#!/bin/bash

FUTILITY_PACKAGE_ROOT=$(dirname $BASH_SOURCE)

source $FUTILITY_PACKAGE_ROOT/core.sh

FUTILITY_PACKAGE_ROOT=$(current_dir)

source $FUTILITY_PACKAGE_ROOT/promptimal.sh
source $FUTILITY_PACKAGE_ROOT/speccial.sh
source $FUTILITY_PACKAGE_ROOT/deepthonk.sh

add_to_path $FUTILITY_PACKAGE_ROOT/bin
