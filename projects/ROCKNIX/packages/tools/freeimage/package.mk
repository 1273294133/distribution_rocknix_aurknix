# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="freeimage"
PKG_VERSION="3180"
PKG_LICENSE="GPLv3"
PKG_SITE="http://freeimage.sourceforge.net/"
PKG_URL="https://deb.debian.org/debian/pool/main/f/freeimage/freeimage_3.18.0+ds2.orig.tar.xz"
PKG_SHA256="4425d04d4691084260848d67eb79949ea7c129d85c73a72066ba609fd3f3aa39"
PKG_DEPENDS_TARGET="toolchain"
PKG_SOURCE_DIR="FreeImage"
PKG_LONGDESC="FreeImage library"

pre_make_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++11 -fPIC -Wno-implicit-function-declaration"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0 -fPIC -Wno-implicit-function-declaration"
}
