wat() {
	local pager=$(which bat || which less)
	echo "$@"
	$@ --help | "${pager}"
}

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
	tree --prune --matchdirs -P "$pattern" "$dir" "$@"
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

pbpath() {
	local target="$1"
	local dir=$(dirname "${target}")
	local base=$(basename "${target}")

	local abs_dir=$(get_absolute_path "${dir}")
	echo -n "${abs_dir}/${base}" | pbcopy
}

dir_size() {
	du -sh "$@"
}