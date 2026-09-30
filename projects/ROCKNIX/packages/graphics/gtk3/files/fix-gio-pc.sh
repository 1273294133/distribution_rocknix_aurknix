#!/bin/bash
# AURKNIX: gtk3 meson cross-configure fails with
#   ERROR: Dependency 'glib-2.0' tool variable 'glib_mkenums' contains
#   erroneous value: '/usr/bin/glib-mkenums'
# when the gio-2.0.pc / glib-2.0.pc that meson resolves carries host
# /usr/bin tool paths. Earlier versions guarded the sed with a grep that
# missed `${bindir}/glib-genmarshal` and `${bindir}/glib-mkenums` (the
# toolchain-shipped 2.90.0 .pc references tools via ${bindir}), yielding
# "rewritten 0" while meson still read /usr/bin paths. Now rewrite
# unconditionally: expand every ${bindir} reference, rewrite absolute
# /usr/bin/glib-* tool paths and the bindir= definition line, in every
# gio-2.0.pc / glib-2.0.pc found on PKG_CONFIG_PATH, PKG_CONFIG_LIBDIR and
# both resolved pcfiledirs. sed failures are surfaced instead of swallowed.
set -u

TOOLCHAIN="${1:-${TOOLCHAIN:-}}"
[ -n "${TOOLCHAIN}" ] || exit 0

rewritten=0
errf="${TMPDIR:-/tmp}/fix-gio-pc.err.$$"
# dirs = PKG_CONFIG_PATH entries + PKG_CONFIG_LIBDIR (toolchain sysroot) +
# resolved pcfiledirs (deduped). meson resolves gio-2.0 with an empty
# PKG_CONFIG_PATH and only PKG_CONFIG_LIBDIR pointing at the shared sysroot,
# where a toolchain-shipped 2.90.0 gio-2.0.pc may keep /usr/bin tool paths.
dirs=""
PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
PKG_CONFIG_LIBDIR="${PKG_CONFIG_LIBDIR:-}"
for d in ${PKG_CONFIG_PATH//:/ } ${PKG_CONFIG_LIBDIR//:/ }; do
  [ -n "${d}" ] || continue
  case ":${dirs}:" in *":${d}:"*) ;; *) dirs="${dirs}:${d}" ;; esac
done
for mod in gio-2.0 glib-2.0; do
  pcfiledir="$(pkg-config --variable=pcfiledir "${mod}" 2>/dev/null || true)"
  if [ -n "${pcfiledir}" ]; then
    case ":${dirs}:" in *":${pcfiledir}:"*) ;; *) dirs="${dirs}:${pcfiledir}" ;; esac
  fi
done

for d in ${dirs//:/ }; do
  [ -d "${d}" ] || continue
  for pc in "${d}/gio-2.0.pc" "${d}/glib-2.0.pc"; do
    [ -f "${pc}" ] || continue
    if ! sed -e "s#\\\${bindir}#${TOOLCHAIN}/bin#g" \
             -e 's#/usr/bin/glib-#'"${TOOLCHAIN}"'/bin/glib-#g' \
             -e "s#bindir=/usr/bin#bindir=${TOOLCHAIN}/bin#g" \
             -i "${pc}" 2>"${errf}"; then
      echo "fix-gio-pc.sh: WARN sed failed on ${pc}: $(cat "${errf}")" >&2
      rm -f "${errf}"
      continue
    fi
    rm -f "${errf}"
    rewritten=$((rewritten+1))
  done
done

# Leave a trace in the thread log so CI diagnosis is possible.
echo "fix-gio-pc.sh: rewritten ${rewritten} .pc file(s) (TOOLCHAIN=${TOOLCHAIN})" >&2
exit 0
