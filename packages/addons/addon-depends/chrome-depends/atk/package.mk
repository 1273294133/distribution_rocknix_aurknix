# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="atk"
PKG_VERSION="2.38.0"
PKG_SHA256="ac4de2a4ef4bd5665052952fe169657e65e895c5057dffb3c2a810f6191a0c36"
PKG_LICENSE="GPL"
PKG_SITE="http://library.gnome.org/devel/atk/"
PKG_URL="https://ftp.gnome.org/pub/gnome/sources/atk/${PKG_VERSION:0:4}/atk-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain glib"
PKG_LONGDESC="Provides the set of accessibility interfaces that are implemented by other applications."
PKG_BUILD_FLAGS="+pic"

PKG_MESON_OPTS_TARGET="-Ddocs=false \
                       -Dintrospection=false"

pre_configure_target() {
  # glib 2.85+ ships pc tool variables expanded to host /usr/bin (glib_genmarshal etc),
  # which meson refuses during cross configure. Rewrite them in the shared sysroot
  # before atk's meson setup runs (belt & braces; glib post_makeinstall also does this
  # but only when glib is actually rebuilt).
  sed -e "s#/usr/bin/glib-genmarshal#${TOOLCHAIN}/bin/glib-genmarshal#" \
      -e "s#/usr/bin/glib-mkenums#${TOOLCHAIN}/bin/glib-mkenums#" \
      -e "s#/usr/bin/gobject-query#${TOOLCHAIN}/bin/gobject-query#" \
      -i "${PKG_ORIG_SYSROOT_PREFIX}/usr/lib/pkgconfig/"{gio,glib}-2.0.pc 2>/dev/null || true
}
