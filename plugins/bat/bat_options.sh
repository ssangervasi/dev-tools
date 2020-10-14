# Bat
BAT_DEFAULT_OPTIONS='--paging always'
alias 'bat'='bat ${BAT_DEFAULT_OPTIONS}'

batwitch() {
	bat "$(which $1)"
}
alias whichat=batwitch