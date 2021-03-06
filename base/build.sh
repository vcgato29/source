#!/bin/sh

. ../env.sh

BUILD_DIR=$STAGING/kbox4-base-installer

(cd busybox; ./build.sh)
if [[ $? -ne 0 ]] ; then
    echo busybox build failed ... stopping
    exit 1
fi
(cd kbox_shell; ./build.sh)
if [[ $? -ne 0 ]] ; then
    echo kbox_shell build failed ... stopping
    exit 1
fi
(cd libfakechroot; ./build.sh)
if [[ $? -ne 0 ]] ; then
    echo libfakechroot build failed ... stopping
    exit 1
fi
(cd unzip60; ./build.sh)
if [[ $? -ne 0 ]] ; then
    echo unzip60 build failed ... stopping
    exit 1
fi

mkdir -p $BUILD_DIR

mkdir -p $DIST
ZIP=/tmp/kbox4-base-installer.zip
TARGET=$DIST/kbox4-install-base-$DEB_ARCH

cp installer/* $BUILD_DIR

cp $STAGING/kbox_shell-0.0.1/kbox_shell $BUILD_DIR/
android-elf-cleaner $BUILD_DIR/kbox_shell

cp $STAGING/fakechroot-2.16/libfakechroot.so $BUILD_DIR/
android-elf-cleaner $BUILD_DIR/libfakechroot.so

cp $STAGING/busybox-1.26.2/busybox $BUILD_DIR/
android-elf-cleaner $BUILD_DIR/busybox

(cd $STAGING; echo "\$AUTORUN\$>./kbox4-base-installer/install.sh" | zip -z -r $ZIP kbox4-base-installer)
cat $STAGING/unzip60/unzipsfx $ZIP > $TARGET 

android-elf-cleaner $TARGET

rm $ZIP

