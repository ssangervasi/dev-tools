#!/bin/bash

whereami() {
	echo $PWD
}

howami() {
	cat <<-NICE
		I'm looking nice.
			My shadow's looking nice.
				We're a real nice team!
	NICE
}

whatami() {
	echo "A man, or a mouse."
}

whyami() {
	echo "You pass butter."
}

whenami() {
	date
}
