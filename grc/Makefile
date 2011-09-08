LANGCODE=grc
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE)
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE0   = Write::Treex file_stem=''
WRITE    = Write::Treex

prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp /net/data/ancient-greek-dt/1.2/data/1999.*.xml $(IN)
	mv $(IN)/1999.01.0015.xml $(IN)/test.xml

source_xml_to_conll:
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0003.xml > $(IN)/1999.01.0003.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0005.xml > $(IN)/1999.01.0005.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0007.xml > $(IN)/1999.01.0007.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0009.xml > $(IN)/1999.01.0009.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0011.xml > $(IN)/1999.01.0011.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0013.xml > $(IN)/1999.01.0013.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0127.xml > $(IN)/1999.01.0127.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0129.xml > $(IN)/1999.01.0129.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0131.xml > $(IN)/1999.01.0131.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0133.xml > $(IN)/1999.01.0133.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0135.xml > $(IN)/1999.01.0135.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.01.0183.xml > $(IN)/1999.01.0183.conll	
	cat $(IN)/19*.conll > $(IN)/train.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/test.xml > $(IN)/test.conll

prepare_dirs:
	@echo The root data directory for $(LANGCODE): $(DATADIR)
	mkdir -p $(DATADIR)
	if [ ! -e data ]; then ln -s $(DATADIR) data; fi
	mkdir -p $(DIR0)
	mkdir -p $(DIR0)/train
	mkdir -p $(DIR0)/test
	mkdir -p $(DIR1)
	mkdir -p $(DIR1)/train
	mkdir -p $(DIR1)/test
	chmod -R g+w data/. data/*

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE0) path=$(DIR0)/test/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::GRC::CoNLL2PDTStyle
to_pdt:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# This goal serves development and debugging of the CoNLL2PDTStyle block.
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/ -- $(DIR0)/test/*.treex.gz

clean:
	rm -rf $(DATADIR)/treex


