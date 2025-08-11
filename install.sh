#!/bin/bash

#################################################
# install script for Picture Label service menu #
#################################################

#  check for installation of basic KDE commands
if [ ! `command -v awk` ] || [ ! `command -v sed` ] || [ ! `command -v kdialog` ] ; then
	echo "Cannot find either \"awk\", \"sed\", or \"kdialog\".  Please check your system installation."
	exit
fi

# check for installation of either IM-6, IM-7, or IM-7 appimage
if [ ! `command -v convert` ] ; then
# 	echo "Cannot find  \"convert\".  Please check your system installation."
	((strikes++))
fi
if [ ! `command -v magick` ]; then
# 	echo "Cannot find  \"magic\".  Please check your system installation."
	((strikes++))
fi
if [ ! `command -v imagemagick` ]; then
# 	echo "Cannot find  \"imagemagic\".  Please check your system installation."
	((strikes++))
fi
if [ $strikes -eq 3 ]; then
	echo "Cannot find any installation of \"imagemagic\".  Please check your system installation."
	exit
fi

# places the .desktop file in either
# ~/.local/share/kio/servicemenus/
# or
# ~/.local/share/kservices5/
# depending on which version of plasma is running
# creating a folder path for the user, if necessary

if [[ "$KDE_SESSION_VERSION" == "6" ]]; then
    INSTALL_DIR="$HOME/.local/share/kio/servicemenus"
    if [[ ! -d $INSTALL_DIR ]]; then
        # There is no local configuration path so must be created.
        mkdir -p "$INSTALL_DIR"
    fi
else
    INSTALL_DIR="$HOME/.local/share/kservices5/"
    if [[ ! -d $INSTALL_DIR ]]; then
        # There is no local configuration path so must be created.
        mkdir -p "$INSTALL_DIR"
    fi
fi

# make a folder to hold the scripts and database files
# copy all the files into their proper location

mkdir -p $INSTALL_DIR/PictureLabel
cp -f picture_label.desktop $INSTALL_DIR/picture_label.desktop
cp -f picture-label.sh $INSTALL_DIR/PictureLabel/picture-label.sh
cp -f settings.sh $INSTALL_DIR/PictureLabel/settings.sh
cp -f setdb.txt $INSTALL_DIR/PictureLabel/setdb.txt
cp -f setdb.txt.bak $INSTALL_DIR/PictureLabel/setdb.txt.bak

# modify the path statements of installed .desktop and .sh files
# and make the .desktop and .sh files executable

sed -i "s|PATH_HOLDER|$INSTALL_DIR|" $INSTALL_DIR/picture_label.desktop
chmod +x $INSTALL_DIR/picture_label.desktop

sed -i "s|PATH_HOLDER|$INSTALL_DIR|" $INSTALL_DIR/PictureLabel/picture-label.sh
chmod +x $INSTALL_DIR/PictureLabel/picture-label.sh

sed -i "s|PATH_HOLDER|$INSTALL_DIR|" $INSTALL_DIR/PictureLabel/settings.sh
chmod +x $INSTALL_DIR/PictureLabel/settings.sh

echo
echo Picture Label servicemenu -- Installation Complete
echo
