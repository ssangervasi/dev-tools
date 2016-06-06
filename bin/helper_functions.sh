#!/bin/bash
src() {
    if [ "$1" ]; then
        source ~/.venvs/$1/bin/activate
    else 
        source ./.bash_profile;
    fi
}

default() {
    defval=''
    for val in "$@"
    do
        echo val;
        test $val && defval=$val && break;
    done
    echo defval
}

count() {
    where='.'
    what='.'

    test ! -z $1 && where=$1
    test ! -z $2 && what=$2

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
