# Bat
def_bat() {
	BAT_BIN=$(which bat)
	if [[ -z "${BAT_BIN}" ]]; then
		BAT_BIN=$(which batcat)
	fi
	if [[ -z "${BAT_BIN}" ]]; then
		echo_error "No bat installed"
		return
	fi

	BAT_DEFAULT_OPTIONS=(--paging always)
	alias 'bat'="${BAT_BIN} ${BAT_DEFAULT_OPTIONS[*]}"

	batwitch() {
		"${BAT_BIN}" ${BAT_DEFAULT_OPTIONS[*]} "$(which $1)"
	}
	alias whichat=batwitch	
}

def_bat
