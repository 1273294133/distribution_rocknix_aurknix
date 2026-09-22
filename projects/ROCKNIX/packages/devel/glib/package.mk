# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/devel/glib/package.mk

# Force rebuild: stamp hashing must pick up the pc tool variable fix in the
# global package.mk (8a59d87). Bump this value to force glib rebuild.
PKG_STAMP="20260923-genmarshal-fix-v2"

PKG_MESON_OPTS_HOST="-Ddefault_library=shared \
                     -Dinstalled_tests=false \
                     -Dlibmount=disabled \
                     -Dintrospection=disabled \
                     -Dtests=false"

# ROCKNIX stamp bump: glib 2.85+ pc tool variables (glib_genmarshal/glib_mkenums) rewritten to toolchain in post_makeinstall_target (8a59d87). Changing this line changes the package stamp so glib is rebuilt.
