LANGCODE=mt
TREEBANK=mt
include ../common.mak
SRCDIR=/net/work/people/zeman/malti/mlrs.v2

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	zcat $(SRCDIR)/press-001-020/malti02.press{001,002,003,004,005,006,007,008,009,010}.conll.gz > $(IN)/train.conll
	zcat $(SRCDIR)/press-001-020/malti02.press{011,012,013,014,015}.conll.gz > $(IN)/dev.conll
	zcat $(SRCDIR)/press-001-020/malti02.press{016,017,018,019,020}.conll.gz > $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
