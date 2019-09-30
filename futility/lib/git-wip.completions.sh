complete -o bashdefault -F _complete_git-wip git-wip

_git_wip() { _complete_git-wip "$@"; }

_complete_git-wip() {
	# echo "${COMP_WORDS[@]}"
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	list=$(git wip list | grep "${current_word}")
	COMPREPLY=(
		$(printf '%s\n' "${list}")
	)
}
