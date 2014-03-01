LANGCODE=sk
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp /net/data/ancient-greek-dt/1.2/data/1999.*.xml $(IN)
	mv $(IN)/1999.01.0015.xml $(IN)/test.xml
	$(XML2CONLL) -i $(IN)/1999.01.0003.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0003.conll
	$(XML2CONLL) -i $(IN)/1999.01.0183.xml | $(BETACODE) | $(DECYCLE) > $(IN)/1999.01.0183.conll	
	cat $(IN)/19*.conll > $(IN)/train.conll
	$(XML2CONLL) -i $(IN)/test.xml | $(BETACODE) | $(DECYCLE) > $(IN)/test.conll

treex:
	treex -Lsk Read::PDT schema_dir=/net/projects/pdt/pdt20/data/schemas t_layer=0 from=/net/work/people/zeman/slovallex/Wikipedia/anotator1/wiki-30_kandracova_dok.a Write::Treex clobber=1 to=data/treex/000_orig/train/wiki-30_kandracova_dok.treex.gz

