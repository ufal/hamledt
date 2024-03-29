LANGCODE=cs
TREEBANK=cs-fictree
UDCODE=cs_fictree
UDNAME=Czech-FicTree
HARMONIZE=HarmonizeFicTree
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

# The first version we got from ÚTKL was in their vertical format and we converted it to CoNLL-X like this:
# The .vert format used in ÚTKL is like CoNLL but it has only 6 columns: ID FORM LEMMA TAG HEAD DEPREL.
# Convert it to CoNLL-X so that we can use the standard Treex reader.
# perl -CDS -pe 's/^([0-9]+?)\t(.*?)\t(.*?)\t(.*?)\t([0-9]+?)\t(.*?)$$/$$1\t$$2\t$$3\t$$4\t$$4\t_\t$$5\t$$6\t_\t_/'
# It is no longer needed because the second version we got is already converted to CoNLL-X.
source:
	./catsource.sh

# We do not use the conll_to_treex goal from common.mak because we want the sentence ids to contain original file names.
treex:
	$(TREEX) $(IMPORTX) from=$(IN)/train.conll sid_within_feat=1 $(POST_IMPORTX_BLOCKS) $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORTX) from=$(IN)/dev.conll   sid_within_feat=1 $(POST_IMPORTX_BLOCKS) $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORTX) from=$(IN)/test.conll  sid_within_feat=1 $(POST_IMPORTX_BLOCKS) $(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced export

# We need our own export because we need specific post-processing.
UDAPISCEN=ud.cs.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train started | tee -a time.log
	cat $(CONLLUDIR)/train/*.conllu | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/*.conllu | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/*.conllu | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu
