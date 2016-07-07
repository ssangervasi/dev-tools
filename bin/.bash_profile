# Expose custom path
# Put this in the actual ~/.bash_profile or ~/.bashrc
export DEV_BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="$DEV_BIN:$PATH"

# Tools
source "aliases.sh"
source "helper_functions.sh"

# Custom terminal
source "colors.sh"
changeprompt INFO

# Bash completion (OSX only)
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi