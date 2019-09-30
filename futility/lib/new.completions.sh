complete -o bashdefault -F _complete_new new

_complete_new() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"

	if (( "$COMP_CWORD" > 1 )); then
		COMPREPLY=(
			$(compgen -o default "${current_word}")
		)
		return
	fi
	COMPREPLY=(
		$(printf '%s\n' "$(_command_names)" | grep -E "${current_word}")
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