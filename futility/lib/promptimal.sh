
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
	unmangle_prompt_command _dynamic_prompt
}

_simple_prompt() {
	export PS1='\$ ';
}

_timer_prompt() {
	mangle_prompt_command 'prompt_clock'
	export PS1='$ELAPSED\$ '
}

_dynamic_prompt() {
	history -a
	
	local min_info_width=70
	local columns=$(default ${COLUMNS} ${min_info_width})
	local connector='…'
	# Wow math comparisons are ugly.
	if (( "${min_info_width}" < "${columns}")); then
		local max_basename_width=16
		local pwd_basename=$(basename "$PWD")
		local abrv_basename="${pwd_basename}"
		# String length calc is even uglier!
		if (( "${max_basename_width}" < "${#pwd_basename}" )); then
			local head_width=8
			local tail_width=7
			local basename_head=$(echo ${pwd_basename} | head -c ${head_width})
			local basename_tail=$(echo ${pwd_basename} | tail -c ${tail_width})
			abrv_basename="${basename_head}${connector}${basename_tail}"
		fi

		local abrv_username="$(whoami)"
		abrv_username="${abrv_username:0:4}"

		_info_prompt "${abrv_basename}" "${abrv_username}"
	else
		_simple_prompt
	fi
}

_info_prompt() {
	local basename=$(default "$1" "\W")
	local username=$(default "$2" "\u")
	local info_ps1="\
${PROMPT_PREFIX}\
\[${COLOR_CYAN}\]\
\t\
\[${COLOR_NC}\]\
|\
\[${COLOR_BROWN}\]\
${username}\
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
	local prompt_command_custom="$1"
	if ! [[ "${PROMPT_COMMAND:-}" =~ ${prompt_command_custom} ]]; then
		PROMPT_COMMAND="${prompt_command_custom};${PROMPT_COMMAND}"
	fi
	_cleanup_prompt_command
}

unmangle_prompt_command() {
	local prompt_command_custom="$1"
	PROMPT_COMMAND="${PROMPT_COMMAND/${prompt_command_custom}/}"
	_cleanup_prompt_command
}

_cleanup_prompt_command() {
	PROMPT_COMMAND="${PROMPT_COMMAND/;;/;}"
	PROMPT_COMMAND="${PROMPT_COMMAND#;}"
	# PROMPT_COMMAND=$(
	# 	echo "$PROMPT_COMMAND" |
	# 	sed 's/^;//g' |
	# 	sed -E 's/;+/;/g'
	# )
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
