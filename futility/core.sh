#!/bin/bash

YA_DUN_GOOFED=92

echo_error() {
	echo $@ 1>&2
	return $YA_DUN_GOOFED
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
			export PATH="${abs_path_dir}:$PATH"
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
	local usage=$1
	shift
	local help_pattern='^(-h|--help)$'
	local arg
	for arg in $args; do
		if [[ $1 =~ $help_pattern ]]; then
			echo $usage
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

source_if_exists() {
	local file_path="$1"
	local else_log="$2"
	if [[ -f "$file_path" ]]; then
		source "$file_path"
	elif [[ "$else_log" =~ ^-l|--log$ ]]; then
		echo_error "Could not source $file_path"
		return $YA_DUN_GOOFED
	fi
	return 0
}
