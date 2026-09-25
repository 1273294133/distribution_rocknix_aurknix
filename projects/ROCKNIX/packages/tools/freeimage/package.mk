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
PKG_STAMP="danoli3-fixed-make-20260926-srcs17"

# danoli3 fork ships BOTH CMakeLists.txt and Makefile.gnu; ROCKNIX auto-detect
# picks cmake, whose FREEIMAGE_STATIC default=ON builds a static libFreeImage.a
# (capital I) - but emulationstation FindFreeImage does find_library(NAMES
# freeimage freeimageLib) i.e. libfreeimage.so (lowercase), so the shared lib
# never exists -> "Required library FreeImage not found" despite pc+headers.
# Force the GNU make build (Makefile -> Makefile.gnu -> libfreeimage-3.19.so
# + libfreeimage.so symlink), matching what emulationstation expects.
PKG_TOOLCHAIN="make"

pre_make_target() {
  # ROCKNIX runs make inside PKG_REAL_BUILD (./.aarch64-rocknix-linux-gnu) which
  # has no Makefile; Makefile.gnu also uses relative paths (Source/, Wrapper/)
  # so it must run from the source root. PKG_BUILD is only defined at run time
  # (empty at package.mk parse time), so set PKG_MAKE_OPTS_TARGET here.
  PKG_MAKE_OPTS_TARGET="-C ${PKG_BUILD} -f Makefile.gnu"
  # make install also runs in PKG_REAL_BUILD (no Makefile) -> No rule to make
  # target 'install'; point it at the source root too. Makefile.gnu install
  # supports DESTDIR (DESTDIR ?= /, INCDIR=$(DESTDIR)/usr/include, no -o root)
  # and creates the libfreeimage.so -> .so.3 -> 3.19.so symlink chain.
  PKG_MAKEINSTALL_OPTS_TARGET="-C ${PKG_BUILD} -f Makefile.gnu"
  # danoli3 fork bundles OpenEXR 3.x which needs C++14+ (std::enable_if_t);
  # -std=c++11 breaks it. Must set std explicitly: Makefile.gnu uses
  # 'CXXFLAGS ?= ...' so a pre-set env CXXFLAGS would skip the -std default.
  export CXXFLAGS="${CXXFLAGS} -Wno-narrowing -std=c++17 -fPIC -Wno-implicit-function-declaration"
  export CFLAGS="${CFLAGS} -DPNG_ARM_NEON_OPT=0 -fPIC -Wno-implicit-function-declaration"
  # danoli3 fork's Makefile.srcs SRCS list omits bundled sources that the
  # linked consumers need (emulationstation links with -Wl,--no-undefined):
  # LibWebP palette + sharpyuv (WebPGetColorPalette/SharpYuv*) and LibRawLite
  # decoders/write (olympus_load_raw/sony_ycbcr_load_raw/panasonicC8_load_raw,
  # losslessjpeg, libraw_c_api, apply_profile, tiff_writer). Without them
  # libfreeimage.so itself carries undefined symbols -> link error. The *_ph.cpp
  # stubs (write_ph/postprocessing_ph/preprocessing_ph) are deliberately NOT
  # added: they duplicate symbols already present (file_write.cpp,
  # postprocessing_utils.cpp, raw2image.cpp etc) - verified locally as
  # 'multiple definition'. LibRawLite defines NO_LCMS internally (defines.h)
  # so apply_profile.cpp compiles its no-op path without lcms2.h.
  sed -i 's|^SRCS = .*|& ./Source/LibWebP/src/utils/palette.c ./Source/LibWebP/src/dsp/lossless_avx2.c ./Source/LibWebP/src/dsp/lossless_enc_avx2.c ./Source/LibWebP/sharpyuv/sharpyuv.c ./Source/LibWebP/sharpyuv/sharpyuv_cpu.c ./Source/LibWebP/sharpyuv/sharpyuv_csp.c ./Source/LibWebP/sharpyuv/sharpyuv_dsp.c ./Source/LibWebP/sharpyuv/sharpyuv_gamma.c ./Source/LibWebP/sharpyuv/sharpyuv_neon.c ./Source/LibWebP/sharpyuv/sharpyuv_sse2.c ./Source/LibRawLite/src/decoders/olympus14.cpp ./Source/LibRawLite/src/decoders/pana8.cpp ./Source/LibRawLite/src/decoders/sonycc.cpp ./Source/LibRawLite/src/decompressors/losslessjpeg.cpp ./Source/LibRawLite/src/libraw_c_api.cpp ./Source/LibRawLite/src/write/apply_profile.cpp ./Source/LibRawLite/src/write/tiff_writer.cpp|' "${PKG_BUILD}/Makefile.srcs"
}

post_makeinstall_target() {
  # Makefile.gnu install (danoli3-fixed.zip drops -o root chown) produces
  # libfreeimage-3.19.so + symlinks in the pkg sysroot; copy lib+header as a
  # deterministic fallback and die if the shared lib is missing.
  if ! ls "${PKG_BUILD}"/libfreeimage-*.so* >/dev/null 2>&1; then
    echo "ERROR: freeimage shared library not produced by make"
    die "freeimage build did not create libfreeimage.so (check make output in thread log)"
  fi
  mkdir -p "${SYSROOT_PREFIX}/usr/include" "${SYSROOT_PREFIX}/usr/lib" "${SYSROOT_PREFIX}/usr/lib/pkgconfig"
  cp -f "${PKG_BUILD}/Source/FreeImage.h" "${SYSROOT_PREFIX}/usr/include/"
  cp -f "${PKG_BUILD}"/libfreeimage-*.so* "${SYSROOT_PREFIX}/usr/lib/" 2>/dev/null || true
  cp -f "${PKG_BUILD}/libfreeimage.a" "${SYSROOT_PREFIX}/usr/lib/" 2>/dev/null || true
  # NOTE: grep -o already yields "libfreeimage-3.19.so"; the previous
  # "lib$(...)" prefix produced a broken "liblibfreeimage-3.19.so" symlink,
  # so ld could not resolve -lfreeimage to the .so and fell back to the
  # static .a (C++ runtime symbols missing) -> SDL2/drastic_adv link failure.
  ln -sfn "$(ls "${PKG_BUILD}" | grep -o 'libfreeimage-[0-9.]*\.so' | head -1)" \
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
