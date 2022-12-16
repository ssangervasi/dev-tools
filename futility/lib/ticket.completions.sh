
_complete_ticket() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"

	if (( $COMP_CWORD == 1 )); then
		COMPREPLY=(
		  $(compgen -W "$(ticket _commands)" "${current_word}")
		)
	elif (( $COMP_CWORD >= 2 )); then
		if [[ "${COMP_WORDS[1]}" == new ]]; then
			return
			# _complete_ticket_new
		else
			_complete_ticket_name
		fi
	fi
	# COMPREPLY+=("COMP_TYPE '$COMP_TYPE'")
}
complete -o bashdefault -F _complete_ticket ticket

_complete_ticket_name() {
	if (( $COMP_CWORD >= 3 )); then
		return
	fi

	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	# COMPREPLY=($(ticket hist 10))
	local hist_arr=($(ticket hist 10))
	for entry in "${hist_arr[@]}"; do
		# COMPREPLY+=("$entry")
		if [[ "$entry" =~ .*"$current_word".* ]]; then
			COMPREPLY+=("$entry # $(ticket desc -t $entry 2>/dev/null)")
		fi
	done

	if (( ${#COMPREPLY[@]} == 1 )); then
		__complete__strip_comments
	fi
}


__complete__strip_comments() {
	for i in "${!COMPREPLY[@]}"; do
		v="${COMPREPLY[$i]}"
		COMPREPLY[$i]="${v/' #'*/}"
	done
}


_complete_ticket_new() {
	if (( $COMP_CWORD >= 3 )); then
		return
	fi

	local current_word="${COMP_WORDS[$COMP_CWORD]}"

	local gh_issues=($(
		gh issue list --assignee "@me" --json title,number --jq '.[] | [.title, .number]'
	))
	for entry in "${gh_issues[@]}"; do
		local n=$(sed -E 's/,?.?"([0-9]+).+/\1/' <<<$entry)
		COMPREPLY+=("$n")
		# if [[ "$n" =~ .*"$current_word".* ]]; then
		# fi
	done

	if (( ${#COMPREPLY[@]} == 1 )); then
		__complete__strip_comments
	fi
}