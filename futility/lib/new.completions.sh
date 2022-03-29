complete -o bashdefault -F _complete_new new

_complete_new() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	local previous_word="${COMP_WORDS[$COMP_CWORD - 1]}"

	# echo_error "pw ${previous_word}"

	if (( "$COMP_CWORD" <= 1 )); then
		COMPREPLY=(
			$(printf '%s\n' "$(_command_names)" | grep -E "${current_word}")
		)
		return
	fi
	
	if [[ "${previous_word}" == "branch" ]]; then
		COMPREPLY=(
			ssangervasi/
			ssangervasi/ticket/description
		)
		return
	fi

	COMPREPLY=(
		$(compgen -o default "${current_word}")
	)
}

_command_names() {
	cat <<-COMMAND_NAMES
		directory
		dir
		directories
		dirs
		file
		branch
	COMMAND_NAMES
}