
FUTILITY_VERSION='0.1.2'

futility_load_package() {
	FUTILITY_PACKAGE_ROOT=$(dirname $BASH_SOURCE)

	FUTILITY_PACKAGE_CORE="$FUTILITY_PACKAGE_ROOT/core.sh"
	source "$FUTILITY_PACKAGE_CORE"

	FUTILITY_PACKAGE_ROOT=$(eval $(current_dir_command))
	FUTILITY_PACKAGE_LIB="$FUTILITY_PACKAGE_ROOT/lib"

	futility_load_bin
	futility_load_lib
}

futility_load_lib() {
	local lib_file
	for lib_file in "$FUTILITY_PACKAGE_LIB"/*.sh; do
		source_if_exists ${lib_file}
	done
}

futility_load_bin() {
	FUTILITY_PACKAGE_BIN="$FUTILITY_PACKAGE_ROOT/bin"
	add_to_path "$FUTILITY_PACKAGE_BIN"
}

futility_help() {
	format_contents() {
		ls -1F $1 | sed 's/^/    /'
	}

	cat <<-HELP_TEXT
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

futility_load_package
