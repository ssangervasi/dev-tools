
##
# Generic framework for specification testing and linting.
##

##
# Spec testing

SPEC_HISTORY_PATH=~/.spec_history
SPEC_HISTORY_SIZE='100'

spec() {
	local args=$(args_and_or_stdin $@ <&0)
	print_spec_header ${args}
	write_spec_history ${args}
	run_spec_command ${args}
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
	local new_entry="$@"
	local prev_entry=$(read_spec_history 1 &>/dev/null)
	if [[ "${new_entry}" == "${prev_entry}" ]]; then
		return 0
	fi
	echo "${new_entry}" >> $SPEC_HISTORY_PATH

	# Hacky file rotation
	local temp_path="${SPEC_HISTORY_PATH}.tmp"
	tail -n "$SPEC_HISTORY_SIZE" "$SPEC_HISTORY_PATH" > "${temp_path}"
	mv "${temp_path}" "$SPEC_HISTORY_PATH"
}

read_spec_history() {
	local range_end=$1
	local spec_history

	local out_path=$(mktemp)
	trap "rm ${out_path}" RETURN

	if empty $range_end; then
		tail -n 1 $SPEC_HISTORY_PATH > ${out_path}

	elif [[ $range_end =~ [0-9]+ ]]; then
		tail -n $range_end $SPEC_HISTORY_PATH > ${out_path}

	elif [[ $range_end =~ all ]]; then
		cat $SPEC_HISTORY_PATH > ${out_path}
	fi

	if [[ ! -s ${out_path} ]]; then
		echo_error 'No spec history!'
		return $YA_DUN_GOOFED
	fi

	cat ${out_path}
}

echo_paths() {
	echo 'Found these paths:'
	ls -1 $@
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
	check_help $@ && globspec_help && return 0

	if empty $@; then
		echo_error 'Error: must provide a pattern!'
		echo $usage
		return $YA_DUN_GOOFED
	fi

	local matches=$(find -X . -path $1)
	if empty ${matches}; then
		echo_error 'Error: no files match pattern!'
		return $YA_DUN_GOOFED
	fi

	echo_paths ${matches}
	spec ${matches}
}

globspec_help() {
	cat <<HELP_TEXT
Usage: globspec */glob/pattern/*.txt
	=> run \`spec\` on all files matching the pattern
Example:
	globspec *animals/*horse_spec.rb
HELP_TEXT
}

modspec() {
	local ref=$1
	shift
	local modified_specs=$(ls_modified_specs $ref)
	if empty $modified_specs; then
		echo_error 'No modified spec files.'
		return 0
	fi

	echo_paths $modified_specs
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
	local ref="$1"
	shift
	local modified_sources=$(ls_modified_sources ${ref})
	if empty $modified_sources; then
		echo_error 'No modified source files.'
		return 0
	fi

	echo_paths $modified_sources
	run_lint_command $modified_sources $@
}

ls_modified_sources() {
	# TODO: Come up with a better way of extending this pattern.
	ls_modified $1 | grep -E '^((Gemfile)|(.+[.])(hs|rb|py|js))$'
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
	SPEC_RSPEC_DEFAULT_ARGS="--format documentation --fail-fast"

	run_spec_command() {
		$SPEC_RSPEC_COMMAND $SPEC_RSPEC_DEFAULT_ARGS $@
	}

	print_spec_header() {
		echo "Running: $SPEC_RSPEC_COMMAND"
		echo "With args: $SPEC_RSPEC_DEFAULT_ARGS $@"
	}

	##
	# Linting with RuboCop

	SPEC_RUBOCOP_COMMAND='bundle exec rubocop'

	alias modcop="modlint"

	run_lint_command() {
		$SPEC_RUBOCOP_COMMAND $@
	}
}
