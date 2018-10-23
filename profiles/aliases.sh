##
# Aliases
##

# Handydandy
alias resource='source $HOME/.bashrc $HOME/.bash_profile'
alias '..'='cd ..'
alias '...'='cd $DEV_HOME'
alias ',,,'='cd $DEV_HOME'
alias tree='tree -C'
alias binweb='./bin/web'
alias tt='term-theme'

# Ruby & Rails
alias be='bundle exec'
alias beer='bundle exec rake'
alias beer-taste='RAILS_ENV=test beer'
alias bier='bundle exec rails'
alias berps='spec'
alias belch='bundle exec spring rspec'
alias bemigrate='bundle install && beer db:migrate && beer-taste db:migrate'

# Git
alias gita="git a"
alias gitb="git b"
alias gitl="git l"
alias gits="git s"
alias hamster='git hamster'
alias gitcd='cd $(git root-dir)'

# Lock the screen (OSX only)
MAC_OS_LOCK_SCREEN='/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession'
if [[ -f $MAC_OS_LOCK_SCREEN ]]; then
	alias 'afk'='"$MAC_OS_LOCK_SCREEN" -suspend'
fi

# Alias pip (Win only)
if (! which pip &> /dev/null); then
	alias 'pip'='python -m pip'
fi
