read_to_arr_help() {
	cat <<-HELP_TEXT
		usage: read_to_arr [<left_params>...] [ - ] [<right_params>...]
		
		Read parameters into an array. The results are available in varable
		named "READ_TO_ARR_RESULT". No other output is produced. Any parameters
		equal to "-" after the first are inserted as-is.

		<left_params> : Any number of parameters insert before stdin lines. 
		- : If present, write each line of stdin after writing left_params.
		<right_params> : Any number of parameters insert after stdin lines.

		Example:
			$ read_to_arr horse - "small cow" - "'medium moose'" <<<"big dog"
			$ for i in {0..4}; do echo "${READ_TO_ARR_RESULT[$i]}"; done
			> horse
			> big dog
			> small cow
			> -
			> 'medium moose'
	HELP_TEXT
}

read_to_arr() {
	READ_TO_ARR_RESULT=()

	local arg
	local stdin_used=1

	for arg in "$@"; do
		if [[ "${arg}" = '-' ]] && (( 0 < "${stdin_used}" )); then
			stdin_used=0
			local arg_line
			while read arg_line; do
				READ_TO_ARR_RESULT+=("${arg_line}")
			done
		else
			READ_TO_ARR_RESULT+=("${arg}")
		fi
	done

	return 0
}

read_to_stdout_help() {
	cat <<-HELP_TEXT
		usage: read_to_stdout [<left_params>...] [ - ] [<right_params>...]
		
		Read parameters and/or stdin to stdout. Each entry is written to its own line.
		Any parameters equal to "-" after the first are written as-is.

		<left_params> : Any number of parameters to write before stdin lines. 
		- : If present, write each line of stdin after writing left_params.
		<right_params> : Any number of parameters to write after stdin lines.

		Example:
			$ read_to_stdout horse - "small cow" - "'medium moose'" <<<"big dog"
			> horse
			> big dog
			> small cow
			> -
			> 'medium moose'
	HELP_TEXT
}

read_to_stdout() {
	local arg
	local stdin_used=1

	for arg in "$@"; do
		if [[ "${arg}" = '-' ]] && (( 0 < "${stdin_used}" )); then
			stdin_used=0
			cat <&0
		else
			echo "${arg}"
		fi
	done
}
