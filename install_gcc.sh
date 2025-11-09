#!/usr/bin/env bash
set -euo pipefail

# --- Variables ---
CROSS_DIR="$HOME/cross-gcc"
GCC_VER="15.2.0"
BINUTILS_VER="2.42"
TARGET="i686-elf"
PREFIX="$CROSS_DIR/install-i686"

# --- Create directories ---
mkdir -p "$CROSS_DIR" "$CROSS_DIR/build-binutils-i686" "$CROSS_DIR/build-gcc-i686" "$PREFIX"
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
cd build-binutils-i686
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
cd ../build-gcc-i686
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

echo "✅ i686-elf GCC $GCC_VER installed successfully at $PREFIX"
