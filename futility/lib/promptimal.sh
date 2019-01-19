#!/bin/bash

prompt_swap() {
	check_help $@ && prompt_swap_help && return 0
	case $1 in
		-s|--simple)
			_simple_prompt
			;;
		-i|--info)
			_info_prompt
			;;
		-t|--timer)
			_timer_prompt
			;;
		-d|--dynamic)
			mangle_prompt_command _dynamic_prompt
			;;
		*)
			export PS1=$(default "$1" "$simple_prompt")
	esac
}

prompt_swap_help() {
	cat <<HELP_TEXT
Supported prompts:
	-s, --simple
	-i, --info
	-t, --timer
	-d, --dynamic
HELP_TEXT
}

_simple_prompt() {
	mangle_prompt_command ''
	export PS1='\$ ';
}

_timer_prompt() {
	mangle_prompt_command 'prompt_clock'
	export PS1='$ELAPSED\$ '
}

_dynamic_prompt() {
	local min_info_width=70
	local columns=$(default ${COLUMNS} ${min_info_width})
	# Wow math comparisons are ugly.
	if [[ $((${columns} >= ${min_info_width})) == 1 ]]; then
		local max_basename_width=16
		local pwd_basename=$(basename $PWD)
		local basename=${pwd_basename}
		# String length calc is even uglier!
		if [[ $((${#pwd_basename} > ${max_basename_width})) == 1 ]]; then
			local head_width=8
			local tail_width=7
			local connector='…'
			local basename_head=$(echo ${pwd_basename} | head -c ${head_width})
			local basename_tail=$(echo ${pwd_basename} | tail -c ${tail_width})
			basename="${basename_head}${connector}${basename_tail}"
		fi
		_info_prompt "${basename}"
	else
		_simple_prompt
	fi
}

_info_prompt() {
	local basename=$(default "$1" "\W")
	local info_ps1="\
${PROMPT_PREFIX}\
\[${COLOR_CYAN}\]\
\T\
\[${COLOR_NC}\]\
|\
\[${COLOR_BROWN}\]\
\u\
\[${COLOR_NC}\]\
|\
${basename}\
\$ "
	export PS1="${info_ps1}"
}

prefix_prompt() {
	export PROMPT_PREFIX="$1"
	export PS1="${PROMPT_PREFIX}${PS1}"
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
	local original=$(
		echo "$PROMPT_COMMAND" \
		| sed s/[[:space:]]*prompt_command_function[[:space:]]*//
	)
	if empty ${original}; then
		export PROMPT_COMMAND="$PROMPT_COMMAND_CUSTOM"
	else
		export PROMPT_COMMAND_ORIGINAL="${original}"
		export PROMPT_COMMAND="prompt_command_function"
	fi
}

prompt_command_function() {
	type $PROMPT_COMMAND_ORIGINAL &>/dev/null
	if [[ $? == 0 ]]; then
		eval "$PROMPT_COMMAND_ORIGINAL"
	fi
	type $PROMPT_COMMAND_CUSTOM &>/dev/null
	if [[ $? == 0 ]]; then
		$PROMPT_COMMAND_CUSTOM
	fi
}

prompt_command_help() {
	cat <<HELP_TEXT
PROMPT_COMMAND          : $PROMPT_COMMAND
PROMPT_COMMAND_CUSTOM   : $PROMPT_COMMAND_CUSTOM
PROMPT_COMMAND_ORIGINAL : $PROMPT_COMMAND_ORIGINAL

prompt_command_function
$(type prompt_command_function)
HELP_TEXT
}
