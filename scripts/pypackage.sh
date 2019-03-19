
mkpy() {
    test $1 && mkdir -p $1
    init_dir=$(default $1 '.')
    touch $init_dir/__init__.py
}

pypackage() {
    # Bleh args whatever.
    source_dir=$(default $1 '.')
    source_name=$(basename $source_dir)
    target_dir=$(default $2 ./$source_name)
    package_name=$(basename $target_dir)
    # Do stuff.
    mkdir -p $target_dir
    mkpy $target_dir/$package_name
    mv $source_dir/* $target_dir/$package_name
    cp -r $DEV_BIN/py-templates/* $target_dir
}

