#!/bin/bash

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
			mangle_prompt_command "prompt_clock"
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

prefix_prompt() {
	local prefix="$1"
	export PS1="${prefix}${PS1}"
}

unprefix_prompt() {
	local prefix="$1"
	local unprefixed=$(echo "$PS1" | sed "s/^${prefix}//")
	export PS1="${unprefixed}"
}

prompt_clock() {
	export CHECK_SECONDS=$((SECONDS-CHECK_SECONDS))
	export ELAPSED=$((CHECK_SECONDS/60)):$((CHECK_SECONDS%60))
	export CHECK_SECONDS=$SECONDS
}

mangle_prompt_command() {
	export PROMPT_COMMAND_CUSTOM="$1"
	if empty ${PROMPT_COMMAND_ORIGINAL}; then
		export PROMPT_COMMAND_ORIGINAL="$PROMPT_COMMAND"
		export PROMPT_COMMAND="prompt_command_function"
	fi
}

unmangle_prompt_command() {
	export PROMPT_COMMAND="$PROMPT_COMMAND_ORIGINAL"
}

prompt_command_function() {
	$PROMPT_COMMAND_ORIGINAL
	$PROMPT_COMMAND_CUSTOM
}
