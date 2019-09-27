
copy_associative_array() {
	local src_var_name="$1"
	local dst_var_name="$2"
	local key val
	local indirection='${!'"${src_var_name}"'[@]}'
	for key in $(eval "echo ${indirection}"); do
		echo 1 $key
		# indirection='${'"${src_var_name}"'[${'"${key}"'}]}'
		indirection='${'"${src_var_name}"'['"${key}"']}'
		eval "val=${indirection}"
		echo 2 "${indirection}" "'$val'"
		indirection="${dst_var_name}"'['"${key}"']'
		echo 3 "${indirection}"
		eval "${indirection}=${val}"
	done
}

copy_associative_array_demo() {
	declare -A my_contacts your_contacts our_contacts
	my_contacts=(
		["Jim"]='555-123-1234'
		["Dan"]='555-000-0101'
	)
	your_contacts=(
		["Karen"]='666-123-1234'
		["Carlifer"]='666-000-0101'
	)

	our_contacts=()
	copy_associative_array my_contacts our_contacts
	copy_associative_array your_contacts our_contacts
	cat <<-RESULT
		my_contacts
			${!my_contacts[@]}
			${my_contacts[@]}
		your_contacts
			${!your_contacts[@]}
			${your_contacts[@]}
		our_contacts
			${!our_contacts[@]}
			${our_contacts[@]}
	RESULT
}
