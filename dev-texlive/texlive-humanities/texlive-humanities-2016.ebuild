# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

TEXLIVE_MODULE_CONTENTS="adtrees bibleref bibleref-lds bibleref-mouth bibleref-parse covington diadia dramatist dvgloss ecltree edfnotes ednotes eledform eledmac expex gb4e gmverse jura juraabbrev juramisc jurarsp ledmac leipzig lexikon lexref ling-macros linguex liturg metrix parallel parrun phonrule plari play poemscol poetrytex qobitree qtree reledmac rrgtrees rtklage screenplay screenplay-pkg sides stage textglos thalie tree-dvips verse xyling collection-humanities
"
TEXLIVE_MODULE_DOC_CONTENTS="adtrees.doc bibleref.doc bibleref-lds.doc bibleref-mouth.doc bibleref-parse.doc covington.doc diadia.doc dramatist.doc dvgloss.doc ecltree.doc edfnotes.doc ednotes.doc eledform.doc eledmac.doc expex.doc gb4e.doc gmverse.doc jura.doc juraabbrev.doc juramisc.doc jurarsp.doc ledmac.doc leipzig.doc lexikon.doc lexref.doc ling-macros.doc linguex.doc liturg.doc metrix.doc parallel.doc parrun.doc phonrule.doc plari.doc play.doc poemscol.doc poetrytex.doc qobitree.doc qtree.doc reledmac.doc rrgtrees.doc rtklage.doc screenplay.doc screenplay-pkg.doc sides.doc stage.doc textglos.doc thalie.doc tree-dvips.doc verse.doc xyling.doc "
TEXLIVE_MODULE_SRC_CONTENTS="bibleref.source bibleref-lds.source bibleref-mouth.source dramatist.source dvgloss.source edfnotes.source eledform.source eledmac.source jura.source juraabbrev.source jurarsp.source ledmac.source leipzig.source liturg.source metrix.source parallel.source parrun.source plari.source play.source poemscol.source poetrytex.source reledmac.source rrgtrees.source screenplay.source textglos.source thalie.source verse.source "
inherit  texlive-module
DESCRIPTION="TeXLive Humanities packages"

LICENSE=" GPL-1 GPL-2 LPPL-1.2 LPPL-1.3 "
SLOT="0"
KEYWORDS="alpha amd64 arm ~hppa ia64 ~mips ~ppc ~ppc64 ~s390 ~sh x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2016
!dev-tex/lineno
"
RDEPEND="${DEPEND} "
TEXLIVE_MODULE_BINSCRIPTS="texmf-dist/scripts/diadia/diadia.lua"
