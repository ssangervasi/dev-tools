#!/bin/bash

##
# Initializing

enter_project() {
	local project_name="$1"
	echo "Entering ${project_name}..."
	# An interactive login shell...
	# 	though, technically, it doesn' use the official '-l' argument to
	# 	make it a login shell because I'm mangling the init file.
	env PROJECT_NAME="${project_name}" \
			PROJECT_INIT_COMMAND="init_project_${project_name}" \
			PROJECT_EXIT_COMMAND="exit_project_${project_name}" \
			bash --init-file <(echo 'source $HOME/.bash_profile; init_project') -i
}

init_project() {
	if [[ -z "${PROJECT_INIT_COMMAND}" ]]; then
		return
	fi

	# Jump out of any existing project.
	exit_project &> /dev/null

	type "${PROJECT_INIT_COMMAND}" &>/dev/null

	if [[ $? == 1 ]]; then
		dump_logo
		dump_world_map
		dump_no_project_help

		exit
	fi

	.help() {
		project_default_help
	}

	eval "${PROJECT_INIT_COMMAND}" || exit

	cleanup_project() {
		echo "Exiting $PROJECT_NAME..."
		eval "${PROJECT_EXIT_COMMAND}" 2> /dev/null
	}

	exit_project() { exit; }

	trap cleanup_project EXIT
}

exit_project() {
	echo_error 'Not in a project!'
}

project_default_help() {
	cat <<-HELP_TEXT
		Project ${PROJECT_NAME}
		This the default Mercator help message.
		Define your own .help in ${PROJECT_INIT_COMMAND}
	HELP_TEXT
}

dump_no_project_help() {
	cat <<-HELP_TEXT
		Looks like you tried to enter project "$PROJECT_NAME",
		but there is no init command "$PROJECT_INIT_COMMAND".
		You need to define that in order to use Mercator.
	HELP_TEXT
}

dump_world_map() {
	cat "$FUTILITY_PACKAGE_LIB/data-files/world_map.txt"
}

dump_logo() {
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
