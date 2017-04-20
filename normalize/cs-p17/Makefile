LANGCODE=cs
TREEBANK=cs-p17
UDCODE=cs_p17
UDNAME=Czech-P17
HARMONIZE=Harmonize change_bundle_id=0
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords
include ../common.mak

# DFKI-Google Parallel Treebank
# Intermediate processing of the Czech part: take XPOSTAG+lemma annotation from Milan, process it as if it was Prague Dependency Treebank.
# prazska rucni morfologie k prevedeni do UD:
#  /home/straka/small_projects/conll17_cs_data/tagged-2-conllu-xpos/Data_Czech_morpho_1000.conllu
# naparsovaná verze je v
#  /home/straka/small_projects/conll17_cs_data/parsed/cs_dgpart-ud-test-parsed.conllu

SOURCE_MORPHO=/home/straka/small_projects/conll17_cs_data/tagged-2-conllu-xpos/Data_Czech_morpho_1000.conllu
source_morpho:
	mkdir -p data/source
	cat $(SOURCE_MORPHO) | perl -pe 'if(m/^\d+\t/) { @f=split(/\t/); $$f[6]=0; $$f[7]="NR"; $$_=join("\t",@f); }' > data/source/test.conllu

SOURCE=/home/straka/small_projects/conll17_cs_data/parsed/cs_dgpart-ud-test-parsed.conllu
source:
	cat $(SOURCE) | quot.pl > data/source/test.conllu

treex_morpho:
	$(TREEX) \
		$(IMPORTU) from='!$(IN)/test.conllu' \
		Util::Eval anode='$$.set_tag($$.conll_pos)' \
		Write::Treex clobber=1 path=$(DIR0)/test/ compress=1

# S naparsovanými daty už tohle nevolat, volat raději rovnou make ud, aby to šlo do adresáře treex/02.
treex:
	$(TREEX) \
		$(IMPORTU) from='!$(IN)/test.conllu' \
		HamleDT::CS::ToDoPunctuation \
		Write::Treex clobber=1 path=$(DIR0)/test/ compress=1

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud_morpho: prague_to_ud

# Před $(WRITE0) ještě bylo $(POST_UD_BLOCKS), ale to jsou SplitFusedWords, ty už teď vynechávám, protože to už je udělané.
ud:
	$(TREEX) \
		$(IMPORTU) from=$(IN)/test.conllu \
		HamleDT::CS::ToDoPunctuation \
		$(WRITE0) path=$(DIR2)/test/

# Po ruční anotaci v Tredu zkopírovat soubory *.treex.gz zpět do $(DIR2) a pustit tohle:
postprocess:
	$(QTREEX) \
		Read::Treex from='!$(DIR2)/test/*.treex.gz' \
		HamleDT::CS::CollectSentenceText \
		Write::CoNLLU print_zone_id=0 substitute={$(DIR2)}{$(CONLLUDIR)} compress=1
	../export_ud.sh $(UDCODE) $(UDNAME)
	cp /net/work/people/zeman/unidep/UD_$(UDNAME)/$(UDCODE)-ud-test.conllu /net/work/people/zeman/unidep/czech-parallel-ud
