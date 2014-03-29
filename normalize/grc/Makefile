LANGCODE=grc
TREEBANK=grc
include ../common.mak
XML2CONLL = $(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl
BETACODE  = $(TMT_ROOT)/tools/format_convertors/conll_to_conll/beta2unicode.pl
DECYCLE   = ../conll_break_cycles.pl

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp /net/data/ancient-greek-dt/1.2/data/1999.*.xml $(IN)
	mv $(IN)/1999.01.0015.xml $(IN)/test.xml
	$(XML2CONLL) -i $(IN)/1999.01.0003.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0003.conll
	$(XML2CONLL) -i $(IN)/1999.01.0005.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0005.conll
	$(XML2CONLL) -i $(IN)/1999.01.0007.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0007.conll
	$(XML2CONLL) -i $(IN)/1999.01.0009.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0009.conll
	$(XML2CONLL) -i $(IN)/1999.01.0011.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0011.conll
	$(XML2CONLL) -i $(IN)/1999.01.0013.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0013.conll
	$(XML2CONLL) -i $(IN)/1999.01.0127.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0127.conll
	$(XML2CONLL) -i $(IN)/1999.01.0129.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0129.conll
	$(XML2CONLL) -i $(IN)/1999.01.0131.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0131.conll
	$(XML2CONLL) -i $(IN)/1999.01.0133.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0133.conll
	$(XML2CONLL) -i $(IN)/1999.01.0135.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0135.conll
	$(XML2CONLL) -i $(IN)/1999.01.0183.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0183.conll	
	cat $(IN)/19*.conll > $(IN)/train.conll
	$(XML2CONLL) -i $(IN)/test.xml | $(BETACODE) | $(DECYCLE) > $(IN)/test.conll

treex: conll_to_treex

# Parallelize normalization to make it faster.
###!!! Vypadá to, že za současného nastavení se pro train i test dohromady použije počet úloh z ...TRAIN_OPT a ...TEST_OPT se ignoruje.
TO_PDT_TRAIN_OPT := -p --jobs 21
