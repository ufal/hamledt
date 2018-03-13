LANGCODE=sk
TREEBANK=sk-a1
UDCODE=sk_a1
UDNAME=Slovak-A1
include ../common.mak

SOURCEDIR=/net/data/treebanks/sk/stb-merged
# Currently we select only a subset of the available documents.
source:
	cp $(SOURCEDIR)/*/*.treex.gz $(IN)

treex:
	$(QTREEX) \
		Read::Treex from='!$(IN)/*.treex.gz' \
		A2A::CopyAtree source_selector='annotator1' \
		Write::Treex path=$(DIR0)/test/ compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
