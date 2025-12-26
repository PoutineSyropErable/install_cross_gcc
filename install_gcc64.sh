#!/usr/bin/env bash
set -euo pipefail

# --- Variables ---
CROSS_DIR="$HOME/cross-gcc"
GCC_VER="15.2.0"
BINUTILS_VER="2.42"
TARGET="x86_64-elf"
PREFIX="$CROSS_DIR/install-$TARGET"

mkdir -p "$CROSS_DIR/state_files"
BIN_UTILS_STATE_FILE="$CROSS_DIR/state_files/gcc64_binutils"
GCC_BUILD_STATE_FILE="$CROSS_DIR/state_files/gcc64_make"
GCC_INSTALL_STATE_FILE="$CROSS_DIR/state_files/gcc64_install"
GCC_LIB_STATE_FILE="$CROSS_DIR/state_files/gcc64_lib"

# --- Create directories ---
mkdir -p "$CROSS_DIR" \
         "$CROSS_DIR/build-binutils-$TARGET" \
         "$CROSS_DIR/build-gcc-$TARGET" \
         "$PREFIX"

# --- Ensure starting from CROSS_DIR ---
pushd "$CROSS_DIR" >/dev/null

# --- Download binutils ---
BINUTILS_TAR="binutils-$BINUTILS_VER.tar.gz"
[[ -f $BINUTILS_TAR ]] || wget "https://ftp.gnu.org/gnu/binutils/$BINUTILS_VER/$BINUTILS_TAR"
[[ -d binutils-$BINUTILS_VER ]] || tar xf "$BINUTILS_TAR"

# --- Download GCC ---
GCC_TAR="gcc-$GCC_VER.tar.gz"
[[ -f $GCC_TAR ]] || wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VER/$GCC_TAR"
[[ -d gcc-$GCC_VER ]] || tar xf "$GCC_TAR"

# --- Functions ---
build_binutils() {
    echo "Building binutils..."
    pushd "$CROSS_DIR/build-binutils-$TARGET" >/dev/null
    ../binutils-$BINUTILS_VER/configure \
        --target=$TARGET \
        --prefix=$PREFIX \
        --disable-nls \
        --disable-werror \
        --with-sysroot
    make -j"$(nproc)"
    make install
    echo "true" > "$BIN_UTILS_STATE_FILE"
    popd >/dev/null
}

build_gcc() {
    echo "Building GCC..."
    export PATH="$PREFIX/bin:$PATH"
    pushd "$CROSS_DIR/build-gcc-$TARGET" >/dev/null
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
    echo "true" > "$GCC_BUILD_STATE_FILE"
    popd >/dev/null
}

install_gcc() {
    echo "Installing GCC..."
    pushd "$CROSS_DIR/build-gcc-$TARGET" >/dev/null
    make install-gcc
    echo "true" > "$GCC_INSTALL_STATE_FILE"
    popd >/dev/null
}

install_gcc_lib() {
    echo "Building target runtime libraries..."
    pushd "$CROSS_DIR/build-gcc-$TARGET" >/dev/null
    make all-target-libgcc -j"$(nproc)"
    make install-target-libgcc
    # Optional C++ runtime
    if false; then
        make all-target-libstdc++-v3 -j"$(nproc)"
        make install-target-libstdc++-v3
    fi
    echo "true" > "$GCC_LIB_STATE_FILE"
    echo "✅ $TARGET GCC $GCC_VER installed successfully at $PREFIX"
    popd >/dev/null
}

# --- Conditional execution ---
[[ -f $BIN_UTILS_STATE_FILE && $(<"$BIN_UTILS_STATE_FILE") == "true" ]] || build_binutils
[[ -f $GCC_BUILD_STATE_FILE && $(<"$GCC_BUILD_STATE_FILE") == "true" ]] || build_gcc
[[ -f $GCC_INSTALL_STATE_FILE && $(<"$GCC_INSTALL_STATE_FILE") == "true" ]] || install_gcc
[[ -f $GCC_LIB_STATE_FILE && $(<"$GCC_LIB_STATE_FILE") == "true" ]] || install_gcc_lib

# --- Return to original directory ---
popd >/dev/null




