#!/bin/sh

# TODO check arguments
SRC=$1
DEST=$2
GPG_RECIPIENT="max@froumentin.net"
REFTIMEFILE=$DEST/reftime

# TODO:
# - test suite
# - possible name conflicts with reftime
# - dry-run option
# - symlinks

function encrypt() {
    echo Encrypting $1
echo    nice gpg --batch --yes --recipient $GPG_RECIPIENT --output "$DEST/$1.enc" --encrypt "$1"
}
export -f encrypt

# recreate directory structure TODO: necessary each time?
function copy_dirs() {
    echo Copying directory structure
    find $SRC -type d -exec mkdir -p ${DEST}/{} \;
}

#if there's a reftime file, copy+encrypt only the files that changed since the last modified time of reftime
function copy_encrypt() {
    if [ -e $REFTIMEFILE ]; then
        echo Encrypting all files that have changed since the last sync on `stat -f %Sm $REFTIMEFILE`
        cp $DEST/reftime /tmp/newreftime
        find $SRC -type f -newer $DEST/reftime -exec bash -c 'encrypt "{}"' \;
        mv /tmp/newreftime $DEST/reftime
    else
        # otherwise encrypt+copy everything
        echo Encrypting all files in $DEST/$SRC
        touch $DEST/reftime
        find $SRC -type f -exec bash -c 'encrypt "{}"' \;
    fi
    echo Finished.
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
