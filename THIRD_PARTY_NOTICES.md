# Third-Party Software Notice

Board Browser Kit is an independent installation and compatibility tool. It is
not published, sponsored, or endorsed by Mozilla, Debian, Google, or GNOME.

The public Board Browser Kit release contains the installer, configuration,
documentation, and the Board Browser Kit Wayland compatibility source/binary.
It does not contain Firefox, Debian packages, Noto fonts, or GNOME icon themes.
Those components are downloaded from their upstream servers during
installation.

## Mozilla Firefox

- Product: Mozilla Firefox ESR for Linux aarch64
- Download source: `https://archive.mozilla.org/pub/firefox/releases/`
- Source code: `https://archive.mozilla.org/pub/firefox/releases/`
- Main code license: Mozilla Public License 2.0
- License: `https://www.mozilla.org/MPL/2.0/`
- Distribution policy:
  `https://www.mozilla.org/foundation/trademarks/distribution-policy/`

Firefox and the Firefox logo are trademarks of the Mozilla Foundation in the
United States and other countries. Board Browser Kit downloads an official
Mozilla archive and configures it locally for the target board. Organizations
that ship a configured browser to customers must separately review Mozilla's
current trademark and distribution requirements.

## Debian Runtime Packages

- Distribution: Debian GNU/Linux Buster archive
- Package index:
  `https://archive.debian.org/debian/dists/buster/main/binary-arm64/Packages.xz`
- Package mirror: `https://archive.debian.org/debian/`

Each downloaded Debian package keeps its package-specific copyright and
license file under:

```text
debian-runtime/usr/share/doc/<package>/copyright
```

The package payloads have different free-software licenses. Check those files
before redistributing an offline runtime bundle.

## Noto CJK Fonts

The installer obtains Noto CJK through Debian's `fonts-noto-cjk` package. Noto
CJK is distributed under the SIL Open Font License 1.1. The installed package
copyright file is retained under `debian-runtime/usr/share/doc/`.

## GNOME Icon Themes

The installer obtains Adwaita and hicolor icon themes from Debian. Their
package copyright and license files are retained under
`debian-runtime/usr/share/doc/`.

## Offline Bundles

An offline package that embeds Firefox, Debian libraries, fonts, or icon
themes is a redistribution of those third-party components. Do not publish or
deliver such a package until the responsible organization has assembled the
applicable licenses, source-code notices, and trademark review.
