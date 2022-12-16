nos() {
	nox -s "$1${2:+(${2})}" "${@:3}"
}

nol() {
	nox -l | sed -nE 's/^- (.+) ->.*/\1/p' | sed 's/[()]/ /g'
}

_complete_nos() {
	local current_word="${COMP_WORDS[${COMP_CWORD}]}"

	COMPREPLY=(
	  $(compgen -W "$(nol)" "${current_word}")
	)

}

complete -F _complete_nos nos