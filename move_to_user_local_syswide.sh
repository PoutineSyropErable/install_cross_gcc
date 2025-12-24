#!/usr/bin/env bash
set -euo pipefail

# Helper function to create symlink if it doesn't exist
link_if_not_exists() {
	local target="$1"
	local link="$2"
	if [[ ! -e "$link" ]]; then
		sudo ln -s "$target" "$link"
		echo "Linked $link -> $target"
	else
		echo "Symlink $link already exists, skipping"
	fi
}

# i686 cross-GCC and G++
link_if_not_exists "$HOME/cross-gcc/install-i686-elf/bin/i686-elf-gcc" "/usr/local/bin/i686-elf-gcc"
link_if_not_exists "$HOME/cross-gcc/install-i686-elf/bin/i686-elf-g++" "/usr/local/bin/i686-elf-g++"
link_if_not_exists "$HOME/cross-gcc/install-i686-elf/bin/i686-elf-objcopy" "/usr/local/bin/i686-elf-objcopy"
link_if_not_exists "$HOME/cross-gcc/install-i686-elf/bin/i686-elf-readelf" "/usr/local/bin/i686-elf-readelf"
link_if_not_exists "$HOME/cross-gcc/install-i686-elf/bin/i686-elf-objdump" "/usr/local/bin/i686-elf-objdump"

link_if_not_exists "$HOME/cross-gcc/install-ia16-elf/bin/ia16-elf-gcc" "/usr/local/bin/ia16-elf-gcc"
link_if_not_exists "$HOME/cross-gcc/install-ia16-elf/bin/ia16-elf-g++" "/usr/local/bin/ia16-elf-g++"

link_if_not_exists "$HOME/cross-gcc/install-x86_64-elf/bin/x86_64-elf-gcc" "/usr/local/bin/x86_64-elf-gcc"
link_if_not_exists "$HOME/cross-gcc/install-x86_64-elf/bin/x86_64-elf-g++" "/usr/local/bin/x86_64-elf-g++"

if false; then
	for arch in i686 ia16 x86_64; do
		for compiler in gcc g++; do
			target="$HOME/cross-gcc/install-$arch-elf/bin/$arch-elf-$compiler"
			link="/usr/local/bin/$arch-elf-$compiler"
			link_if_not_exists "$target" "$link"
		done
	done

fi
