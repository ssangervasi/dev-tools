#!/bin/bash

##
# Generic framework for specification testing and linting.
##

## 
# Spec testing 

SPEC_HISTORY_PATH=~/.spec_history

spec() {
	print_spec_header $@
	write_spec_history $@
	run_spec_command $@
}

print_spec_header() {
	echo "Running: run_spec_command"
	echo "With args: $@"
}

run_spec_command() {
	echo_error 'You need to implement a "run_spec_command" function!'
	return $YA_DUN_GOOFED
}

write_spec_history() {
	echo "" >> $SPEC_HISTORY_PATH
	echo "$@" >> $SPEC_HISTORY_PATH
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

modspec() {
	local ref=$1
	shift
	local modified_specs=$(ls_modified_specs $ref)
	if empty $modified_specs; then
		echo_error 'No modified spec files.'
		return 0
	fi

	echo_spec_paths $modified_specs
	spec $modified_specs $@
}

ls_modified_specs() {
	ls_modified $1 | grep -E "(^(Test|Spec)|.+(_spec|_test)[.].+)"
}

##
# Linting

lint() {
	run_lint_command "$@"
}

modlint() {
	local modified_sources=$(ls_modified_sources $1)
	if empty $modified_sources; then
		echo_error 'No modified source files.'
		return 0
	fi
	run_lint_command $modified_sources
}

ls_modified_sources() {
	ls_modified $1 | grep -E ".+[.](hs|rb|py|js)$"
}

run_lint_command() {
	echo_error 'You need to implement a "run_lint_command" function!'
	return $YA_DUN_GOOFED
}

##
# Ruby w/ RSpec & RuboCop spec plugin implementation.
##

load_ruby_speccial_plugin() {
	##
	# Tests with RSpec

	SPEC_RSPEC_COMMAND='bundle exec rspec'

	run_spec_command() {
		$SPEC_RSPEC_COMMAND --format documentation $@
	}

	##
	# Linting with RuboCop

	SPEC_RUBOCOP_COMMAND='bundle exec rubocop'

	alias modcop="modlint"

	run_lint_command() {
		$SPEC_RUBOCOP_COMMAND $@
	}
}
