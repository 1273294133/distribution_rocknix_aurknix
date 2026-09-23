# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="freeimage"
PKG_VERSION="3180"
PKG_LICENSE="GPLv3"
PKG_SITE="http://freeimage.sourceforge.net/"
PKG_URL="https://github.com/1273294133/distribution_rocknix_aurknix/releases/download/sources-mirror/danoli3.zip"
PKG_SHA256="bf80ca15bba3072e8c7944da8b887bf8c3e654b382b589e28900fd381e9131c7"
PKG_DEPENDS_TARGET="toolchain"
PKG_SOURCE_DIR="FreeImage-master"
PKG_LONGDESC="FreeImage library"
PKG_STAMP="danoli3-rebuild-20260923"

pre_make_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++11 -fPIC -Wno-implicit-function-declaration"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0 -fPIC -Wno-implicit-function-declaration"
}

post_makeinstall_target() {
  # danoli3 fork Makefile installs lib + headers but no pkg-config file;
  # emulationstation does find_package(freeimage) via pkg-config -> provide one.
  mkdir -p "${SYSROOT_PREFIX}/usr/lib/pkgconfig"
  cat > "${SYSROOT_PREFIX}/usr/lib/pkgconfig/freeimage.pc" <<'EOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: FreeImage
Description: FreeImage - multi-format image loading library
Version: 3.18.0
Libs: -L${libdir} -lfreeimage
Cflags: -I${includedir}
EOF
}
