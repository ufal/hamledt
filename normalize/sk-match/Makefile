LANGCODE=sk
TREEBANK=sk-match
UDCODE=sk_snk
UDNAME=Slovak-SNK
POST_UD_BLOCKS=HamleDT::SK::SplitFusedWords HamleDT::SK::FixUD
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/treebanks/sk/stb-match.conll | /home/zeman/tools/split_conll.pl -phead 80 $(IN)/train.conll $(IN)/dt.conll
	cat $(IN)/dt.conll | /home/zeman/tools/split_conll.pl -phead 50 $(IN)/dev.conll $(IN)/test.conll

treex:
	$(TREEX) $(IMPORTX) is_member_within_afun=1 is_parenthesis_root_within_afun=1 from=$(IN)/train.conll sid_within_feat=1 Filter::RemoveEmptySentences W2W::EstimateNoSpaceAfter $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORTX) is_member_within_afun=1 is_parenthesis_root_within_afun=1 from=$(IN)/dev.conll   sid_within_feat=1 Filter::RemoveEmptySentences W2W::EstimateNoSpaceAfter $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORTX) is_member_within_afun=1 is_parenthesis_root_within_afun=1 from=$(IN)/test.conll  sid_within_feat=1 Filter::RemoveEmptySentences W2W::EstimateNoSpaceAfter $(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced export

# We need our own export because we need specific post-processing.
UDAPISCEN=ud.sk.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train started | tee -a time.log
	cat $(CONLLUDIR)/train/*.conllu > $(UDCODE)-ud-train.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/*.conllu >  $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/*.conllu > $(UDCODE)-ud-test.conllu
