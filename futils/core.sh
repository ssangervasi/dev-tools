#!/bin/bash

cls() {
	clear
	pwd
	gitb || tree -L 1
}

YA_DUN_GOOFED=92

echo_error() {
	echo $@ 1>&2
	return YA_DUN_GOOFED
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
	return YA_DUN_GOOFED
}

empty() {
	if [[ $1 =~ ^[[:space:]]*$ ]]; then
		return 0
	fi
	return YA_DUN_GOOFED
}

tree_find() {
	local pattern=$1
	shift
	tree --prune -P $pattern $@
}

ls_modified() {
	local ref=$1
	if empty $ref; then
		ref='HEAD'
	fi
	git diff $ref --name-only --diff-filter=d
}
