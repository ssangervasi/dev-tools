#!/bin/bash

tree_find() {
	local pattern=$1
	shift
	tree --prune -P $pattern $@
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

# resource() {
# 	if [ ! $1 ]; then
# 		deactivate &> /dev/null
# 		source $DEV_BIN/.bash_profile
# 		return 0;
# 	fi
# 	local osx_activate='bin/activate'
# 	local win_activate='Scripts/activate'
# 	local venvs=$(default $VENVS ~/.venvs)
# 	local activate=$venvs/$1/$osx_activate
# 	if [ ! -e $activate ]; then
# 		activate=$venvs/$1/$win_activate
# 	fi
# 	source $activate &> /dev/null
# 	if [[ $? != 0 ]]; then
# 		echo 'No venv "'$1'"'
# 		echo 'Options:'
# 		ls -1 $venvs
# 	fi
# }

prompt_clock() {
	export CHECK_SECONDS=$((SECONDS-CHECK_SECONDS))
	export ELAPSED=$((CHECK_SECONDS/60)):$((CHECK_SECONDS%60))
	export CHECK_SECONDS=$SECONDS
}

export prompt_swap_command=''
export PROMPT_COMMAND=$PROMPT_COMMAND'; $prompt_swap_command'
prompt_swap() {
	export prompt_swap_command=''
	simple_prompt='\$ '
	timer_prompt='$ELAPSED\$ '
	info_prompt="\[${COLOR_CYAN}\]\A\[${COLOR_NC}\]:\u:\W\$ "
	case $1 in
		-i|--info)
			export PS1=$info_prompt
			;;
		-t|--timer)
			export prompt_swap_command=prompt_clock
			export PS1=$timer_prompt
			;;
		-s|--simple)
			PS1=$simple_prompt
			;;
		-h|--help)
			echo '--info, --timer, --simple'
			;;
		*)
			export PS1=$(default "$1" "$simple_prompt")
	esac
}

tabname() {
	echo -ne "\033]0;$*\007"
}

count_files() {
	what=$(default $1 '.')
	where=$(default $2 '.')
	ls -1 $where | grep $what --count
}

space_to_csv() {
	echo "$@" | sed 's/[ \n\t]\+/,/g'
}

slackpost() {
	SLACK_MESSAGE=$@;
	test ! SLACK_WEBHOOK_URL && echo 'No SLACK_WEBHOOK_URL set!' && return 1
	SLACK_CHANNEL=$(default $SLACK_CHANNEL "@slackbot")
	SLACK_BOTNAME=$(default $SLACK_BOTNAME "HookBot")

	SLACK_PAYLOAD="payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${SLACK_MESSAGE}\", \"icon_emoji\": \":warning:\"}"
	echo "Posting to slack: " $SLACK_PAYLOAD

	curl -s -S -X POST --data-urlencode "$SLACK_PAYLOAD" "$SLACK_WEBHOOK_URL"
}

# Java is silly.
jcr() {
	rootdir=$(default $1 '.')
	find $rootdir -name '*.java' | xargs javac
	test $2 && java $2
}
