# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="espeak"
PKG_VERSION="1.48.15+dfsg"
PKG_SHA256="27b2b012b955e9fcb3edd3b3127ec0f0564a0a62cff64446a52d2c572c59be67"
PKG_LICENSE="GPL"
PKG_SITE="http://espeak.sourceforge.net/"
PKG_URL="https://deb.debian.org/debian/pool/main/e/espeak/espeak_1.48.15+dfsg.orig.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Text to Speech engine for English, with support for other languages"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  cp src/portaudio19.h src/portaudio.h
}

make_target() {
  make -C src \
       CXXFLAGS="${CXXFLAGS}" \
       LDFLAGS="${LDFLAGS}" \
       AUDIO=""
}

makeinstall_target() {
  make -C src \
       CXXFLAGS="${CXXFLAGS}" \
       LDFLAGS="${LDFLAGS}" \
       AUDIO="" \
       DESTDIR=${INSTALL} install
}
