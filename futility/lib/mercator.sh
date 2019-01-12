#!/bin/bash

enter_project() {
	local project_name="$1"
	echo "Entering ${project_name}..."
	# An interactive login shell
	env PROJECT_NAME="${project_name}" \
			PROJECT_INIT_COMMAND="init_project_${project_name}" \
			PROJECT_EXIT_COMMAND="exit_project_${project_name}" \
			bash --init-file <(echo 'source $HOME/.bash_profile; init_project') \
					 -i 
					 
			# bash -il --init-file=<(echo ${interactive_subshell_init_command})
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

	eval "${PROJECT_INIT_COMMAND}" || exit

	echo "Entered ${PROJECT_NAME}."

	cleanup_project() {
		echo "Exiting $PROJECT_NAME..."
		eval "${PROJECT_EXIT_COMMAND}"
	}

	exit_project() { exit; }

	trap cleanup_project EXIT
}

exit_project() {
	echo_error 'Not in a project!'
}

dump_no_project_help() {
		cat <<HELP_TEXT
Looks like you tried to enter project "$PROJECT_NAME",
but there is no init command "$PROJECT_INIT_COMMAND".
You need to define that in order to use Mercator.
HELP_TEXT
}

dump_world_map() {
	cat $FUTILITY_PACKAGE_LIB/world_map.txt
}

dump_logo() {
	cat <<MERCATOR
/=================\\
  M E R C A T O R
\\=================/
MERCATOR
}

##
# Demo

.temp() { enter_project 'temp'; }

init_project_temp() {
	prefix_prompt '⏳ '
	term-theme DevOrange &> /dev/null || echo 'No orange theme 😞'

	temp_location=$(mktemp -d)
	cd "${temp_location}"

	exit_project_temp() {
		rm -r "${temp_location}"
	}

	cat <<HELP_TEXT > ./help.txt
This is a temporary location!:

	${temp_location}

Everything will be deleted when you exit!
HELP_TEXT

	cat ./help.txt
}
