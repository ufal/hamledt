LANGCODE=la
TREEBANK=la
include ../common.mak

#/net/data/latin-dt/1.5/data$ for i in *.xml ; do echo $i `grep '<word' $i | wc -l` ; done
#1999.02.0002.xml 1488
#1999.02.0010.xml 6229
#1999.02.0029.xml 4789
#1999.02.0055.xml 2613
#1999.02.0060.xml 8382
#1999.02.0066.xml 4857
#2007.01.0001.xml 12474
#2008.01.0002.xml 12311
#ldt-1.5.xml 53143

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp /net/data/latin-dt/1.5/data/[12]*.xml $(IN)
	mv $(IN)/1999.02.0055.xml $(IN)/dev.xml
	mv $(IN)/1999.02.0029.xml $(IN)/test.xml
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0002.xml > $(IN)/1999.02.0002.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0010.xml > $(IN)/1999.02.0010.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0060.xml > $(IN)/1999.02.0060.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0066.xml > $(IN)/1999.02.0066.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/2007.01.0001.xml > $(IN)/2007.01.0001.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/2008.01.0002.xml > $(IN)/2008.01.0002.conll
	# If test.conll has already been created before we definitely do not want to include it in train.conll!
	cat $(IN)/1999.*.conll $(IN)/200[78].*.conll > $(IN)/train.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/dev.xml  > $(IN)/dev.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/test.xml > $(IN)/test.conll

treex: conll_to_treex

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
