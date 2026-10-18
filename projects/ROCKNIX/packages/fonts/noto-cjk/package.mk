# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present AURKNIX (https://github.com/1273294133/distribution_rocknix_aurknix)

PKG_NAME="noto-cjk"
PKG_VERSION="20261018"
PKG_LICENSE="OFL-1.1"
PKG_SITE="https://github.com/notofonts/noto-cjk"
PKG_URL="https://github.com/1273294133/distribution_rocknix_aurknix/releases/download/sources-mirror/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_SHA256="b86f34a0400b84ed8afd2c433add767a216a5e2606c17c2d91c5d282a32f98a5"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Noto Sans CJK SC - Simplified Chinese font for CJK menu/OSD rendering"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/fonts/truetype/noto/
  cp ${PKG_BUILD}/NotoSansCJKsc-Regular.otf ${INSTALL}/usr/share/fonts/truetype/noto/
}
