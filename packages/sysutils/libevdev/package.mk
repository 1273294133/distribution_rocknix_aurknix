# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libevdev"
PKG_VERSION="1.13.4"
PKG_SHA256="0cfa48d1dddac26988ae9ce16282eff97683f1adcd3f5d4312f86d714565d890"
PKG_LICENSE="MIT"
PKG_SITE="http://www.freedesktop.org/wiki/Software/libevdev/"
PKG_URL="https://github.com/1273294133/distribution_rocknix_aurknix/releases/download/sources-mirror/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="libevdev is a wrapper library for evdev devices."
PKG_BUILD_FLAGS="+pic"

PKG_MESON_OPTS_TARGET=" \
  -Ddefault_library=shared \
  -Ddocumentation=disabled \
  -Dtests=disabled"

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}
