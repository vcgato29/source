#!/bin/bash
#https://github.com/kevinboone/android-audio-sink/archive/0.0.1.tar.gz

VERSION=0.0.2
VVERSION=$VERSION
SUFFIX=tar.gz
NAME=android-audio-sink
DOWNLOAD_URL=https://github.com/kevinboone/android-audio-sink/archive/$VVERSION.$SUFFIX

. ../../env.sh

BUILD_DIR=$STAGING/${NAME}-${VERSION}
TARGET=$BUILD_DIR/$NAME
DEB=$BUILD_DIR/$NAME-${VERSION}_kbox4_${DEB_ARCH}.deb

if [ -f $DEB ]; then
  echo $DEB exists -- delete it to rebuild
  exit 0;
fi

if [ ! -d $BUILD_DIR ]; then 
  mkdir -p $STAGING/tarballs
  TARBALL=$STAGING/tarballs/$NAME-$VERSION.$SUFFIX
  if [ ! -f $TARBALL ]; then 
    echo "Downloading $VERSION"
    wget -O $TARBALL $DOWNLOAD_URL 
  else
    echo "Using cached $TARBALL"
  fi 
  mkdir -p $STAGING
  (cd $STAGING; tar xfvz $TARBALL)
else
  echo "Building cached $NAME-$VERSION"
fi

echo "Running make"

mkdir -p $BUILD_DIR/image/

(cd $BUILD_DIR; make CC=$CC DESTDIR=`pwd`/image all install)

if [[ $? -ne 0 ]] ; then
    echo make install failed ... stopping
    exit 1
fi


echo "Building package"
mkdir -p $BUILD_DIR/out

sed -e s/%ARCH%/$DEB_ARCH/ control | sed -e s/%VERSION%/$VERSION/ > $BUILD_DIR/control

(cd $BUILD_DIR; tar cfz out/data.tar.gz -C image ".") 
(cd $BUILD_DIR; tar cfz out/control.tar.gz ./control) 
echo "2.0" > $BUILD_DIR/out/debian-binary
rm -f $DEB
ar rcs $DEB $BUILD_DIR/out/debian-binary $BUILD_DIR/out/data.tar.gz $BUILD_DIR/out/control.tar.gz 
cp -p $DEB $DIST/ 



