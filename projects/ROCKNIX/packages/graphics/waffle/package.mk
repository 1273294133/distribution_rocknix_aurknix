# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://rocknix.org)
PKG_NAME="waffle"
PKG_LICENSE="BSD"
PKG_VERSION="5f1f48287e806544d745e9a8f5aed47234c61292"
PKG_SITE="https://waffle.freedesktop.org/"
PKG_URL="https://github.com/1273294133/distribution_rocknix_aurknix/releases/download/sources-mirror/waffle-5f1f482.tar.gz"
PKG_SHA256="4a3584b56fc2bb98466eb64f2578a13b75d67328ae16c95b320fa55cbc6afe00"
PKG_DEPENDS_TARGET="toolchain wayland mesa Python3"
PKG_LONGDESC="Waffle - a library for selecting an OpenGL API and window system at runtime"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET+=" -Dwayland=enabled \
                       -Dgbm=enabled \
                       -Dx11_egl=enabled \
                       -Dsurfaceless_egl=enabled \
                       -Dglx=enabled \
                       -Dbuild-examples=false"
