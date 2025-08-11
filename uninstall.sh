#!/bin/bash

######################################################
# uninstall script for the Picture Label servicemenu #
######################################################

# removes the .desktop file from either
# ~/.local/share/kio/servicemenus/
# or
# ~/.local/share/kio/servicemenus/
# depending on where the folder PictureLabel is found
# and then deletes the folder.


if [[ -d $HOME/.local/share/kio/servicemenus/PictureLabel ]]; then
    rm $HOME/.local/share/kio/servicemenus/picture_label.desktop
    rm -rf $HOME/.local/share/kio/servicemenus/PictureLabel
else
    rm $HOME/.local/share/kservices5/picture_label.desktop
    rm -rf $HOME/.local/share/kservices5/PictureLabel
fi

echo
echo Picture Label servicemenu -- uninstalled
echo
