#!/bin/bash
src() {
    if [ "$1" ]; then
        source ~/.venvs/$1/bin/activate;
    else 
        source $DEV_BIN"/.bash_profile";
    fi
}

default() {
    defval=''
    for val in "$@"
    do
        test $val && defval=$val && break;
    done
    echo $defval
}

checktime() {
    export CHECK_SECONDS=$((SECONDS-CHECK_SECONDS))
    export ELAPSED=$((CHECK_SECONDS/60)):$((CHECK_SECONDS%60))
    export CHECK_SECONDS=$SECONDS
}

changeprompt() {
    simple_prompt='\$ '
    timer_prompt='$ELAPSED\$ '
    info_prompt='\A:\u:\W\$ '
    export PROMPT_COMMAND=''
    case $1 in
        INFO)
            export PS1=$info_prompt
            ;;
        TIMER)
            export PROMPT_COMMAND=checktime
            export PS1=$timer_prompt
            ;;
        SIMPLE)
            PS1=$simple_prompt
            ;;
        *)
            PS1=$(default $1 $simple_prompt)
    esac
}

count() {
    what=$(default $1 '.')
    where=$(default $2 '.')
    ls -1 $where | grep $what --count
}

tabname() {
    echo -ne "\033]0;$*\007"   
}

cls() {
    clear
    ls
}

space2csv() {
    echo "$@" | sed 's/[ \n\t]\+/,/g'
}

whereami() {
    echo $PWD
}

howami() {
    echo "I'm looking nice.
    My shadow's looking nice.
        We're a real nice team!"

}

whatami() {
    echo "A man, or a mouse."
}

rmcache() {
    find . -name '.cache' | xargs rm -r
}


sublime() {
    echo ">>> Opening sublime with args: $@"
    touch $@
    sublime_app="Sublime Text"
    echo $sublime_app
    open -a "$sublime_app" $@
    echo ">>> $sublime_app running in background"
}

# Java is silly.
jcr() {
    rootdir=$(default $1 '.')
    find $rootdir -name '*.java' | xargs javac
    test $2 && java $2
}