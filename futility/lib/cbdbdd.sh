##
# change dir, but weird
##

cls() {
	clear
	summary "$@"
	gits
}

summary() {
	local dir_path=$(get_absolute_path ${1:-.})
	local ls_result="$(ls -A1F $dir_path)"
	local dir_count=$(echo "$ls_result" | grep -c '/$')
	local exe_count=$(echo "$ls_result" | grep -c '*$')
	local specials='/*%@=%|'
	local reg_count=$(echo "$ls_result" | grep -vc "[${specials}]$")
	local total_count=$(echo "$ls_result" | grep -c '.')
	cat <<-SUMMARY
		${dir_path}
		Directories: ${dir_count}
		Executables: ${exe_count}
		Regular:     ${reg_count}
		Total:       ${total_count}
	SUMMARY
}

summary_table() {
	summary |
		column -t |
		while read line; do
			echo "$line" |
				sed -E 's/[[:space:]]{2}/· /g' |
				cat
			read line && echo "$line"
		done
}

mcd() {
	mkdir -p "$1"
	cd "$1"
}

rmcd() {
	wuz="$PWD"
	cd "${1:-..}"
	rm -r "${wuz}"
}
