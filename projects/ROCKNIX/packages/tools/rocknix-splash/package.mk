# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-splash"
PKG_VERSION="master"
PKG_LICENSE="GPL"
# Fork with per-device splash brands: RK3326-family builds R36S wordmark (big
# "R36S" centered + small "AURKNIX" right-bottom), other devices keep AURKNIX.
PKG_SITE="https://github.com/1273294133/aurknix-splash"
PKG_URL="${PKG_SITE}/archive/refs/heads/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_INIT="toolchain"
PKG_LONGDESC="ROCKNIX splash screen application"
