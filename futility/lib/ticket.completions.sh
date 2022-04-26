
_complete_ticket() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	COMPREPLY=(
	  $(compgen -W "$(ticket _commands)" "${current_word}")
	)
}
complete -o bashdefault -F _complete_ticket ticket
