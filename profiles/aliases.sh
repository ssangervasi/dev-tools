##
# Aliases
##

# Handydandy
alias resource='source $HOME/.bashrc $HOME/.bash_profile'
alias '..'='cd ..'
alias '...'='cd $DEV_HOME'
alias ',,,'='cd $DEV_HOME'
TREE_DEFAULT_OPTIONS='--dirsfirst -C'
alias tree='tree ${TREE_DEFAULT_OPTIONS}'
alias binweb='./bin/web'
alias tt='term-theme'
alias 'pgrep'='pgrep -lfi'
alias lsa='ls -A1lh'

# Originally for Rails, but made more generic.
alias taste='RAILS_ENV=test RACK_ENV=test FLASK_ENV=test'

# Ruby & Rails
alias be='bundle exec'
alias beer='bundle exec rake'
alias bier='bundle exec rails'
alias berps='spec'
alias belch='bundle exec spring rspec'
alias bemigrate='bundle install && beer db:migrate && taste beer db:migrate'

# Git
alias gita="git a"
alias gitb="git b"
alias gitl="git l"
alias gits="git s"
alias hamster='git hamster'
alias new='git new'

# Lock the screen (OSX only)
MAC_OS_LOCK_SCREEN='/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession'
if [[ -f $MAC_OS_LOCK_SCREEN ]]; then
	alias 'afk'='"$MAC_OS_LOCK_SCREEN" -suspend'
fi

# Alias pip (Win only)
if (! which pip &> /dev/null); then
	alias 'pip'='python -m pip'
fi

# Bat
BAT_DEFAULT_OPTIONS='--paging always'
alias 'bat'='bat ${BAT_DEFAULT_OPTIONS}'
