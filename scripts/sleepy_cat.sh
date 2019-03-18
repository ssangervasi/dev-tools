sleepy() {
	echo '😴 so sleepy'
	sleep 1;
	for i in $(seq 1 $1); do
		echo "😴 snooze $i";
		sleep 1;
	done
	echo '😌 ok me awake'
}

catnap() {
	# Cat sleep when cat feel like
	echo '😽 purr'
	sleep $1
	# You wake cat up?
	echo '🙀 meow?!'
	# Read from stdin
	cat <&0
	# Darn you
	echo '😾 hiss'
}

examples() {
	echo '==========================================================='
	echo 'Cat wakes immediately, waits on each snooze'
	echo 'sleepy 6 | catnap 0'
	sleepy 6 | catnap 0

	echo '==========================================================='
	echo 'Cat wakes while sleepy is snoozing, waits on the last half'
	echo 'sleepy 6 | catnap 3'
	sleepy 6 | catnap 3

	echo '==========================================================='
	echo 'Cat sleeps longer, immediately reads all snoozes on wake'
	echo 'sleepy 6 | catnap 7'
	sleepy 6 | catnap 7
}
