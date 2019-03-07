#!/bin/bash

TEST_FAILURE=37

describe() {
	echo "${COLOR_BLUE}describe ${@}${COLOR_NC}"
}

it() {
	echo "${COLOR_LIGHT_BLUE}it ${@}${COLOR_NC}"
}

passed() {
	echo_success 'passed'
}

failed() {
	echo_error 'failed'
	exit $TEST_FAILURE
}

expect() {
	case "$2" in
		'to be')
			expect_to_be "$1" "$3"
			;;
		'to eq')
			expect_to_eq "$1" "$3"
			;;
		*)
			echo_error "What is '$2'?"
	esac
}

expect_to_be() {
	local actual_var="$1"
	local expected_var="$2"

	if [[ -z ${actual_var} || -z ${expected_var} ]]; then
		echo_error "expect 'to be' requires two variables"
		failed
	fi

	# Gross?
	local actual="${!actual_var}"
	local expected="${!expected_var}"

	if [[ ${actual} != ${expected} ]]; then
		echo_error "Varible ${actual_var} was not ${expected_var}!"
		echo_error "expected: '${expected}'"
		echo_error "received: '${actual}'"
		failed
	fi
}

expect_to_eq() {
	local actual="$1"
	local expected="$2"

	if [[ ${actual} != ${expected} ]]; then
		echo_error "Values were not equal!"
		echo_error "expected: '${expected}'"
		echo_error "received: '${actual}'"
		failed
	fi
}
