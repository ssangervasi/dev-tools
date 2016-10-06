# Source this file in your actual ~/.bash_profile or ~/.bashrc

# Expose custom path
export DEV_BIN="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PATH="$DEV_BIN:$PATH"

if (test -z $DEV_WORK); then
    dev_envs="workspace Documents/workspace repo"
    for work in $dev_envs; do
        if (test -d ~/$work ); then
            DEV_WORK=$work
            break
        fi
    done
    export DEV_WORK
fi

# Tools
source "aliases.sh"
source "helper_functions.sh"

# Custom terminal
source "colors.sh"
changeprompt INFO

# Other tools:
add_to_path="$DEV_WORK/arcanist/bin
             /usr/local/go/bin"
for path_dir in $add_to_path; do
    if (test -d $path_dir); then
        export PATH=$path_dir":"$PATH
    fi
done