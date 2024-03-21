# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit gnome.org gnome2-utils meson readme.gentoo-r1 xdg

DESCRIPTION="Archive manager for GNOME"
HOMEPAGE="https://wiki.gnome.org/Apps/FileRoller"
COMMIT="ebe46a98283d26e3ae1b1cf973e151a50d440564"
SRC_URI="https://gitlab.gnome.org/GNOME/file-roller/-/archive/${COMMIT}/file-roller-${COMMIT}.tar.bz2"

LICENSE="GPL-2+ CC-BY-SA-3.0"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~loong ~ppc ~ppc64 ~riscv x86 ~amd64-linux ~x86-linux"
IUSE="gtk-doc +introspection nautilus"
REQUIRED_USE="gtk-doc? ( introspection )"

# gdk-pixbuf used extensively in the source
# cairo used in eggtreemultidnd.c
# pango used in fr-window
RDEPEND="
	>=dev-libs/glib-2.38:2
	>=gui-libs/gtk-4.8.1:4
	>=gui-libs/libadwaita-1.2
	nautilus? ( >=gnome-base/nautilus-43.0 )
	>=dev-libs/json-glib-0.14
	>=app-arch/libarchive-3.2:=
	introspection? ( dev-libs/gobject-introspection )
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/pango
	dev-libs/libportal[gtk]
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/glib-utils
	dev-util/itstool
	>=sys-devel/gettext-0.19.8
	virtual/pkgconfig
	gtk-doc? ( dev-util/gi-docgen )
"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
${PN} is a frontend for several archiving utilities. If you want a
particular archive format support, see ${HOMEPAGE}
and install the relevant package. For example:
7-zip   - app-arch/p7zip
ace     - app-arch/unace
arj     - app-arch/arj
brotli  - app-arch/brotli
cpio    - app-arch/cpio
deb     - app-arch/dpkg
iso     - app-cdr/cdrtools
jar,zip - app-arch/zip and app-arch/unzip
lha     - app-arch/lha
lzop    - app-arch/lzop
lz4     - app-arch/lz4
rar     - app-arch/unrar or app-arch/unar
rpm     - app-arch/rpm
unstuff - app-arch/stuffit
zstd    - app-arch/zstd
zoo     - app-arch/zoo"

# Add a FUSE based virtual FS for drag-to-extract
PATCHES="${FILESDIR}/112.patch"

S="${WORKDIR}/${PN}-${COMMIT}"

src_prepare() {
	# File providing Gentoo package names for various archivers
	cp -v "${FILESDIR}"/3.36-packages.match data/packages.match || die

	default
	xdg_environment_reset
}

src_configure() {
	local emesonargs=(
		-Drun-in-place=false
		$(meson_feature nautilus nautilus-actions)
		-Dnotification=enabled
		-Duse_native_appchooser=true
		-Dpackagekit=false
		-Dlibarchive=enabled
		$(meson_feature introspection)
		$(meson_feature gtk-doc api_docs)
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	if use gtk-doc; then
		mkdir -p "${ED}"/usr/share/gtk-doc/ || die
		mv "${ED}"/usr/share/doc/file-roller "${ED}"/usr/share/gtk-doc/file-roller || die
	fi
	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_pkg_postinst
	gnome2_schemas_update
	readme.gentoo_print_elog
}

pkg_postrm() {
	xdg_pkg_postrm
	gnome2_schemas_update
}
