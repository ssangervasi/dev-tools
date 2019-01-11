#!/bin/bash

prompt_swap() {
	export prompt_swap_command=''
	timer_prompt='$ELAPSED\$ '
	case $1 in
		-i|--info)
			_info_prompt
			;;
		-t|--timer)
			mangle_prompt_command "prompt_clock"
			export PS1=$timer_prompt
			;;
		-s|--simple)
			_simple_prompt
			;;
		-d|--dynamic)
			mangle_prompt_command _dynamic_prompt
			;;
		-h|--help)
			echo '--info, --timer, --simple'
			;;
		*)
			export PS1=$(default "$1" "$simple_prompt")
	esac
}

_simple_prompt() { export PS1='\$ '; }

_dynamic_prompt() {
	local min_width=100
	# Wow math comparisons are ugly.
	if [[ $(($COLUMNS > $min_width)) == 1 ]]; then
		_info_prompt
	else
		_simple_prompt
	fi
}

_info_prompt() {
	local info_ps1="\
\[${COLOR_CYAN}\]\
\T\
\[${COLOR_NC}\]\
|\
\[${COLOR_GREY}\]\
\u\
\[${COLOR_NC}\]\
|\
\W\
\$ "
	export PS1="${info_ps1}"
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
