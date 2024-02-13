# After mucking around with various terminal 

FUTILITY_THEME_PURPLE="#320830"
FUTILITY_THEME_BLUE="#101035"
FUTILITY_THEME_BLUER="#121245"
FUTILITY_THEME_ORANGE="#492009"
FUTILITY_THEME_GREEN="#102807"

FUTILITY_THEMES='
name   bg
purple #320830
purpler #500845
blue   #101035
bluer  #121245
orange #492009
green  #102807
greener  #103812
'



futility_theme() {
	_futility_theme_find_line "$1" || return $YA_DUN_GOOFED
	_futility_theme_parse_line

	_futility_theme_set_bg "$FUTILITY_THEME_BG"
}

FUTILITY_THEME_LINE=''

_futility_theme_find_line() {
	local name="$1"
	local found=$(grep -i "$name" <<<"$FUTILITY_THEMES")
	if [[ -z "$found" ]]; then
		echo_error "No theme matches '$1'"
		return $YA_DUN_GOOFED
	fi
	FUTILITY_THEME_LINE="$found"
}

_futility_theme_parse_line() {
	FUTILITY_THEME_ARR=($FUTILITY_THEME_LINE)
	FUTILITY_THEME_NAME="${FUTILITY_THEME_ARR[0]}"
	FUTILITY_THEME_BG="${FUTILITY_THEME_ARR[1]}"
}


_futility_theme_set_bg() {
	printf '\x1b]11;'"$1"'\x1b\\'
}