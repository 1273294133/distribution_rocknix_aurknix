#!/bin/bash
# AURKNIX: gtk3 meson cross-configure fails with
#   ERROR: Dependency 'gio-2.0' tool variable 'glib_compile_resources' contains
#   erroneous value: '/usr/bin/glib-compile-resources'
# when the gio-2.0.pc that pkg-config resolves (e.g. a copy inside
# install_pkg/pango-*/usr/lib/pkgconfig) carries host /usr/bin tool paths that
# do not exist on the build host. Rewrite the resolved .pc in place so the tool
# variables point at the toolchain binaries.
set -u

TOOLCHAIN="${1:-${TOOLCHAIN:-}}"
[ -n "${TOOLCHAIN}" ] || exit 0

pcfiledir="$(pkg-config --variable=pcfiledir gio-2.0 2>/dev/null)"
if [ -z "${pcfiledir}" ] || [ ! -f "${pcfiledir}/gio-2.0.pc" ]; then
  # Fallback: locate the first gio-2.0.pc on PKG_CONFIG_PATH.
  pcfiledir=""
  for d in ${PKG_CONFIG_PATH//:/ }; do
    [ -f "${d}/gio-2.0.pc" ] && { pcfiledir="${d}"; break; }
  done
fi
[ -n "${pcfiledir}" ] || exit 0
pcfile="${pcfiledir}/gio-2.0.pc"
[ -f "${pcfile}" ] || exit 0

if grep -Eq '/usr/bin/glib-compile-resources|\$\{bindir\}/glib-compile-resources|bindir=/usr/bin' "${pcfile}"; then
  sed -e 's#/usr/bin/glib-compile-resources#'"${TOOLCHAIN}"'/bin/glib-compile-resources#g' \
      -e "s#\\\${bindir}/glib-compile-resources#${TOOLCHAIN}/bin/glib-compile-resources#g" \
      -e 's#bindir=/usr/bin#bindir='"${TOOLCHAIN}"'/bin#g' -i "${pcfile}"
  glibpc="$(dirname "${pcfile}")/glib-2.0.pc"
  if [ -f "${glibpc}" ] && grep -Eq '/usr/bin/glib-genmarshal|/usr/bin/glib-mkenums|bindir=/usr/bin' "${glibpc}"; then
    sed -e 's#/usr/bin/glib-genmarshal#'"${TOOLCHAIN}"'/bin/glib-genmarshal#g' \
        -e 's#/usr/bin/glib-mkenums#'"${TOOLCHAIN}"'/bin/glib-mkenums#g' \
        -e 's#bindir=/usr/bin#bindir='"${TOOLCHAIN}"'/bin#g' -i "${glibpc}"
  fi
fi
exit 0
