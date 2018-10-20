#!/bin/bash

SPEC_HISTORY_PATH=~/.spec_history

spec() {
	echo $@ > $SPEC_HISTORY_PATH
	bundle exec rspec --format documentation $@
}

read_spec_history() {
	spec_history=$(cat $SPEC_HISTORY_PATH)
	if empty $spec_history; then
		echo_error 'No spec history!'
		return YA_DUN_GOOFED
	fi

	echo $spec_history
}

respec() {
	spec_history=$(read_spec_history)
	if $_; then
		return YA_DUN_GOOFED
	fi

	echo 'Replaying spec:' $spec_history $@
	spec $spec_history $@
}

globspec() {
	usage='Usage: globspec */glob/pattern/*.txt
	=> run `spec` on all files matching the pattern
	Example:
		globspec *animals/*horse_spec.rb

	'
	if check_help $usage $@; then
		return 0
	fi
	if empty $@; then
		echo_error 'Error: must provide a pattern!'
		echo $usage
		return YA_DUN_GOOFED
	fi

	matches=$(find -X . -path $1)
	if empty $matches; then
		echo_error 'Error: no files match pattern!'
		return YA_DUN_GOOFED
	fi

	echo 'Running `spec` on these paths:'
	ls -1 $matches
	spec $matches
}

ls_modified_specs() {
	ls_modified $1 | grep "_spec\.rb$"
}

ls_modified_rbs() {
	ls_modified $1 | grep "\.rb$"
}

modspec() {
	ref=$1
	shift
	local modified_specs=$(ls_modified_specs $ref)
	if empty $modified_specs; then
		echo_error 'No modified spec files.'
		return 0
	fi

	echo "Running \"spec $@\" on these paths:"
	ls -1 $modified_specs
	spec $modified_specs $@
}

modcop() {
	local modified_rbs=$(ls_modified_rbs $1)
	if empty $modified_rbs; then
		echo_error 'No modified ruby files.'
		return 0
	fi
	bundle exec rubocop $modified_rbs
}
