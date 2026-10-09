# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pango"
PKG_VERSION="1.56.1"
PKG_SHA256="426be66460c98b8378573e7f6b0b2ab450f6bb6d2ec7cecc33ae81178f246480"
PKG_LICENSE="GPL"
PKG_SITE="http://www.pango.org/"
PKG_URL="https://download.gnome.org/sources/pango/${PKG_VERSION:0:4}/pango-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain cairo freetype fontconfig fribidi glib json-glib harfbuzz"
PKG_DEPENDS_CONFIG="cairo"
PKG_LONGDESC="The Pango library for layout and rendering of internationalized text."

configure_package() {
  # Build with X11 support
  if [ ${DISPLAYSERVER} = "x11" ]; then
    PKG_DEPENDS_TARGET+=" libX11 libXft"
    PKG_DEPENDS_CONFIG+=" libXft"
    PKG_BUILD_FLAGS="-sysroot"
  fi
}

pre_configure_target() {
  # pango's meson falls back to its bundled glib wrap subproject whenever the
  # toolchain glib-2.0.pc is not visible (arm builds install glib pc under
  # usr/lib32 which is not on the default PKG_CONFIG_LIBDIR; a concurrent glib
  # rebuild can also temporarily hide it). The wrap download on the runner is
  # unreliable and fails hard ("Subproject exists but has no meson.build").
  # Drop the wrap, wait briefly for the toolchain glib pc, mirror it into
  # usr/lib, and add usr/lib32 to the search path so meson must use the
  # toolchain glib.
  rm -rf ${PKG_BUILD}/subprojects
  for i in $(seq 1 30); do
    if [ -f ${SYSROOT_PREFIX}/usr/lib/pkgconfig/glib-2.0.pc ] || \
       [ -f ${SYSROOT_PREFIX}/usr/lib32/pkgconfig/glib-2.0.pc ]; then
      break
    fi
    sleep 5
  done
  for base in glib-2.0.pc gio-2.0.pc gobject-2.0.pc gmodule-2.0.pc gthread-2.0.pc gio-unix-2.0.pc; do
    if [ -f ${SYSROOT_PREFIX}/usr/lib32/pkgconfig/${base} ] && [ ! -f ${SYSROOT_PREFIX}/usr/lib/pkgconfig/${base} ]; then
      cp -f ${SYSROOT_PREFIX}/usr/lib32/pkgconfig/${base} ${SYSROOT_PREFIX}/usr/lib/pkgconfig/
    fi
  done
  export PKG_CONFIG_LIBDIR="${SYSROOT_PREFIX}/usr/lib/pkgconfig:${SYSROOT_PREFIX}/usr/lib32/pkgconfig:${SYSROOT_PREFIX}/usr/share/pkgconfig"
  PKG_MESON_OPTS_TARGET="-Dgtk_doc=false \
                         -Dintrospection=disabled"
}
