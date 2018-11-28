#!/bin/bash

SPEC_HISTORY_PATH=~/.spec_history

SPEC_RSPEC_COMMAND='bundle exec rspec'
SPEC_RUBOCOP_COMMAND='bundle exec rubocop'

spec() {
	echo "Running: $SPEC_RSPEC_COMMAND"
	echo "With args: --format documentation $@"
	echo "" >> $SPEC_HISTORY_PATH
	echo "$@" >> $SPEC_HISTORY_PATH
	$SPEC_RSPEC_COMMAND --format documentation $@
}

read_spec_history() {
	local range_end=$1
	local spec_history;
	if empty $range_end; then
		spec_history=$(tail -n 1 $SPEC_HISTORY_PATH)
	elif [[ $range_end =~ [0-9]+
	 ]]; then
		echo 'digits'
		spec_history=$(tail -n $range_end $SPEC_HISTORY_PATH)
	elif [[ $range_end =~ all ]]; then
		spec_history=$(cat $SPEC_HISTORY_PATH)
	fi
	if empty $spec_history; then
		echo_error 'No spec history!'
		return $YA_DUN_GOOFED
	fi

	echo $spec_history
}

echo_spec_paths() {
	echo 'Found these spec paths:'
	ls -1 $1
}

respec() {
	spec_history=$(read_spec_history)
	if [[ $? > 0 ]]; then
		return $YA_DUN_GOOFED
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
		return $YA_DUN_GOOFED
	fi

	matches=$(find -X . -path $1)
	if empty $matches; then
		echo_error 'Error: no files match pattern!'
		return $YA_DUN_GOOFED
	fi

	echo_spec_paths $matches
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

	echo_spec_paths $modified_specs
	spec $modified_specs $@
}

modcop() {
	local modified_rbs=$(ls_modified_rbs $1)
	if empty $modified_rbs; then
		echo_error 'No modified ruby files.'
		return 0
	fi
	$SPEC_RUBOCOP_COMMAND $modified_rbs
}
