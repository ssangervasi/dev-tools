
##
# Registration

register_project() {
	local project_name="$1"
	local init_command=$(_init_command_from_name "${project_name}")

	alias ",${project_name}"="enter_project ${project_name}"
	MERCATOR_PROJECTS+=("${project_name}")
}

# Bash completion based on registered names

_complete_enter_project() {
	local current_word="${COMP_WORDS[$COMP_CWORD]}"
	# Note the difference between:
	# 	array=(foo bar)
	# 	"${array[@]}" => "foo" "bar"
	# 	"${array[*]}" => "foo bar"
	COMPREPLY=(
		$(printf '%s\n' "${MERCATOR_PROJECTS[@]}" | grep -E "${current_word}")
	)
}

alias ',,'=enter_project
complete -F _complete_enter_project enter_project ',,'

##
# Entering the shell

enter_project() {
	local project_name="$1"
	echo "Entering ${project_name}..."
	# An interactive login shell...
	# 	though, technically, it doesn' use the official '-l' argument to
	# 	make it a login shell because I'm mangling the init file.
	env MERCATOR_PROJECT_NAME="${project_name}" \
			MERCATOR_PROJECT_INIT_COMMAND=$(_init_command_from_name "${project_name}") \
			MERCATOR_PROJECT_EXIT_COMMAND=$(_exit_command_from_name "${project_name}") \
			bash --init-file <(echo 'source $HOME/.bash_profile; _init_project') -i
}

_init_command_from_name() {
	local project_name="$1"
	echo "init_project_${project_name}"
}

_exit_command_from_name() {
	local project_name="$1"
	echo "exit_project_${project_name}"
}

_init_project() {
	if [[ -z "${MERCATOR_PROJECT_INIT_COMMAND}" ]]; then
		return
	fi

	# Jump out of any existing project.
	exit_project &> /dev/null

	if ! is_defined "$MERCATOR_PROJECT_INIT_COMMAND"; then
		_dump_logo
		_dump_world_map
		_dump_no_project_help

		exit
	fi

	eval "${MERCATOR_PROJECT_INIT_COMMAND}" || exit

	_cleanup_project() {
		echo "Exiting $MERCATOR_PROJECT_NAME..."
		eval "${MERCATOR_PROJECT_EXIT_COMMAND}" 2> /dev/null
	}

	exit_project() { exit; }

	trap _cleanup_project EXIT
}

exit_project() {
	echo_error 'Not in a project!'
}

project_default_help() {
	cat <<-HELP_TEXT
		Project ${MERCATOR_PROJECT_NAME}
		This the default Mercator help message.
		Define your own .help in ${MERCATOR_PROJECT_INIT_COMMAND}
	HELP_TEXT
}

_dump_no_project_help() {
	cat <<-HELP_TEXT
		Looks like you tried to enter project "$MERCATOR_PROJECT_NAME",
		but there is no init command "$MERCATOR_PROJECT_INIT_COMMAND".
		You need to define that in order to use Mercator.
	HELP_TEXT
}

_dump_world_map() {
	cat "$FUTILITY_PACKAGE_LIB/data-files/world_map.txt"
}

_dump_logo() {
	cat <<MERCATOR
/=================\\
	M E R C A T O R
\\=================/
MERCATOR
}

##
# Generating

generate_project() {
	check_help $@ && generate_project_help && return 0

	local name directory icon
	if ! empty "$1" && [[ ! -d "$1" ]]; then
		echo_error 'The argument "'"$1"'" is not a directory.'
		return $YA_DUN_GOOFED
	fi
	directory=$(default $(get_absolute_path "$1") "$PWD")

	name=$(default "$2" $(basename ${directory}))
	icon=$(default "$3" '🆕')

	cat <(cat "$FUTILITY_PACKAGE_LIB/data-files/new_project.sh.template" |
				sub_var 'name' "${name}" |
				sub_var 'directory' "${directory}" |
				sub_var 'icon' "${icon}" |
				sub_var 'date' "$(date)")
}

generate_project_help() {
	cat <<-HELP_TEXT
		usage: generate_project [-h|--help] [<directory>] [<name>] [<icon>]

		-h, --help   : Print this help and exit.
		<directory>  : Path to where the project should be located. Default is the current directory.
		<name>       : The name of the project, which will be used to generate functions.
									 Default is the basename of the directory argument.
		<icon>       : The icon that will prefix PS1 when inside the proejct. Default is '🆕'.

		This command genates a boilerplate Mercator project with the given arguments.
		The result is printed to stdout. To preserve the project, run something like:

			$ generate_project . my_proj >> ~/bash_profile

		Replace "~/bash_profile" with your preferred shell initializer script,
		or in a file devoted to the project. If you choose the latter, remember that
		you will need to source that file in your init script.
	HELP_TEXT
}

##
# Have you ever written a template language using file streams and sed replacement?
# Have you ever used a `'` as a sed seperator `/` wouldn't allow you replace file paths?
# Are you so stubborn that you won't just add a dependency on Jinja2?
sub_var() {
	local var_name var_content template
	var_name="$1"
	var_content="$2"
	IFS=''
	while read -t 10 template; do
		echo ${template} |
			sed -E "s'{{[[:space:]]*(${var_name})[[:space:]]*}}'${var_content}'g"
	done
	unset IFS
}

##
# Demo

.temp() { enter_project 'temp'; }

init_project_temp() {
	prefix_prompt '⏳ '
	term-theme DevOrange

	temp_location=$(mktemp -d)
	cd "${temp_location}"

	exit_project_temp() {
		rm -r "${temp_location}"
	}

	.help() {
		cat <<-HELP_TEXT
			This is a temporary location!:

				${temp_location}

			Everything will be deleted when you exit!
		HELP_TEXT
	}

	.help
}

register_project 'temp'
