#!/bin/sh

# TODO check arguments
SRC=$1
DEST=$2
GPG_RECIPIENT="max@froumentin.net"

# TODO:
# - test suite
# - dry-run option
# - symlinks ?

function encrypt() {
    echo "* Encrypting $1"
    nice gpg --batch --yes --recipient $GPG_RECIPIENT --output "$DEST/$1.enc" --encrypt "$1"
}
export -f encrypt

# recreate directory structure
function copy_dirs() {
    echo Copying directory structure
    find $SRC -type d -exec mkdir -p ${DEST}/{} \;
}

# encrypt all files that haven't been yet or that are newer than their existing encrypted version
function copy_encrypt() {
    echo Encrypting new or recently modified files
    find $SRC  -type f | while read source_file; do
        # look if this file is encrypted
        prefix=$SRC
        target_file=$DEST/${source_file}.enc
        if [[ ! -f $target_file || ($source_file -nt $target_file) ]]; then
            encrypt $source_file
        fi
    done
}

function delete_extra_files() {
    echo Looking for deleted directories in source
    find $DEST/$SRC -type d | while read dir; do
        prefix=$DEST/
        name=${dir#$prefix}
        if ! [ -e $name ]; then
            echo removing dir $dir
            rm -r $dir
        fi
    done

    echo Looking for deleted files in source
    find $DEST/$SRC -type f | while read file; do
        suffix=".enc"
        prefix=$DEST/
        name=${file#$prefix}
        name=${name%$suffix}
        if ! [ -e $name ]; then
                echo removing file $file
                rm $file
        fi
    done
}

copy_dirs
copy_encrypt
delete_extra_files
