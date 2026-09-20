# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="fontconfig"
PKG_VERSION="2.17.1"
PKG_SHA256="f07504cef87f171ee1748352e2df9b9f125352f620fa0d03a9284306ea2c40a4"
PKG_LICENSE="OSS"
PKG_SITE="https://www.freedesktop.org/wiki/Software/fontconfig/"
PKG_URL="https://deb.debian.org/debian/pool/main/f/fontconfig/fontconfig_${PKG_VERSION}.orig.tar.gz"
PKG_SOURCE_DIR="fontconfig-${PKG_VERSION}-6d0a98982ec351c165c9224c8b7dbdfca3010e47"
PKG_DEPENDS_TARGET="toolchain util-linux util-macros freetype libxml2 zlib expat"
PKG_LONGDESC="Fontconfig is a library for font customization and configuration."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--with-arch=${TARGET_ARCH} \
                           --with-cache-dir=/storage/.cache/fontconfig \
                           --with-default-fonts=/usr/share/fonts \
                           --without-add-fonts \
                           --disable-dependency-tracking \
                           --disable-docs \
                           --disable-rpath"

pre_configure_target() {
  # ensure we dont use '-O3' optimization.
  CFLAGS=$(echo ${CFLAGS} | sed -e "s|-O3|-O2|")
  CXXFLAGS=$(echo ${CXXFLAGS} | sed -e "s|-O3|-O2|")
  CFLAGS+=" -I${PKG_BUILD}"
  CXXFLAGS+=" -I${PKG_BUILD}"
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
