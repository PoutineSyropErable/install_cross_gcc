#!/usr/bin/env bash
set -euo pipefail

# --- Variables ---
CROSS_DIR="$HOME/cross-gcc"
TARGET="ia16-elf"
PREFIX="$CROSS_DIR/install-$TARGET"
BINUTILS_VER="2.39"  # IA-16 patched version


mkdir -p "$CROSS_DIR/state_files"
BIN_UTILS_STATE_FILE="$CROSS_DIR/gcc16_binutils"
GCC_BUILD_STATE_FILE="$CROSS_DIR/gcc16_make"
GCC_INSTALL_STATE_FILE="$CROSS_DIR/gcc16_install"
GCC_LIB_STATE_FILE="$CROSS_DIR/gcc16_lib"

# --- Create directories ---
mkdir -p "$CROSS_DIR/build-binutils-$TARGET" \
         "$CROSS_DIR/build-gcc-$TARGET" \
         "$PREFIX"

# --- Enter CROSS_DIR ---
pushd "$CROSS_DIR" >/dev/null

# --- Download/Extract binutils ---
BINUTILS_TAR="binutils-$BINUTILS_VER.tar.gz"
[[ -f $BINUTILS_TAR ]] || wget "https://github.com/tkchia/build-ia16/releases/download/v2.39/i16butil-$BINUTILS_VER.tar.gz" -O "$BINUTILS_TAR"
[[ -d binutils-$BINUTILS_VER ]] || tar xf "$BINUTILS_TAR"

# --- Clone GCC IA16 fork ---
if [[ ! -d gcc-ia16 ]]; then
    git clone https://github.com/tkchia/gcc-ia16.git
fi

# --- Build functions ---
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
    echo "Building GCC IA16..."
    export PATH="$PREFIX/bin:$PATH"
    pushd "$CROSS_DIR/build-gcc-$TARGET" >/dev/null
    ../gcc-ia16/configure \
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
    echo "Installing GCC IA16..."
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
    echo "true" > "$GCC_LIB_STATE_FILE"
    echo "✅ $TARGET GCC IA16 installed successfully at $PREFIX"
    popd >/dev/null
}

# --- Conditional execution ---
[[ -f $BIN_UTILS_STATE_FILE && $(<"$BIN_UTILS_STATE_FILE") == "true" ]] || build_binutils
[[ -f $GCC_BUILD_STATE_FILE && $(<"$GCC_BUILD_STATE_FILE") == "true" ]] || build_gcc
[[ -f $GCC_INSTALL_STATE_FILE && $(<"$GCC_INSTALL_STATE_FILE") == "true" ]] || install_gcc
[[ -f $GCC_LIB_STATE_FILE && $(<"$GCC_LIB_STATE_FILE") == "true" ]] || install_gcc_lib

# --- Return to original directory ---
popd >/dev/null

