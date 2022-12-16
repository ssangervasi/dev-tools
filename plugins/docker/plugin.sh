
alias d="docker"
alias dc="docker-compose"

source_if_exists /Applications/Docker.app/Contents/Resources/etc/docker
source_if_exists /Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion

complete -F _docker d
complete -F _docker_compose dc

dc-bash() {
	dc run --rm "$@" bash -i
}

# Run bash in a docker container with init file. Wacky!
# dc run container bash -c "bash --init-file <(cat <<< 'fun() { echo whee; };' )"