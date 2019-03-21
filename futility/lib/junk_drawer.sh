
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

ls_modified() {
	local ref=$1
	if empty $ref; then
		ref='HEAD'
	fi
	git diff $ref --name-only --diff-filter=d
}

cls() {
	clear
	pwd
	git b || tree -L 1
}

tabname() {
	echo -ne "\033]0;$*\007"
}

count_files() {
	local what where
	what=$(default $1 '.')
	where=$(default $2 '.')
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
	(
		# Turn on extended shell debugging
		shopt -s extdebug
		# Dump the function's name, line number and fully qualified source file
		declare -F $1
		# Turn off extended shell debugging
		shopt -u extdebug
	)
}