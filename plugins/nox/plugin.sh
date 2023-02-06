nos() {
	session="$1"
	param="$2"
	args="${@:3}"

	resolved_param=""
	if [[ "$param" == '--' ]]; then
		resolved_param=""
	elif [[ "$param" == '' ]]; then
		resolved_param=""
	else
		resolved_param="(${param})"
	fi

	resolved_args=()
	for arg in "${args[@]}"; do
		if [[ "$arg" == '--' ]]; then
			continue
		fi
		resolved_args+=("$arg")
	done

	nox -s "${session}${resolved_param}" -- "${resolved_args[@]}"
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