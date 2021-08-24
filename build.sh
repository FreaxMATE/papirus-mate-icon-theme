#!/usr/bin/env bash

set -e -o pipefail

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

SRC_DIR="$SCRIPT_DIR/papirus-icon-theme"
DST_DIR="$SCRIPT_DIR"

headline() {
	printf "%b => %b%s\n" "\e[1;32m" "\e[0m" "$*"
}

recolor() {
	# args: <old colors> <new colors> <path to file>
	IFS=" " read -ra old_colors <<< "$1"
	IFS=" " read -ra new_colors <<< "$2"
	local filepath="$3"

	[ -f "$filepath" ] || exit 1

	for (( i = "${#old_colors[@]}" - 1; i >= 0; i-- )); do
		sed -i "s/${old_colors[$i]}/${new_colors[$i]}/gI" "$filepath"
	done
}

_rm_dir() {
	test -d "$1" || return 0  # is a dir
	test -L "$1" && return 0  # is not a symlink
	echo "Removing directory '$1'..." >&2
	rm -rf "$1"
}

_rm_symlink() {
	test -L "$1" || return 0  # is a symlink
	echo "Removing symlink '$1'..." >&2
	rm -f "$1"
}

declare -a PLACES_DIRS=(
	"16x16/places"
	"22x22/places"
	"24x24/places"
	"32x32/places"
	"48x48/places"
	'64x64/places'
)

declare -a ICON_THEMES=(
	# Parent theme
	"Papirus-MATE"
	# Child themes
	"Papirus-MATE-Dark"
	"Papirus-MATE-Light"
)

declare -A COLORS=(
	# [0] - primary color
	# [1] - secondary color
	# [2] - color of symbol
	# [3] - color of paper
	#
	# | name     | [0]   | [1]   | [2]   | [3]   |
	# |----------|-------|-------|-------|-------|
	[blue]="      #5294e2 #4877b1 #1d344f #e4e4e4"
	[mategreen]=" #97bb72 #77a050 #2f3e1f #e4e4e4"
)


headline "Cleanup before building ..."
# -----------------------------------------------------------------------------
for icon_theme in "${ICON_THEMES[@]}"; do
	for dir in "${PLACES_DIRS[@]%%/*}"; do
		_rm_dir "${DST_DIR:?}/$icon_theme/$dir"
	done
done


headline "Coping places icons from Papirus to Papirus-MATE icon theme ..."
# -----------------------------------------------------------------------------
src_theme_dir="$SRC_DIR/${ICON_THEMES[0]//-MATE/}"
dst_theme_dir="$DST_DIR/${ICON_THEMES[0]}"

echo "DST_THEME_DIR: $dst_theme_dir"
echo "SRC_THEME_DIR: $src_theme_dir"

for places_dir in "${PLACES_DIRS[@]}"; do
	[ -d "$src_theme_dir/$places_dir" ] || continue
	size_dir="${places_dir%%/*}"
	mkdir -p "$dst_theme_dir/$size_dir"
	cp -R --reflink=auto "$src_theme_dir/$places_dir" "$dst_theme_dir/$size_dir"
done


headline "Coping places icons from ${ICON_THEMES[1]//-MATE/} to ${ICON_THEMES[1]} theme ..."
# -----------------------------------------------------------------------------
src_dark_theme_dir="$SRC_DIR/${ICON_THEMES[1]//-MATE/}"
dst_dark_theme_dir="$DST_DIR/${ICON_THEMES[1]}"

if [ -d "$src_dark_theme_dir" ]; then
	mkdir -p "$dst_dark_theme_dir/16x16"
	cp -R --reflink=auto "$src_dark_theme_dir/16x16/places" \
		"$dst_dark_theme_dir/16x16"
fi


# Change folder color
default_color="blue"
new_folder_color="mategreen"
sizes_regex="(16x16|22x22|24x24|32x32|48x48|64x64)"
icons_regex="(folder|user)-"


headline "Creating mategreen folder icons ..."
# -----------------------------------------------------------------------------
find "$dst_theme_dir" "$dst_dark_theme_dir" -type f -regextype posix-extended \
	-regex ".*/${sizes_regex}/places/${icons_regex}${default_color}[-\.].*" \
	-print0 | while read -r -d $'\0' file; do

	new_file="${file/-$default_color/-$new_folder_color}"

	cp -P --remove-destination "$file" "$new_file"
	recolor "${COLORS[$default_color]}" "${COLORS[$new_folder_color]}" "$new_file"
done


headline "Changing blue folder color to mategreen ..."
# -----------------------------------------------------------------------------
declare -a color=$new_folder_color # "mategreen"
declare -a size prefix file_path file_name symlink_path
declare -a sizes=(22x22 24x24 32x32 48x48 64x64)
declare -a prefixes=("folder-$color" "user-$color")

for size in "${sizes[@]}"; do
	for prefix in "${prefixes[@]}"; do
		for file_path in "$dst_theme_dir/$size/places/$prefix"{-*,}.svg; do
			[ -f "$file_path" ] || continue  # is a file
			[ -L "$file_path" ] && continue  # is not a symlink

			file_name="${file_path##*/}"
			symlink_path="${file_path/-$color/}"  # remove color suffix

			ln -sf "$file_name" "$symlink_path" || {
				fatal "Fail to create '$symlink_path' symlink"
			}
		done
	done
done

headline "Changing color in .ColorScheme-Highlight class of monochrome icons ..."
# -----------------------------------------------------------------------------
for icon_theme in "${ICON_THEMES[@]}"; do
	find "$DST_DIR/$icon_theme" -type f -name '*.svg' \
		-exec sed -i 's/color:#4285f4;/color:#97bb72;/gI' '{}' \;
done
