#!/bin/sh

rm -rf tools/work
rm tools/_clean_attrs.sed
rm tools/_clean_style_attr.sed
rm tools/ffsvg.sh
rm tools/_fix_color_scheme.sh
rm tools/flathub_list_updater.sh
rm tools/missing_flathub_apps.sh
rm tools/_scour.sh
rm tools/svgo.config.js

rm preview.png
rm install.sh
rm uninstall.sh



for dir in "Papirus" "Papirus-Dark" "Papirus-Light" "ePapirus" "ePapirus-Dark"; do

    # delete all non-folder-mategreen icons
    find ${dir} ! -name "folder-mategreen*" > icons_for_removal.txt
    # exceptions
    sed -i -e '/user-mategreen-desktop.svg/d' icons_for_removal.txt
    xargs rm < icons_for_removal.txt
    # delete empty directories
    find . -type d | xargs rmdir

done
