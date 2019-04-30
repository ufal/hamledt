LANGCODE=sk
TREEBANK=sk-match
UDCODE=sk_snk
UDNAME=Slovak-SNK
POST_UD_BLOCKS=HamleDT::CS::FixUD
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/treebanks/sk/stb-match.conll | /net/work/people/zeman/parsing/tools/split_conll.pl -phead 80 $(IN)/train.conll $(IN)/dt.conll
	cat $(IN)/dt.conll | /net/work/people/zeman/parsing/tools/split_conll.pl -phead 50 $(IN)/dev.conll $(IN)/test.conll

treex:
	$(TREEX) $(IMPORTX) is_member_within_afun=1 is_parenthesis_root_within_afun=1 from=$(IN)/train.conll sid_prefix=train- Filter::RemoveEmptySentences W2W::EstimateNoSpaceAfter $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORTX) is_member_within_afun=1 is_parenthesis_root_within_afun=1 from=$(IN)/dev.conll   sid_prefix=dev-   Filter::RemoveEmptySentences W2W::EstimateNoSpaceAfter $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORTX) is_member_within_afun=1 is_parenthesis_root_within_afun=1 from=$(IN)/test.conll  sid_prefix=test-  Filter::RemoveEmptySentences W2W::EstimateNoSpaceAfter $(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced
