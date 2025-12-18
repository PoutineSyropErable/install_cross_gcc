#!/usr/bin/env bash
set -euo pipefail

# --- Variables ---
CROSS_DIR="$HOME/cross-gcc"
GCC_VER="15.2.0"
BINUTILS_VER="2.42"
TARGET="i686-elf"
PREFIX="$CROSS_DIR/install-$TARGET"

# --- Create directories ---
mkdir -p "$CROSS_DIR" "$CROSS_DIR/build-binutils-$TARGET" "$CROSS_DIR/build-gcc-$TARGET" "$PREFIX"
cd "$CROSS_DIR"

# --- Download binutils ---
BINUTILS_TAR="binutils-$BINUTILS_VER.tar.gz"
if [[ ! -f $BINUTILS_TAR ]]; then
	wget "https://ftp.gnu.org/gnu/binutils/$BINUTILS_TAR"
else
	echo "$BINUTILS_TAR already exists, skipping."
fi
[[ -d binutils-$BINUTILS_VER ]] || tar xf "$BINUTILS_TAR"

# --- Download GCC ---
GCC_TAR="gcc-$GCC_VER.tar.gz"
if [[ ! -f $GCC_TAR ]]; then
	wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/$GCC_TAR"
else
	echo "$GCC_TAR already exists, skipping."
fi
[[ -d gcc-$GCC_VER ]] || tar xf "$GCC_TAR"

# --- Build binutils ---
cd "build-binutils-$TARGET"
../binutils-$BINUTILS_VER/configure \
	--target=$TARGET \
	--prefix=$PREFIX \
	--disable-nls \
	--disable-werror \
	--with-sysroot
make -j"$(nproc)"
make install

# Add binutils to PATH for GCC build
export PATH="$PREFIX/bin:$PATH"

# --- Build GCC ---
cd "../build-gcc-$TARGET"
../gcc-$GCC_VER/configure \
	--prefix=$PREFIX \
	--target=$TARGET \
	--disable-nls \
	--disable-werror \
	--disable-multilib \
	--without-headers \
	--enable-languages=c,c++ \
	--disable-build-format-warnings
make all-gcc -j"$(nproc)"
make install-gcc
# --- Build target runtime libraries ---
make all-target-libgcc -j"$(nproc)"
make install-target-libgcc
# C++ Support (No runtime so cancel the bellow)
if false; then
	make all-target-libstdc++-v3 -j"$(nproc)"
	make install-target-libstdc++-v3
fi
echo "✅ $TARGET GCC $GCC_VER installed successfully at $PREFIX"
