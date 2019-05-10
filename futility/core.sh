
YA_DUN_GOOFED=92

futility_log() {
	local log_path="$HOME/.futility/futility.log"
	mkdir -p $(dirname ${log_path})
	touch log_path || return $YA_DUN_GOOFED
	echo "$(date +'%D %T') | $@" >> ${log_path}
	# tail -n 1000 ${log_path} > ${log_path}
}

echo_error() {
	echo "$COLOR_RED""$@""$COLOR_NC" 1>&2
	return $YA_DUN_GOOFED
}

echo_success() {
	echo "$COLOR_GREEN""$@""$COLOR_NC" 1>&2
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
	local relative_path absolute_path
	relative_path="$1"

	go_there() {
		cd "$1" 2>>/dev/null && echo "$PWD"
	}

	absolute_path=$(go_there "${relative_path}")

	if empty "$absolute_path"; then
		return $YA_DUN_GOOFED
	fi
	echo "$absolute_path"
}

current_dir_command() {
  echo 'get_absolute_path $(dirname "$BASH_SOURCE")'
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
	local arg
	local args=()
	local use_stdin='no'
	for arg in "$@"; do
		if [[ ${arg} = '-' ]]; then
			use_stdin='yes'
		else
			args+=("${arg}")
		fi
	done

	if [[ ${use_stdin} != 'yes' ]]; then
		echo "${args[@]}"
		return 0
	fi

	local arg_line
	while read arg_line; do
		args+=("${arg_line}")
	done

	echo "${args[@]}"
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