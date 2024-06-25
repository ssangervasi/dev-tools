
_git_wip() { _complete_git-wip "$@"; }

_complete_git-wip() {
	# echo "${COMP_WORDS[@]}"
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	local list=$(git wip list | grep "${current_word}")
	COMPREPLY=(
		$(printf '%s ' "${list}")
	)
}
complete -o bashdefault -F _complete_git-wip git-wip

_complete_git-fix() {
	local full_line="${COMP_LINE/git?fix?/}"
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	# echo_info "current_word: '${current_word}'"
	local git_log=$(git log --pretty=format:'%s' $(git seq) | grep "${full_line}")
	# echo_error "git_log ${#git_log}"

	COMPREPLY=()

	IFS=$'\n'
	for line in ${git_log}; do
		# echo_info "line ${line}"

		COMPREPLY+=("${current_word}${line/${full_line}/}")
	done
	# echo_info "COMPREPLY ${#COMPREPLY[@]}"

	unset IFS

	# COMPREPLY=(
	#   $(IFS=$'\n' compgen -W "${git_log}" "${current_word}")
	# )

	# list=($(printf '%s\n' "${list}"))
	# # echo_error "list ${#output}"

	# COMPREPLY=(
	# 	${list[@]}
	# )
}
_git_fix() { _complete_git-fix "$@"; }
complete -F _complete_git-fix git-fix
