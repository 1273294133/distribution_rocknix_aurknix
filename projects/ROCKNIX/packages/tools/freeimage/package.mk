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

pre_make_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++11 -fPIC -Wno-implicit-function-declaration"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0 -fPIC -Wno-implicit-function-declaration"
}
