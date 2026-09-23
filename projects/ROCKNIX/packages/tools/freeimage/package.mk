# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="freeimage"
PKG_VERSION="3180"
PKG_LICENSE="GPLv3"
PKG_SITE="http://freeimage.sourceforge.net/"
PKG_URL="https://github.com/1273294133/distribution_rocknix_aurknix/releases/download/sources-mirror/danoli3-fixed.zip"
PKG_SHA256="b491c0e16a6449b8a42e89fceca5866a61d944a2a2e8b3c7869e49c4220b1538"
PKG_DEPENDS_TARGET="toolchain"
PKG_SOURCE_DIR="FreeImage-master"
PKG_LONGDESC="FreeImage library"
PKG_STAMP="danoli3-fixed-20260924"

pre_make_target() {
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++11 -fPIC -Wno-implicit-function-declaration"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0 -fPIC -Wno-implicit-function-declaration"
}

post_makeinstall_target() {
  # danoli3 fork Makefile installs no pkg-config file; its install target used
  # `install -o root -g root` which fails chown on non-root GitHub runners, so
  # the lib/header lines never ran and only the .pc mattered - but the .so was
  # missing from sysroot. Fixed zip (danoli3-fixed.zip) drops the -o/-g; we also
  # copy lib+header directly from the build dir as a deterministic fallback.
  if ! ls "${PKG_BUILD}"/libfreeimage-*.so* >/dev/null 2>&1; then
    echo "ERROR: freeimage shared library not produced by make"
    die "freeimage build did not create libfreeimage.so (check make output in thread log)"
  fi
  mkdir -p "${SYSROOT_PREFIX}/usr/include" "${SYSROOT_PREFIX}/usr/lib" "${SYSROOT_PREFIX}/usr/lib/pkgconfig"
  cp -f "${PKG_BUILD}/Source/FreeImage.h" "${SYSROOT_PREFIX}/usr/include/"
  cp -f "${PKG_BUILD}"/libfreeimage-*.so* "${SYSROOT_PREFIX}/usr/lib/" 2>/dev/null || true
  cp -f "${PKG_BUILD}/libfreeimage.a" "${SYSROOT_PREFIX}/usr/lib/" 2>/dev/null || true
  ln -sfn "lib$(ls "${PKG_BUILD}" | grep -o 'libfreeimage-[0-9.]*\.so' | head -1)" \
    "${SYSROOT_PREFIX}/usr/lib/libfreeimage.so" 2>/dev/null || true
  cat > "${SYSROOT_PREFIX}/usr/lib/pkgconfig/freeimage.pc" <<'FIEOF'
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: FreeImage
Description: FreeImage - multi-format image loading library
Version: 3.18.0
Libs: -L${libdir} -lfreeimage
Cflags: -I${includedir}
FIEOF
}
