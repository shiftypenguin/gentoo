# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )
# this ebuild currently only supports installing ruby bindings for a single ruby version
# so USE_RUBY must contain only a single value (the latest stable) as the ebuild calls
# /usr/bin/${USE_RUBY} directly
USE_RUBY="ruby22"
inherit eutils flag-o-matic multilib python-single-r1 ruby-single toolchain-funcs

DESCRIPTION="Open source multimedia framework for television broadcasting"
HOMEPAGE="https://www.mltframework.org/"
SRC_URI="https://github.com/mltframework/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~x86 ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="compressed-lumas debug ffmpeg fftw frei0r gtk jack kdenlive libav libsamplerate melt opencv opengl
cpu_flags_x86_mmx qt5 rtaudio sdl cpu_flags_x86_sse cpu_flags_x86_sse2 xine xml lua python ruby vdpau"
# java perl php tcl vidstab
IUSE="${IUSE} kernel_linux"

#rtaudio will use OSS on non linux OSes
COMMON_DEPEND="
	ffmpeg? (
		libav? ( media-video/libav:0=[vdpau?] )
		!libav? ( media-video/ffmpeg:0=[vdpau?] )
	)
	xml? ( >=dev-libs/libxml2-2.5 )
	sdl? ( >=media-libs/libsdl-1.2.10[X,opengl,video]
		 >=media-libs/sdl-image-1.2.4 )
	libsamplerate? ( >=media-libs/libsamplerate-0.1.2 )
	jack? ( >=media-sound/jack-audio-connection-kit-0.121.3
		media-libs/ladspa-sdk
		>=dev-libs/libxml2-2.5 )
	fftw? ( sci-libs/fftw:3.0= )
	frei0r? ( media-plugins/frei0r-plugins )
	gtk? ( x11-libs/gtk+:2
		media-libs/libexif
		x11-libs/pango )
	opencv? ( >=media-libs/opencv-3.1.0:= )
	opengl? ( media-video/movit )
	rtaudio? (
		media-libs/rtaudio
		kernel_linux? ( media-libs/alsa-lib )
	)
	xine? ( >=media-libs/xine-lib-1.1.2_pre20060328-r7 )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtsvg:5
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
		media-libs/libexif
		x11-libs/libX11
		opengl? ( dev-qt/qtopengl:5 )
	)
	lua? ( >=dev-lang/lua-5.1.4-r4:= )
	python? ( ${PYTHON_DEPS} )
	ruby? ( ${RUBY_DEPS} )"
#	sox? ( media-sound/sox )
#	java? ( >=virtual/jre-1.5 )
#	perl? ( dev-lang/perl )
#	php? ( dev-lang/php )
#	tcl? ( dev-lang/tcl:0= )
#	vidstab? ( media-libs/libvidstab )
SWIG_DEPEND=">=dev-lang/swig-2.0"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	compressed-lumas? ( virtual/imagemagick-tools[png] )
	lua? ( ${SWIG_DEPEND} virtual/pkgconfig )
	python? ( ${SWIG_DEPEND} )
	ruby? ( ${SWIG_DEPEND} )"
#	java? ( ${SWIG_DEPEND} >=virtual/jdk-1.5 )
#	perl? ( ${SWIG_DEPEND} )
#	php? ( ${SWIG_DEPEND} )
#	tcl? ( ${SWIG_DEPEND} )
RDEPEND="${COMMON_DEPEND}
	!media-libs/mlt++
"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-6.2.0-ruby-link.patch

	# respect CFLAGS LDFLAGS when building shared libraries. Bug #308873
	for x in python lua; do
		sed -i "/mlt.so/s: -lmlt++ :& ${CFLAGS} ${LDFLAGS} :" src/swig/$x/build || die
	done
	sed -i "/^LDFLAGS/s: += :& ${LDFLAGS} :" src/swig/ruby/build || die

	sed -i -e "s/env ruby/${USE_RUBY}/" src/swig/ruby/* || die

	default
}

src_configure() {
	tc-export CC CXX

	# bug 589848
	append-cxxflags -std=c++11

	local myconf="--enable-gpl
		--enable-gpl3
		--enable-motion-est
		--target-arch=$(tc-arch)
		--disable-kde
		--disable-swfdec
		$(use_enable debug)
		$(use compressed-lumas && echo ' --luma-compress')
		$(use_enable cpu_flags_x86_sse sse)
		$(use_enable cpu_flags_x86_sse2 sse2)
		$(use_enable gtk gtk2)
		$(use_enable sdl)
		$(use_enable jack jackrack)
		$(use_enable ffmpeg avformat)
		$(use ffmpeg && echo ' --avformat-swscale')
		$(use_enable fftw plus)
		$(use_enable frei0r)
		$(use_enable melt)
		$(use_enable opencv)
		$(use_enable opengl)
		$(use_enable libsamplerate resample)
		$(use_enable rtaudio)
		$(use vdpau && echo ' --avformat-vdpau')
		$(use_enable xml)
		$(use_enable xine)
		$(use_enable kdenlive)
		--disable-sox"
		#$(use_enable sox) FIXME

	if use qt5 ; then
		myconf+=" --enable-qt
			--qt-includedir=$(pkg-config Qt5Core --variable=includedir)
			--qt-libdir=$(pkg-config Qt5Core --variable=libdir)"
	else
		myconf+=" --disable-qt"
	fi

	if use x86 || use amd64 ; then
		myconf+=" $(use_enable cpu_flags_x86_mmx mmx)"
	else
		myconf+=" --disable-mmx"
	fi

	if ! use melt; then
		sed -i -e "s;src/melt;;" Makefile || die
	fi

	# TODO: add swig language bindings
	# see also https://www.mltframework.org/twiki/bin/view/MLT/ExtremeMakeover

	local swig_lang
	# TODO: java perl php tcl
	for i in lua python ruby ; do
		use $i && swig_lang="${swig_lang} $i"
	done
	[ -z "${swig_lang}" ] && swig_lang="none"

	econf ${myconf} --swig-languages="${swig_lang}"

	sed -i -e s/^OPT/#OPT/ "${S}/config.mak" || die
	if use qt5 ; then
		if ! use opengl ; then
			sed -i -e "/^USE_QT_OPENGL/ s/^/#/" "${S}/src/modules/qt/config.mak" || die
		fi
	fi
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS README docs/*.txt

	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	doins -r demo

	docinto swig

	# Install SWIG bindings
	if use lua; then
		cd "${S}"/src/swig/lua || die
		exeinto $(pkg-config --variable INSTALL_CMOD lua)
		doexe mlt.so
		dodoc play.lua
	fi

	if use python; then
		cd "${S}"/src/swig/python || die
		insinto $(python_get_sitedir)
		doins mlt.py
		exeinto $(python_get_sitedir)
		doexe _mlt.so
		dodoc play.py
		python_optimize
	fi

	if use ruby; then
		cd "${S}"/src/swig/ruby || die
		exeinto $("${EPREFIX}"/usr/bin/${USE_RUBY} -r rbconfig -e 'print RbConfig::CONFIG["sitearchdir"]')
		doexe mlt.so
		dodoc play.rb thumbs.rb
	fi
	# TODO: java perl php tcl
}
