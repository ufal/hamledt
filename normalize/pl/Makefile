LANGCODE=pl
TREEBANK=pl
UDCODE=pl
UDNAME=Polish
include ../common.mak
SRCDIR=/a/LRC_TMP/hamledt/data_translations/not_yet_hamledt_treebanks/pl
TOOLS=/home/zeman/tools

POST_IMPORTX_BLOCKS = W2W::EstimateNoSpaceAfter
POST_UD_BLOCKS=HamleDT::PL::SplitFusedWords

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	$(TOOLS)/split_conll.pl < $(SRCDIR)/skladnica-zaleznosciowa-0.5.conll -head 6100 $(IN)/train.conll $(IN)/devtest.conll
	$(TOOLS)/split_conll.pl < $(IN)/devtest.conll -head 1027 $(IN)/dev.conll $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
