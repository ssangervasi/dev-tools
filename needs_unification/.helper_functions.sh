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

echo_error() {
	echo $@ 1>&2
}

SPEC_HISTORY_PATH=~/.spec_history

spec() {
	echo $@ > $SPEC_HISTORY_PATH
	bundle exec rspec --format documentation $@
}

read_spec_history() {
	spec_history=$(cat $SPEC_HISTORY_PATH)
	if empty $spec_history; then
		echo_error 'No spec history!'
		return 1
	fi

	echo $spec_history
}

respec() {
	spec_history=$(read_spec_history)
	if [[ $_ ]]; then
		return 1
	fi

	echo 'Replaying spec:' $spec_history $@
	spec $spec_history $@
}

globspec() {
	help_pattern='^(-h|--help)$'
	usage='Usage: globspec pattern
	=> run `bundle exec rspec` on all files matching the pattern
	Example:
		globspec *animals/*horse_spec.rb

	'
	if [[ $1 == '' ]]; then
		echo_error 'Error: must provide a pattern!'
		return 1
	elif [[ $1 =~ $help_pattern ]]; then
		echo $usage
		return 0
	fi

	matches=$(find -X . -path $1)
	if empty $matches; then
		echo_error 'Error: no files match pattern!'
		return 2
	fi

	echo 'Running "spec" on these paths:'
	ls -1 $matches
	spec $matches
}

empty() {
	if [[ $1 =~ ^[[:space:]]*$ ]]; then
		return 0
	fi
	return 1
}


ls_modified() {
	local ref=$1
	if empty $ref; then
		ref='HEAD'
	fi
	git diff $ref --name-only --diff-filter=d
}

ls_modified_specs() {
	ls_modified $1 | grep "_spec\.rb$"
}

ls_modified_rbs() {
	ls_modified $1 | grep "\.rb$"
}

modspec() {
	ref=$1
	shift
	local modified_specs=$(ls_modified_specs $ref)
	if empty $modified_specs; then
		echo_error 'No modified spec files.'
		return 0
	fi

	echo "Running \"spec $@\" on these paths:"
	ls -1 $modified_specs
	spec $modified_specs $@
}

modcop() {
	local modified_rbs=$(ls_modified_rbs $1)
	if empty $modified_rbs; then
		echo_error 'No modified ruby files.'
		return 0
	fi
	bundle exec rubocop $modified_rbs
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


# Example:
# $ ls -1
# 	cow.rb
# 	frep.sh
# 	horse.rb
# $ find_mvsed '*.rb' -E "s/([a-z]*)\.rb/moved_\1.py/g"
# 	./cow.rb => ./moved_cow.py
# 	./horse.rb => ./moved_horse.py
# $ ls -1
# 	frep.sh
# 	moved_cow.py
# 	moved_horse.py
find_mvsed() {
	local find_pattern=$1
	shift
	local sed_args=$@
	find . -path "$find_pattern" -exec mvsed {} $sed_args \;

}

_mvsed() {
	local file_path=$1
	shift
	local sed_args=$@
	local new_file_path=$(echo $file_path | sed $sed_args)
	# if [[ $file_path != $new_file_path && $(empty $new_file_path) != 0 ]]; then
	if [[ -e $new_file_path ]]; then
		echo_error "Error: cannot move $file_path to $new_file_path -- path exists"
	elif [[ $(empty $new_file_path) ]]; then
		echo_error "Error: cannot move $file_path -- new path is empty"
	else
	    echo "$file_path => $new_file_path"
	    mv $file_path $new_file_path
	fi
}
