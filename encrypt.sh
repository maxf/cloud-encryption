#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source_directory target_directory"
    exit
fi

SRC=$1
DEST=$2
GPG_RECIPIENT="max@froumentin.net"

# TODO:
# - test suite
# - dry-run option
# - symlinks ?

function encrypt() {
    echo "* Encrypting $1 to $2"
    nice gpg --batch --yes --recipient $GPG_RECIPIENT --output "$2" --encrypt "$1"
}
export -f encrypt

# recreate directory structure
function copy_dirs() {
    echo Copying directory structure
    mkdir -p $DEST
    find $SRC/* -type d | while read source_dir; do
        mkdir -p ${DEST}/${source_dir#$SRC/}
    done
}

# encrypt all files that haven't been yet or that are newer than their existing encrypted version
function copy_encrypt() {
    echo Encrypting new or recently modified files
    find $SRC -type f | while read source_file; do
        # look if this file is encrypted
        target_file=$DEST/${source_file#$SRC/}.enc
        if [[ ! -f $target_file || ($source_file -nt $target_file) ]]; then
            encrypt $source_file $target_file
        fi
    done
}

function delete_extra_files_in_dest() {
    echo Looking for deleted dirs in source and delete corresponding dirs in destination
    find $DEST/* -type d | while read dirname_in_dest; do
        dirname_in_source=$SRC/${dirname_in_dest#$DEST/}
        if ! [ -e $dirname_in_source ]; then
            echo removing dir $dirname_in_dest
            rm -rf $dir
        fi
    done

    echo Looking for deleted files in source and delete corresponding encrypted files
    find $DEST -type f | while read filename_in_dest; do
        suffix=".enc"
        filename_in_source=${filename_in_dest#$DEST/}
        filename_in_source=${name%$suffix}
        if ! [ -e $filename_in_source ]; then
            echo removing file $filename_in_dest
            rm -f $filename_in_dest
        fi
    done
}

copy_dirs
copy_encrypt
delete_extra_files_in_dest
