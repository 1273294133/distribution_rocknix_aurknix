#!/bin/bash
# AURKNIX: gtk3 meson cross-configure fails with
#   ERROR: Dependency 'gio-2.0' tool variable 'glib_compile_resources' contains
#   erroneous value: '/usr/bin/glib-compile-resources'
# when the gio-2.0.pc that meson resolves (e.g. a copy shipped inside
# install_pkg/pango-*/usr/lib/pkgconfig) carries host /usr/bin tool paths that
# do not exist on the build host. Earlier versions resolved the .pc via
# `pkg-config --variable=pcfiledir`, but on runners that also have a system
# glib-dev install that resolves to /usr/lib/.../pkgconfig, where sed -i fails
# with permission denied and the real (PKG_CONFIG_PATH) copy is never touched.
# Instead, rewrite EVERY gio-2.0.pc / glib-2.0.pc on PKG_CONFIG_PATH (plus the
# resolved pcfiledir if it is one of those dirs) in place.
set -u

TOOLCHAIN="${1:-${TOOLCHAIN:-}}"
[ -n "${TOOLCHAIN}" ] || exit 0

rewritten=0
# dirs = PKG_CONFIG_PATH entries + resolved pcfiledir (deduped)
dirs=""
for d in ${PKG_CONFIG_PATH//:/ }; do
  [ -n "${d}" ] || continue
  case ":${dirs}:" in *":${d}:"*) ;; *) dirs="${dirs}:${d}" ;; esac
done
pcfiledir="$(pkg-config --variable=pcfiledir gio-2.0 2>/dev/null || true)"
if [ -n "${pcfiledir}" ]; then
  case ":${dirs}:" in *":${pcfiledir}:"*) ;; *) dirs="${dirs}:${pcfiledir}" ;; esac
fi

for d in ${dirs//:/ }; do
  [ -d "${d}" ] || continue
  for pc in "${d}/gio-2.0.pc" "${d}/glib-2.0.pc"; do
    [ -f "${pc}" ] || continue
    if grep -Eq '/usr/bin/glib-compile-resources|\$\{bindir\}/glib-compile-resources|bindir=/usr/bin|/usr/bin/glib-genmarshal|/usr/bin/glib-mkenums' "${pc}"; then
      sed -e 's#/usr/bin/glib-compile-resources#'"${TOOLCHAIN}"'/bin/glib-compile-resources#g' \
          -e "s#\\\${bindir}/glib-compile-resources#${TOOLCHAIN}/bin/glib-compile-resources#g" \
          -e "s#\\\${bindir}/glib-genmarshal#${TOOLCHAIN}/bin/glib-genmarshal#g" \
          -e "s#\\\${bindir}/glib-mkenums#${TOOLCHAIN}/bin/glib-mkenums#g" \
          -e 's#bindir=/usr/bin#bindir='"${TOOLCHAIN}"'/bin#g' \
          -e 's#/usr/bin/glib-genmarshal#'"${TOOLCHAIN}"'/bin/glib-genmarshal#g' \
          -e 's#/usr/bin/glib-mkenums#'"${TOOLCHAIN}"'/bin/glib-mkenums#g' -i "${pc}" 2>/dev/null || continue
      rewritten=$((rewritten+1))
    fi
  done
done

# Leave a trace in the thread log so CI diagnosis is possible.
echo "fix-gio-pc.sh: rewritten ${rewritten} .pc file(s) (TOOLCHAIN=${TOOLCHAIN})" >&2
exit 0
