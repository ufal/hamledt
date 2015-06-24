LANGCODE=grc
TREEBANK=grc
include ../common.mak
XML2CONLL = $(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl
BETACODE  = $(TMT_ROOT)/tools/format_convertors/conll_to_conll/beta2unicode.pl
DECYCLE   = ../conll_break_cycles.pl

#/net/data/ancient-greek-dt/1.2/data$ for i in *.xml ; do echo $i `grep '<word' $i | wc -l` ; done
#1999.01.0003.xml 9806
#1999.01.0005.xml 6380
#1999.01.0007.xml 6563
#1999.01.0009.xml 7045
#1999.01.0011.xml 6223
#1999.01.0013.xml 6206
#1999.01.0015.xml 5949
#1999.01.0127.xml 3834
#1999.01.0129.xml 8106
#1999.01.0131.xml 6941
#1999.01.0133.xml 128102
#1999.01.0135.xml 104467
#1999.01.0183.xml 9474
#agdt-1.2.xml 309092

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp /net/data/ancient-greek-dt/1.2/data/1999.*.xml $(IN)
	mv $(IN)/1999.01.0013.xml $(IN)/dev.xml
	mv $(IN)/1999.01.0015.xml $(IN)/test.xml
	$(XML2CONLL) -i $(IN)/1999.01.0003.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0003.conll
	$(XML2CONLL) -i $(IN)/1999.01.0005.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0005.conll
	$(XML2CONLL) -i $(IN)/1999.01.0007.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0007.conll
	$(XML2CONLL) -i $(IN)/1999.01.0009.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0009.conll
	$(XML2CONLL) -i $(IN)/1999.01.0011.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0011.conll
	$(XML2CONLL) -i $(IN)/1999.01.0127.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0127.conll
	$(XML2CONLL) -i $(IN)/1999.01.0129.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0129.conll
	$(XML2CONLL) -i $(IN)/1999.01.0131.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0131.conll
	$(XML2CONLL) -i $(IN)/1999.01.0133.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0133.conll
	$(XML2CONLL) -i $(IN)/1999.01.0135.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0135.conll
	$(XML2CONLL) -i $(IN)/1999.01.0183.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0183.conll	
	cat $(IN)/19*.conll > $(IN)/train.conll
	$(XML2CONLL) -i $(IN)/dev.xml  | $(BETACODE) | $(DECYCLE) > $(IN)/dev.conll
	$(XML2CONLL) -i $(IN)/test.xml | $(BETACODE) | $(DECYCLE) > $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
