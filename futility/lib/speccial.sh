
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

write_spec_history() {
	local new_entry="$@"
	local prev_entry=$(spec_history 1 2>/dev/null)
	if [[ "${new_entry}" == "${prev_entry}" ]]; then
		return 0
	fi
	echo "${new_entry}" >> $SPEC_HISTORY_PATH

	# Hacky file rotation
	local temp_path="${SPEC_HISTORY_PATH}.tmp"
	tail -n "$SPEC_HISTORY_SIZE" "$SPEC_HISTORY_PATH" > "${temp_path}"
	mv "${temp_path}" "$SPEC_HISTORY_PATH"
}

spec_history() {
	local range_end="$1"

	local out_path=$(mktemp)
	trap "rm ${out_path}" RETURN

	if [[ ${range_end} =~ [0-9]+ ]]; then
		tail -n ${range_end} $SPEC_HISTORY_PATH > ${out_path}
	elif [[ -z ${range_end} || ${range_end} =~ all ]]; then
		cat $SPEC_HISTORY_PATH > ${out_path}
	else
		echo_error "Invalid history range: '${range_end}'"
	fi

	if [[ ! -s ${out_path} ]]; then
		echo_error 'No spec history!'
		echo_error "Expected it to be present in: '$SPEC_HISTORY_PATH'"
		return $YA_DUN_GOOFED
	fi

	cat ${out_path}
}

echo_paths() {
	echo 'Found these paths:'
	ls -1 $@
}

respec() {
	local last_spec=$(spec_history 1)
	if [[ $? > 0 ]]; then
		return $YA_DUN_GOOFED
	fi

	echo 'Replaying spec:' $last_spec $@
	spec $last_spec $@
}


_complete_spec_history() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"

	# Allows using file paths instead of history completion.
	if [[ ${current_word} =~ ^(/|\./|~/) ]]; then
		COMPREPLY=(
			$(compgen -o default "${current_word}")
		)
		return 0
	fi

	COMPREPLY=(
		$(compgen -W "$(spec_history 10)" "${current_word}")
	)
}

complete -F _complete_spec_history spec

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
	cat <<-HELP_TEXT
		Usage: globspec */glob/pattern/*.txt
			=> run \`spec\` on all files matching the pattern
		Example:
			globspec *animals/*horse_spec.rb
	HELP_TEXT
}

ls_modified() {
	local ref=${1:-HEAD}
	git diff $ref --name-only --diff-filter=d
}

modspec() {
	local ref=$1
	shift
	local modified_specs=$(ls_modified ${ref} | select_spec_paths)
	if empty $modified_specs; then
		echo_error 'No modified spec files.'
		return 0
	fi

	echo_paths $modified_specs
	spec $modified_specs $@
}

##
# Linting

lint() {
	run_lint_command $@
}

modlint() {
	local ref="$1"
	shift
	local modified_sources=$(ls_modified ${ref} | select_lint_paths)
	if empty $modified_sources; then
		echo_error 'No modified source files.'
		return 0
	fi

	echo_paths $modified_sources
	run_lint_command $modified_sources $@
}

##
# Default methods that can be overridded by plugins
# TODO: How can I make a clean API for plugging these things?

print_spec_header() {
	echo "Running: run_spec_command"
	echo "With args: $@"
}

run_spec_command() {
	echo_error 'You need to implement a "run_spec_command" function!'
	return $YA_DUN_GOOFED
}

select_spec_paths() {
	grep -E "(^(Test|Spec)|.+(_spec|_test)[.].+)"
}

select_lint_paths() {
	grep -E '^((Gemfile)|(.+[.])(hs|rb|py|js))$'
}

run_lint_command() {
	echo_error 'You need to implement a "run_lint_command" function!'
	return $YA_DUN_GOOFED
}

##
# Ruby w/ Bundler, RSpec, & RuboCop plugin implementation.
##

load_ruby_speccial_plugin() {
	##
	# Tests with RSpec

	SPEC_RSPEC_COMMAND='bundle exec rspec'
	SPEC_RSPEC_DEFAULT_ARGS="--format documentation --fail-fast"

	# I'm not a fan of the retry gem...
	export RSPEC_RETRY_RETRY_COUNT=0

	run_spec_command() {
		$SPEC_RSPEC_COMMAND $SPEC_RSPEC_DEFAULT_ARGS $@
	}

	print_spec_header() {
		echo "Running: $SPEC_RSPEC_COMMAND"
		echo "With args: $SPEC_RSPEC_DEFAULT_ARGS $@"
	}

	use_spring() {
		SPEC_RSPEC_COMMAND='bundle exec spring rspec'
	}

	##
	# Linting with RuboCop

	SPEC_RUBOCOP_COMMAND='bundle exec rubocop'

	alias modcop="modlint"

	run_lint_command() {
		$SPEC_RUBOCOP_COMMAND $@
	}
}

##
# Pyton w/ Pipenv, Pytest, Flake8 plugin implementation.
##

load_python_speccial_plugin() {
	run_spec_command() {
		pipenv run pytest $@
	}

	print_spec_header() {
		echo "Running: pipenv run pytest "
		echo "With args: $@"
	}

	run_lint_command() {
		pipenv run flake8 $@
	}
}
