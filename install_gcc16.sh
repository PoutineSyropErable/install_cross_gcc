#!/usr/bin/env bash
set -euo pipefail

# --- Variables ---
CROSS_DIR="$HOME/cross-gcc"
GCC_VER="15.2.0"
BINUTILS_VER="2.42"
TARGET="ia16-elf"
PREFIX="$CROSS_DIR/install-$TARGET"

mkdir -p "$CROSS_DIR/build-binutils-$TARGET" "$CROSS_DIR/build-gcc-$TARGET" "$PREFIX"
cd "$CROSS_DIR"

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
cd ../build-gcc-"$TARGET"
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

echo "✅ $TARGET GCC $GCC_VER installed successfully at $PREFIX"
