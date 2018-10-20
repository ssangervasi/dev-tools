# Source this file in your actual ~/.bash_profile or ~/.bashrc

# Expose custom path
export DEV_BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="$DEV_BIN:$PATH"

# Tools
source "./aliases.sh"
source "../futility/package.sh"

set_dev_work


# Python
export WORKON_HOME=$HOME/.venvs
export PROJECT_HOME=$DEV_WORK/projects
source /usr/local/bin/virtualenvwrapper.sh 2> /dev/null

# Go
export GOROOT=$DEV_WORK/go

# Custom terminal
source "colors.sh"
changeprompt --info

# Other tools:
add_to_path $DEV_WORK/arcanist/bin \
            /usr/local/go/bin \
            /b/Go/bin \

# Homebrew bash completions
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi