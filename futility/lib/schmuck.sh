
TEST_FAILURE=37

describe() {
	echo "${COLOR_BLUE}describe ${@}${COLOR_NC}"
}

log_result() {
	cat <<-OUT >> results.txt
		$(date +%s) | $1 | IT_VAR: $IT_VAR 
	OUT
}

it() {
	local description="$1"
	local result_fd="$2"
	echo "${COLOR_LIGHT_BLUE}it ${1}${COLOR_NC}"
	
	export IT_VAR='the var of it'
	# log_result 'before cat'
	echo_error 'error date'
	echo "$(date +%s)" 'before cat'
	echo_error "$(date +%s)" 'error before cat'
	# echo 'before cat'
	# sleep 1
	cat ${result_fd} >> results.txt
	sleep 1
	echo_error "$(date +%s)" 'error after cat'
	log_result 'after cat'
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
