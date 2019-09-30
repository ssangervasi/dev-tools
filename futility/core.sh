
YA_DUN_GOOFED=92

futility_log() {
	if [[ -z "$FUTILITY_LOG_LEVEL" ]]; then
		return 0
	fi

	local log_path="$HOME/.futility/futility.log"
	mkdir -p $(dirname ${log_path})
	touch "${log_path}" || return $YA_DUN_GOOFED
	echo "$(date +'%D %T') | $FUTILITY_LOG_LEVEL | $@" >> ${log_path}
	# tail -n 1000 ${log_path} > ${log_path}
}

echo_error() {
	local echo_prefix=${ECHO_PREFIX:-'‼ '}
	echo "${COLOR_RED}${echo_prefix}$@${COLOR_NC}" 1>&2
	return $YA_DUN_GOOFED
}

echo_info() {
	local echo_prefix=${ECHO_PREFIX:-'♾  '}
	echo "${COLOR_YELLOW}${echo_prefix}$@${COLOR_NC}" 1>&2
	return 0
}

echo_success() {
	local echo_prefix=${ECHO_PREFIX:-'✅ '}
	echo "${COLOR_GREEN}${echo_prefix}$@${COLOR_NC}" 1>&2
	return 0
}

default() {
	local default_value=''
	while empty "$default_value"; do
		default_value="$1"
		shift
	done
	echo "$default_value"
}

empty() {
	if [[ $1 =~ ^[[:space:]]*$ ]]; then
		return 0
	fi
	return $YA_DUN_GOOFED
}

add_to_path() {
	local path_dir abs_path_dir
	for path_dir in "$@"; do
		abs_path_dir=$(get_absolute_path "$path_dir")
		if [[ -d "${abs_path_dir}" ]]; then
			export PATH="${abs_path_dir}:$PATH" &&
				futility_log "add_to_path: Added '${path_dir}' as '${abs_path_dir}'"
		else
			futility_log "add_to_path: Error with '${path_dir}' as '${abs_path_dir}'"
		fi
	done
}

get_absolute_path()  {
	local relative_path="$1"
	local absolute_path=$(
		cd "${relative_path}" 2>/dev/null &&
			echo "$PWD"
	)

	if empty "${absolute_path}"; then
		return $YA_DUN_GOOFED
	fi
	echo "${absolute_path}"
}

current_dir_command() {
  echo 'get_absolute_path $(dirname "$BASH_SOURCE")'
}

check_help_help() {
	<<-HELP_TEXT
		Returns success (0) if any argument matches '-h' or '--help'.
		Returns failure (>0) otherwise.
	HELP_TEXT
}

check_help() {
	local args="$@"
	local help_pattern='^(-h|--help)$'
	local arg
	for arg in $args; do
		if [[ $arg =~ ${help_pattern} ]]; then
			return 0
		fi
	done
	return $YA_DUN_GOOFED
}

stacktrace() {
	echo_error "~~ Begin Stacktrace: $* ~~"
	local frame=0
	while caller $frame; do
		((frame++));
	done
	echo_error "~~ End Stacktrace: $* ~~"
}

# This is pretty dang limited, but it's been helpful.
# 	It doesn't handle special characters, so arrows keys
# 	for navigation doesn't work.
breakpoint() {
	echo "~~ Begin Breakpoint: $* ~~"
	echo -n '> '
	while read cmd; do
		eval "$cmd"
		echo -n '> '
	done
	echo "~~ End Breakpoint $* ~~"
}

is_defined() {
	type -t "$1" &>/dev/null &&
		return 0 ||
		return 1
}

find_func() {
	local fn_name="$1"
	# Turn on extended shell debugging
	shopt -s extdebug
	# Turn off extended shell debugging on return
	trap 'shopt -u extdebug' EXIT
	# Dump the function's name, line number and fully qualified source file
	local fn_dec=$(declare -F ${fn_name})
	if [[ -n ${fn_dec} ]]; then
		echo ${fn_dec}
		return 1
	fi

	local alias_dec=$(alias ${fn_name} 2>/dev/null)
	if [[ -z ${alias_dec} ]]; then
		echo_error "No function or alias named '${fn_name}'"
		return 1
	fi

	echo ${alias_dec}
}

source_if_exists() {
	local file_path="$1"
	if [[ -f "${file_path}" ]]; then
		source "${file_path}" &&
			futility_log "source_if_exists: Sourced ${file_path}"
	else
		futility_log "source_if_exists: Error with ${file_path}"
		return $YA_DUN_GOOFED
	fi
	return 0
}

args_and_or_stdin() {
	ARGS_AND_OR_STDIN_RESULT=()
	local arg
	local use_stdin='no'
	for arg in "$@"; do
		if [[ ${arg} = '-' ]]; then
			use_stdin='yes'
		else
			ARGS_AND_OR_STDIN_RESULT+=("${arg}")
		fi
	done

	if [[ ${use_stdin} != 'yes' ]]; then
		echo "${ARGS_AND_OR_STDIN_RESULT[@]}"
		return 0
	fi

	local arg_line
	while read arg_line; do
		ARGS_AND_OR_STDIN_RESULT+=("${arg_line}")
	done

	echo "${ARGS_AND_OR_STDIN_RESULT[@]}"
}

args_and_or_stdin_help() {
	cat <<-HELP_TEXT
		Example:
			my_util() {
				local args=$(args_and_or_stdin $@ - <&0)
				echo ${args} | sed -E 's/[ ]/<space>/g'
			}

			echo 'a horse' 'is a horse' |
				my_util 'is a horse' 'of course'
			# > is<space>a<space>horse<space>of<space>course<space>a<space>horse<space>is<space>a<space>horse
	HELP_TEXT
}