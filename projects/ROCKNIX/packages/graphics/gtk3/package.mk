# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/addons/addon-depends/chrome-depends/gtk3/package.mk

PKG_DEPENDS_TARGET="toolchain at-spi2-atk atk cairo gdk-pixbuf glib libX11 libXi libXrandr libepoxy pango libxkbcommon wayland wayland-protocols libepoxy libpng tiff libjpeg-turbo libffi glew"

unset PKG_BUILD_FLAGS

PKG_MESON_OPTS_TARGET="${PKG_MESON_OPTS_TARGET/-Dwayland_backend=false/-Dwayland_backend=true}"

# AURKNIX: the gio-2.0.pc that pkg-config resolves (usually a copy shipped inside
# install_pkg/pango-*/usr/lib/pkgconfig) may keep glib_compile_resources pointing
# at host /usr/bin/glib-compile-resources which does not exist on the build host,
# making meson cross-configure fail with 'tool variable contains erroneous value'.
# Rewrite the resolved .pc to toolchain paths. Keep the base package env setup too.
pre_configure_target() {
  # ${TOOLCHAIN}/bin/glib-compile-resources requires ${TOOLCHAIN}/lib/libffi.so.6
  export LD_LIBRARY_PATH="${TOOLCHAIN}/lib:${LD_LIBRARY_PATH}"
  export GLIB_COMPILE_RESOURCES=glib-compile-resources GLIB_MKENUMS=glib-mkenums GLIB_GENMARSHAL=glib-genmarshal
  bash ${ROOT}/projects/ROCKNIX/packages/graphics/gtk3/files/fix-gio-pc.sh "${TOOLCHAIN}"
}

post_makeinstall_target() {
  ${TOOLCHAIN}/bin/glib-compile-schemas ${INSTALL}/usr/share/glib-2.0/schemas
}
