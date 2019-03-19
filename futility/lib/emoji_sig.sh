
killmoji() {
	check_help $@ && killmoji_help && return 0
	local unmojied arg
	for arg in "$@"; do
		unmojied="${unmojied} $(unmoji_sig ${arg})"
	done
	kill ${unmojied}
}

killmoji_help() {
	cat <<-HELP_TEXT
		killmoji - map emoji to signals
			🔪 = INT  = 2 = interrupt
			🔫 = QUIT = 3 = quit
			💣 = KILL = 9 = non-catchable, non-ignorable kill

		kill help:
	HELP_TEXT
	help kill
}

unmoji_sig() {
	local without_dash=$(echo "$1" | sed s/^-//)
	case ${without_dash} in
		🔪) echo '-INT'
			;;
		🔫) echo '-QUIT'
			;;
		💣) echo '-KILL'
			;;
		*) echo "$1"
			;;
	esac
}

# Demonstrate a zombie process
🧟‍♂️() {
	trap 'echo Cannot stop the undead hoard.' INT EXIT QUIT
	while : ; do
		echo Braiinnnnsss...
		sleep 2
	done
}
