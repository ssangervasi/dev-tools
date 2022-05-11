
_complete_ticket() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"

	if (( $COMP_CWORD == 1 )); then
		COMPREPLY=(
		  $(compgen -W "$(ticket _commands)" "${current_word}")
		)
	elif (( $COMP_CWORD >= 2 )); then
		if [[ "${COMP_WORDS[1]}" == switch ]]; then
			_complete_ticket_switch
		fi
	fi
	# COMPREPLY+=("COMP_TYPE '$COMP_TYPE'")
}
complete -o bashdefault -F _complete_ticket ticket

_complete_ticket_switch() {
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