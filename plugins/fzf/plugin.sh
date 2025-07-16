# fzf cd
cf() {
  local dir
  dir=$(find ${1:-.} -maxdepth 1 -type d -or -type l 2> /dev/null | fzf +m) && cd "$dir"
}