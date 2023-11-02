LANGCODE=cs
TREEBANK=cs-cltt
UDCODE=cs_cltt
UDNAME=Czech-CLTT
HARMONIZE=Harmonize iset_driver=cs::pdt
POST_UD_BLOCKS=HamleDT::CS::SplitFusedWords HamleDT::CS::FixUD
include ../common.mak

SOURCEDIR_CLTT10=/net/data/treebanks/cs/cltt-1.0
SCHEMADIR_CLTT10=/net/data/treebanks/cs/cltt-1.0
SOURCEDIR_CLTT20=/net/data/treebanks/cs/cltt-2.0/sentences/pml
SCHEMADIR_CLTT20=/net/data/treebanks/cs/cltt-2.0/sentences/pml
# Instead of the officially released CLTT 2.0, we now take the data from the development version where additional errors have been fixed.
SOURCEDIR=/net/work/projects/cltt/data/sentences/pml
SCHEMADIR=/net/work/projects/cltt/data/sentences/pml

# There is no official train / dev / test data split.
# document_01_001.a
source_cltt10:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	cp $(SOURCEDIR_CLTT10)/document_01_00[1-6].[amw] $(IN)/train
	cp $(SOURCEDIR_CLTT10)/document_01_00[7-9].[amw] $(IN)/dev
	cp $(SOURCEDIR_CLTT10)/document_02_00[1-2].[amw] $(IN)/dev
	cp $(SOURCEDIR_CLTT10)/document_02_00[3-8].[amw] $(IN)/test

source:
	mkdir -p data/source/train
	mkdir -p data/source/dev
	mkdir -p data/source/test
	cp $(SOURCEDIR)/document_01_00[1-6].[amw] $(IN)/train
	cp $(SOURCEDIR)/document_01_00[7-9].[amw] $(IN)/dev
	cp $(SOURCEDIR)/document_02_00[1-2].[amw] $(IN)/dev
	cp $(SOURCEDIR)/document_02_00[3-8].[amw] $(IN)/test

treex_cltt10:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR_CLTT10) top_layer=a from='!$(IN)/train/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR_CLTT10) top_layer=a from='!$(IN)/dev/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR_CLTT10) top_layer=a from='!$(IN)/test/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=0

# Just copying Treex files from CLTT 2.0 (sentences/treex instead of sentences/pml) does not work because some details are different from what we expect.
treex_cltt20_fromtreex:
	rm -f $(DIR0)/{train,dev,test}/*.treex
	rm -f $(DIR0)/{train,dev,test}/*.treex.gz
	cp $(IN)/train/*.treex.gz $(DIR0)/train
	cp $(IN)/dev/*.treex.gz $(DIR0)/dev
	cp $(IN)/test/*.treex.gz $(DIR0)/test
	gunzip $(DIR0)/{train,dev,test}/*.treex.gz

treex:
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/train/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/train/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/dev/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/dev/ compress=0
	$(TREEX) \
		Read::PDT schema_dir=$(SCHEMADIR) top_layer=a from='!$(IN)/test/*.a' \
		A2A::FillCoNLLAttributes \
		Write::Treex clobber=1 path=$(DIR0)/test/  compress=0

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud_enhanced export

# We need our own export because we need specific post-processing.
UDAPISCEN=ud.cs.FixEdeprels
export: ud_export default_ud_postprocessing

ud_export:
	@echo `date` cat train started | tee -a time.log
	cat $(CONLLUDIR)/train/*.conllu | ./reset_old_sentence_ids.pl | ../conllu_docpar_from_sentid.pl > $(UDCODE)-ud-train.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-train.conllu
	@echo `date` cat dev started | tee -a time.log
	cat $(CONLLUDIR)/dev/*.conllu | ./reset_old_sentence_ids.pl | ../conllu_docpar_from_sentid.pl >  $(UDCODE)-ud-dev.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-dev.conllu
	@echo `date` cat test started | tee -a time.log
	cat $(CONLLUDIR)/test/*.conllu | ./reset_old_sentence_ids.pl | ../conllu_docpar_from_sentid.pl >> $(UDCODE)-ud-test.conllu
	$(UDTOOLS)/fix-space-after-paragraph.pl $(UDCODE)-ud-test.conllu
