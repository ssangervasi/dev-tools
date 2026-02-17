
##
# Scan directories for `{PROJ}/activate.sh` files and automatically define
# `intit_project_{PROJ}` functions for them.
mercator_scan() {
	local scan_root="$1"

	read_fd_lines_to_arr <(
		find "$scan_root" -maxdepth 3  -name "activate.sh"
	)

	local script_paths=("${READ_TO_ARR_RESULT[@]}")
	for script_path in "${script_paths[@]}"; do
		proj_path=$(dirname "$script_path")
		if [[ $(basename "$proj_path") = "bin" ]]; then
			proj_path=$(dirname $(dirname "$script_path"))
		fi
		proj_name=$(basename "$proj_path")
		echo "$proj_name"
		echo "$proj_path"
	done
}



read_fd_lines_to_arr() {
	READ_TO_ARR_RESULT=()
	local arg="$1"
	local line
	if [[ -r "$arg" ]]; then
		exec 3<"$arg"

		while read -u 3 line; do
			READ_TO_ARR_RESULT+=("${line}")
		done
	fi
}

mercator_scan ~/workspace
