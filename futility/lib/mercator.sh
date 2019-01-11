#!/bin/bash

enter_project() {
	local project_name="$1"
	env PROJECT_INIT_COMMAND="init_project_${project_name}" \
			PROJECT_EXIT_COMMAND="exit_project_${project_name}" \
			bash -i
}

init_project() {
	if [[ -z "${PROJECT_INIT_COMMAND}" ]]; then
		return
	fi

	# Jump out of any existing project.
	exit_project &> /dev/null

	eval "${PROJECT_INIT_COMMAND} || exit"

	cleanup_project() {
		term-theme DevBlack
		eval "${PROJECT_EXIT_COMMAND} || Exiting project."
	}

	exit_project() { exit; }

	trap cleanup_project EXIT
}

exit_project() {
	echo_error 'Not in a project!'
}

##
# Demo

.temp() { enter_project 'temp'; }

init_project_temp() {
	prefix_prompt '⏳ '
	term-theme DevOrange || echo 'No orange theme 😞'

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
