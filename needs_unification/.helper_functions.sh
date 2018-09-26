cls() {
	clear
	pwd
	gitb || tree -L 1
}

# which_rspec() {
# 	bundle show bundler || return 'rspec'
# 	bundle show spring && return 'bundle exec spring rspec'
# 	bundle show rspec && return 'bundle exec rspec'
# }

SPEC_HISTORY=''

spec() {
	SPEC_HISTORY=$@
	bundle exec rspec --format documentation $@
}

respec() {
	if [[ $SPEC_HISTORY =~ ^[[:space:]]*$ ]]; then
		echo 'No spec history!'
		return 0
	fi
	echo 'Replaying spec:' $SPEC_HISTORY
	spec $SPEC_HISTORY
}

globspec() {
	help_pattern='^(-h|--help)$'
	usage='Usage: globspec pattern
	=> run `bundle exec rspec` on all files matching the pattern
	Example:
		globspec *animals/*horse_spec.rb

	'
	if [[ $1 == '' ]]; then
		echo 'Error: must provide a pattern!'
		return 1
	elif [[ $1 =~ $help_pattern ]]; then
		echo $usage
		return 0
	fi

	matches=$(find -X . -path $1)
	if [[ $matches =~ ^[[:space:]]*$ ]]; then
		echo 'Error: no files match pattern!'
		return 2
	fi

	echo 'Running spec on these paths:
	' $matches
	spec $matches
}


ls_modified_specs() {
	# $(git ls-files --modified --others spec)
	git diff HEAD --name-only --diff-filter=d | grep "_spec\.rb$"
}

ls_modified_rbs() {
	git diff HEAD --name-only --diff-filter=d | grep "\.rb$"
}

modspec() {
	local modified_specs=$(ls_modified_specs)
	if [[ $modified_specs =~ ^[[:space:]]*$ ]]; then
		echo 'No modified spec files.'
		return 0
	fi

	echo "Running 'rspec $@' on these paths:
	" $modified_specs
	spec $modified_specs $@
}

modcop(){
	bundle exec rubocop $(ls_modified_rbs)
}

# Take a pss
change_prompt() {
	local info_prompt="\[${COLOR_CYAN}\]\A\[${COLOR_NC}\]:\u:\W\$ "
	export PS1=${info_prompt}
}

# kick_ssh_agent() {
# 	killall ssh-agent; eval "$(ssh-agent -s)" && ssh-add -K
# }

tree_find() {
	local pattern=$1
	shift
	tree --prune -P $pattern $@
}