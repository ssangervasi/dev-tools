
##
# Generic framework for specification testing and linting.
##

##
# Spec testing

SPEC_HISTORY_PATH=~/.spec_history
SPEC_HISTORY_SIZE='100'

spec() {
	read_to_arr $@ <&0
	local args="${READ_TO_ARR_RESULT[@]}"
	print_spec_header ${args}
	write_spec_history ${args}
	run_spec_command ${args}
}

write_spec_history() {
	local new_entry="$@"
	local prev_entry=$(tail -n 1 "$SPEC_HISTORY_PATH")
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
	local range_expr="${1:-all}"

	local in_path=$(mktemp)
	local out_path=$(mktemp)
	trap "rm ${out_path} ${in_path}" RETURN

	grep -n '.*' "${SPEC_HISTORY_PATH}" > "${in_path}"

	if [[ ${range_expr} =~ ^[0-9]+$ ]]; then
		range_expr="${range_expr}-${range_expr}"
	fi

	if [[ ${range_expr} =~ ^[0-9]+-[0-9]+$ ]]; then
		local range_start=$(sed -E s/-[0-9]+$// <<< "${range_expr}")
		local range_end=$(sed -E s/^[0-9]+-// <<< "${range_expr}")
		(sed -n "${range_start},${range_end}p" < "${in_path}") > "${out_path}"
	elif [[ ${range_expr} =~ .+,.+$ ]]; then
		(sed -n "${range_expr}p" < "${in_path}") > "${out_path}"
	elif [[ ${range_expr} =~ all ]]; then
		cat "${in_path}" > "${out_path}"
	elif [[ ${range_expr} =~ last ]]; then
		tail -n 1 "${in_path}" > "${out_path}"
	else
		echo_error "Invalid history range: '${range_expr}'"
	fi

	if [[ ! -s "${out_path}" ]]; then
		echo_error 'No history in range.'
		return $YA_DUN_GOOFED
	fi

	cat "${out_path}"
}

trim_line_num() {
	read_to_stdout $@ <&0 | sed -E 's/^[0-9]+://'
}

respec() {
	local range_expr="${1:-last}"
	shift

	local replay_line=$(spec_history "${range_expr}")
	if [[ $? > 0 ]]; then
		return $YA_DUN_GOOFED
	fi

	replay_line=$(trim_line_num - <<< "${replay_line}")

	echo 'Replaying spec:' ${replay_line} $@
	spec ${replay_line} $@
}


_complete_spec_history() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	local match_array=($(spec_history 10 2>/dev/null | grep -E "${current_word}"))
	# local history_array=($(spec_history 10 2>/dev/null))
	# local match_array=($(compgen -W "${history_array[*]}" "${current_word}"))

	if (( ${#match_array[@]} > 0 )); then
		COMPREPLY=(${match_array[@]})
	else
		COMPREPLY=(
			$(compgen -o default "${current_word}")
		)
	fi

	# FUTILITY_LOG_LEVEL='debug'
	# futility_log "history_array"
	# futility_log "${#history_array[@]} | ${history_array[@]}"
	# futility_log "Match array"
	# futility_log "${#match_array[@]} | ${match_array[@]}"
	# futility_log "COMPREPLY"
	# futility_log "${COMPREPLY[@]}"
	# futility_log "current_word"
	# futility_log "${current_word}"
}

complete -o bashdefault -F _complete_spec_history spec

echo_paths() {
	echo 'Found these paths:'
	ls -1 $@
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
	grep -E '^((Gemfile)|(.+[.])(hs|rb|py|js|ts|tsx|go))$'
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
	SPEC_RSPEC_DEFAULT_ARGS="--format documentation"

	# I'm not a fan of the retry gem...
	export RSPEC_RETRY_RETRY_COUNT=0

	run_spec_command() {
		$SPEC_RSPEC_COMMAND \
			$SPEC_RSPEC_DEFAULT_ARGS \
			$SPEC_RSPEC_FAIL_FAST \
			$SPEC_RSPEC_TAG_FOCUS \
			"$@"
	}

	print_spec_header() {
		echo "Running: $SPEC_RSPEC_COMMAND $SPEC_RSPEC_DEFAULT_ARGS $SPEC_RSPEC_FAIL_FAST $SPEC_RSPEC_TAG_FOCUS"
		echo "With args: $@"
	}

	spec_rspec_use_spring() {
		SPEC_RSPEC_COMMAND='bundle exec spring rspec'
	}

	fail_fast() {
		SPEC_RSPEC_FAIL_FAST='--fail-fast'
	}

	no_fail_fast() {
		SPEC_RSPEC_FAIL_FAST='--no-fail-fast'
	}

	tag_focus() {
		SPEC_RSPEC_TAG_FOCUS='--tag=focus'
	}

	no_tag_focus() {
		SPEC_RSPEC_TAG_FOCUS=''
	}

	fail_fast

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
	alias pe='pipenv'

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
