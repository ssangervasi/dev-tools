# Giffing

JIPH_FPS=30
JIPH_QUALITY=90

video_to_frames() {
	check_help $@ &&
		echo '$1<input_path> -> ./frames/*.png' &&
		return 0

	mkdir -p ./frames
	rm ./frames/*.png

	ffmpeg \
		-i "$1" \
		-r $JIPH_FPS './frames/frame%04d.png'
}

frames_to_gif() {
	check_help $@ &&
		echo './frames/*.png -> $1<output_path>' &&
		return 0

	gifski \
		--fps $JIPH_FPS \
		--quality $JIPH_QUALITY \
		--output "$1" \
		./frames/*.png
}


