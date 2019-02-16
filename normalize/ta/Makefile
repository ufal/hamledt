LANGCODE=ta
TREEBANK=ta
UDCODE=ta_ttb
UDNAME=Tamil-TTB
include ../common.mak
TOOLS=/net/work/people/zeman/parsing/tools
SOURCEDIR=/net/work/people/zeman/tamiltb/data

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ln -s $(SOURCEDIR)/train.conll $(IN)/train.conll
	ln -s $(SOURCEDIR)/dev.conll $(IN)/dev.conll
	ln -s $(SOURCEDIR)/test.conll $(IN)/test.conll

# The import of Tamil data to Treex differs from other languages in that we
# also transliterate the cased Latin back to the Tamil script in UTF-8, and
# the word forms are furthermore romanized using the scientific scheme and the
# result is stored in the translit attribute.
# Otherwise we could just write "treex: conll_to_treex" here.
TRANSLIT=W2W::TA::Transliteration use_enc_map=latin_2_utf8 mark_latin=0 W2W::Translit W2W::EstimateNoSpaceAfter
DETOKDIR=$(HAMLEDT)/normalize/ta/detokenized
treex:
	$(TREEX) $(IMPORTX) from=$(IN)/train.conll sid_prefix=train- $(TRANSLIT) HamleDT::TA::ReadDetokenizedSentences from=$(DETOKDIR)/train.ta $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORTX) from=$(IN)/dev.conll   sid_prefix=dev-   $(TRANSLIT) HamleDT::TA::ReadDetokenizedSentences from=$(DETOKDIR)/dev.ta   $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORTX) from=$(IN)/test.conll  sid_prefix=test-  $(TRANSLIT) HamleDT::TA::ReadDetokenizedSentences from=$(DETOKDIR)/test.ta  $(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
