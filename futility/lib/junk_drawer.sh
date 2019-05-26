
# Strip underscores.Allows big numbers to be written '1_930_055'
# Smiley eyes operator
n_n ()
{
	args_and_or_stdin $@ | sed s/_//g
}

tree_find() {
	local dir="$1"
	local pattern="$2"
	shift
	shift
	tree --prune -P "$pattern" "$dir" "$@"
}

cls() {
	clear
	summary
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

tabname() {
	echo -ne "\033]0;$*\007"
}

count_files() {
	local what where
	what=${1:-.}
	where=${2:-.}
	ls -1 $where | grep $what --count
}

space_to_csv() {
	echo "$@" | sed 's/[ \n\t]\+/,/g'
}

slackpost() {
	test ! "$SLACK_WEBHOOK_URL" && echo 'No SLACK_WEBHOOK_URL set!' && return 1

	local message channel botname
	message=$@;
	channel=$(default $channel "@slackbot")
	botname=$(default $botname "HookBot")


	slack_payload="payload={\"channel\": \"${channel}\", \"username\": \"${botname}\", \"text\": \"${message}\", \"icon_emoji\": \":warning:\"}"
	echo "Posting to slack: " $slack_payload

	curl -s -S -X POST --data-urlencode "$slack_payload" "$SLACK_WEBHOOK_URL"
}

# Java is silly.
jcr() {
	local rootdir=$(default $1 '.')
	find $rootdir -name '*.java' | xargs javac
	test $2 && java $2
}

find_func() {
	local fn_name="$1"
	# Turn on extended shell debugging
	shopt -s extdebug
	# Turn off extended shell debugging on return
	trap 'shopt -u extdebug' EXIT
	# Dump the function's name, line number and fully qualified source file
	local fn_dec=$(declare -F ${fn_name})
	if [[ -n ${fn_dec} ]]; then
		echo ${fn_dec}
		return 1
	fi

	local alias_dec=$(alias ${fn_name} 2>/dev/null)
	if [[ -z ${alias_dec} ]]; then
		echo_error "No function or alias named '${fn_name}'"
		return 1
	fi

	echo ${alias_dec}
}
kanye() {
	json_extract_key "$(curl -s api.kanye.rest)" "quote"
}

json_extract_key() {
	local json="$1"
	local key="$2"
	local py_script=$(
		cat <<-PYTHON
			from __future__ import print_function
			import sys
			import json
			print(json.loads(sys.argv[1])[sys.argv[2]])
		PYTHON
	)
	python -c "${py_script}" "${json}" "${key}"
}