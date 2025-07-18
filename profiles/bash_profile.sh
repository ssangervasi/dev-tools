
# Because I always forget:
# .bash_profile -> loaded for login shell 
# .bashrc -> loaded for interactive shells 

_init() {
	if [[ -z $DEV_TOOLS_ROOT ]]; then
		error_message='
			Error: DEV_TOOLS_ROOT is not set!
			Did you source bashrc.sh correctly?
		'
		echo ${error_message} 1>&2
		# return 2
	fi

	# Custom terminal
	prompt_swap --dynamic

	local os_name=$(uname -o 2>/dev/null || uname -s 2>/dev/null)
	if [[ ${os_name} =~ Msys ]]; then os_msys;
	elif [[ ${os_name} =~ Darwin ]]; then os_darwin;
	elif [[ ${os_name} =~ Linux ]]; then
		if grep -q Microsoft /proc/version; then
			os_wsl
		else
			os_linux
		fi
	fi

	##
	# Plugins
	source "$DEV_TOOLS_ROOT/plugins/bat/bat_options.sh"
	source "$DEV_TOOLS_ROOT/plugins/docker/plugin.sh"
	source "$DEV_TOOLS_ROOT/plugins/gh/plugin.sh"
	source "$DEV_TOOLS_ROOT/plugins/fzf/plugin.sh"
}

os_msys() { 
	export TREE_DEFAULT_OPTIONS='--dirsfirst';
}

os_linux() { 
	alias clear='clear -x'
}

os_wsl() {
	DEV_TOOLS_SUBLIME_PLUGIN="$DEV_TOOLS_ROOT/plugins/sublime/wsl/plugin.sh"
	source "$DEV_TOOLS_ROOT/plugins/clipboard/wsl/plugin.sh"

	register_project 'dev_tools'
	init_project_dev_tools() {
		prefix_prompt '[D]'

		cd "$DEV_TOOLS_ROOT"
	}
}

os_darwin() {
	##
	# Homebrew bash completions

	## For bash < 4

	# brew_bash_completion() {
	#   if type brew 2&>/dev/null; then
	#   	bash_completion_file=$(brew --prefix)/etc/bash_completion
	#   	if [[ -e $bash_completion_file ]]; then
	#   		source  $bash_completion_file
	#     else
	#       echo_error 'Homebrew bash completions do not exist!'
	#       echo_error 'Homebrew suggests running: brew install git bash-completion'
	#       return $YA_DUN_GOOFED
	#     fi
	#   fi
	#   return 0
	# }

	## For bash >= 4

	brew_bash_completion() {
		export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"

		if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then
			source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
		elif [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then			
			source "/usr/local/etc/profile.d/bash_completion.sh"
		else
			echo_error 'Homebrew bash completions do not exist!'
			echo_error 'Homebrew suggests running: brew install bash-completion@2'
			return $YA_DUN_GOOFED
		fi
	}

	brew_bash_completion

	##
	# Plugins

	source "$DEV_TOOLS_ROOT/plugins/clipboard/darwin/plugin.sh"

	# Sublime "subl" CLI
	DEV_TOOLS_SUBLIME_PLUGIN="$DEV_TOOLS_ROOT/plugins/sublime/darwin/plugin.sh"
	DEV_TOOLS_VSCODE_PLUGIN="$DEV_TOOLS_ROOT/plugins/vs-code/darwin/plugin.sh"

	# Chrome CLI
	add_to_path '/Applications/Google Chrome.app/Contents/MacOS'
	alias 'chrome'='Google\ Chrome'

	register_project 'dev_tools'
	init_project_dev_tools() {
		prefix_prompt '🛠'
		# term-theme DevPurple
		futility_theme purple

		cd "$DEV_TOOLS_ROOT"
	}
}

_init
