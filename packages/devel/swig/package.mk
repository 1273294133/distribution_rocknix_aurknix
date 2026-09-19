# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="swig"
PKG_VERSION="4.3.1"
PKG_SHA256="c6091ef5f2e397945a66899bf6859845f35ef603340e79c086d7f2ecf348678c"
PKG_LICENSE="GPL"
PKG_SITE="http://www.swig.org"
PKG_URL="https://github.com/swig/swig/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="ccache:host"
PKG_LONGDESC="SWIG is a software development tool that connects programs written in C and C++ with a variety of high-level programming languages."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_HOST="--program-suffix=4.0 \
                         --with-boost=no \
                         --without-pcre \
                         --without-x \
                         --without-tcl \
                         --without-python \
                         --without-python3 \
                         --without-perl5 \
                         --without-octave \
                         --without-java \
                         --without-gcj \
                         --without-android \
                         --without-guile \
                         --without-mzscheme \
                         --without-ruby \
                         --without-php \
                         --without-ocaml \
                         --without-pike \
                         --without-chicken \
                         --without-csharp \
                         --without-lua \
                         --without-allegrocl \
                         --without-clisp \
                         --without-r \
                         --without-go \
                         --without-d"

post_makeinstall_host() {
  ln -sf swig4.0 ${TOOLCHAIN}/bin/swig
}
