
prompt_swap() {
	check_help $@ && prompt_swap_help && return 0
	clear_prompt

	local arg="${1:--s}"
	case "$arg" in
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
			PS1="$arg"
		;;
	esac
}

prompt_swap_help() {
	cat <<-HELP_TEXT
		Supported prompts:
			-s, --simple
			-i, --info
			-t, --timer
			-d, --dynamic
	HELP_TEXT
}

clear_prompt() {
	unprefix_prompt
	unmangle_prompt_command
}

_simple_prompt() {
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
		local pwd_basename=$(basename "$PWD")
		local abrv_basename="${pwd_basename}"
		# String length calc is even uglier!
		if [[ $((${#pwd_basename} > ${max_basename_width})) == 1 ]]; then
			local head_width=8
			local tail_width=7
			local connector='…'
			local basename_head=$(echo ${pwd_basename} | head -c ${head_width})
			local basename_tail=$(echo ${pwd_basename} | tail -c ${tail_width})
			abrv_basename="${basename_head}${connector}${basename_tail}"
		fi
		_info_prompt "${abrv_basename}"
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
\[${COLOR_GREY}\]\
${basename}\
\[${COLOR_NC}\]\
\$ "
	PS1="${info_ps1}"
}

prefix_prompt() {
	unprefix_prompt
	PROMPT_PREFIX="$1"
	PS1="${PROMPT_PREFIX}${PS1}"
}

unprefix_prompt() {
	if [[ -z $PROMPT_PREFIX ]]; then
		return 0
	fi
	local unprefixed=$(echo "$PS1" | sed "s/^${PROMPT_PREFIX}//")
	PS1="${unprefixed}"
}

prompt_clock() {
	CHECK_SECONDS=$((SECONDS-CHECK_SECONDS))
	ELAPSED=$((CHECK_SECONDS/60)):$((CHECK_SECONDS%60))
	CHECK_SECONDS=$SECONDS
}

mangle_prompt_command() {
	PROMPT_COMMAND_CUSTOM="$1"
	local original=$(
		echo "$PROMPT_COMMAND" |
			sed s/[[:space:]]*prompt_command_function[[:space:]]*//
	)
	PROMPT_COMMAND_ORIGINAL="${original}"
	PROMPT_COMMAND="prompt_command_function"
}

prompt_command_function() {
	if [[ -n $(type $PROMPT_COMMAND_ORIGINAL) ]]; then
		eval "$PROMPT_COMMAND_ORIGINAL"
	fi
	if [[ -n $(type $PROMPT_COMMAND_CUSTOM) ]]; then
		eval "$PROMPT_COMMAND_CUSTOM"
	fi
}

unmangle_prompt_command() {
	PROMPT_COMMAND="$PROMPT_COMMAND_ORIGINAL"
	PROMPT_COMMAND_CUSTOM=''
}

prompt_command_help() {
	cat <<-HELP_TEXT
		PROMPT_COMMAND          : $PROMPT_COMMAND
		PROMPT_COMMAND_CUSTOM   : $PROMPT_COMMAND_CUSTOM
		PROMPT_COMMAND_ORIGINAL : $PROMPT_COMMAND_ORIGINAL

		prompt_command_function
		$(type prompt_command_function)
	HELP_TEXT
}
