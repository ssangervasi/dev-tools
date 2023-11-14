# After mucking around with various terminal 

FUTILITY_THEME_PURPLE="#320830"
FUTILITY_THEME_BLUE="#101035"
FUTILITY_THEME_ORANGE="#492009"
FUTILITY_THEME_GREEN="#102807"

futility_theme() {
	FUTILITY_THEME_NAME="$1"
	if [[ "$FUTILITY_THEME_NAME" == 'purple' ]]; then
		FUTILITY_THEME_BG="$FUTILITY_THEME_PURPLE"
	elif [[ "$FUTILITY_THEME_NAME" == 'blue' ]]; then
		FUTILITY_THEME_BG="$FUTILITY_THEME_BLUE"
	elif [[ "$FUTILITY_THEME_NAME" == 'orange' ]]; then
		FUTILITY_THEME_BG="$FUTILITY_THEME_ORANGE"
	elif [[ "$FUTILITY_THEME_NAME" == 'green' ]]; then
		FUTILITY_THEME_BG="$FUTILITY_THEME_GREEN"
	fi

	# echo printf '\x1b]11;'"$FUTILITY_THEME_BG"'\x1b\\'
	_futility_theme_set_bg "$FUTILITY_THEME_BG"
}

_futility_theme_set_bg() {
	printf '\x1b]11;'"$1"'\x1b\\'
}