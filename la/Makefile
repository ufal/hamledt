LANGCODE=la
DATADIR=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGCODE)
IN       = $(DATADIR)/source
DIR0     = $(DATADIR)/treex/000_orig
DIR1     = $(DATADIR)/treex/001_pdtstyle
TREEX    = treex -L$(LANGCODE) -p
IMPORT   = Read::CoNLLX lines_per_doc=500
WRITE0   = Write::Treex file_stem=''
WRITE    = Write::Treex

prepare_source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cp /net/data/latin-dt/1.5/data/[12]*.xml $(IN)
	mv $(IN)/1999.02.0029.xml $(IN)/test.xml

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


source_xml_to_conll:
	
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0002.xml > $(IN)/1999.02.0002.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0010.xml > $(IN)/1999.02.0010.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0055.xml > $(IN)/1999.02.0055.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0060.xml > $(IN)/1999.02.0060.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/1999.02.0066.xml > $(IN)/1999.02.0066.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/2007.01.0001.xml > $(IN)/2007.01.0001.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/2008.01.0002.xml > $(IN)/2008.01.0002.conll
	# If test.conll has already been created before we definitely do not want to include it in train.conll!
	cat $(IN)/1999.*.conll $(IN)/200[78].*.conll > $(IN)/train.conll
	$(TMT_ROOT)/tools/format_convertors/xml_to_conll/xml_to_conll.pl -i $(IN)/test.xml > $(IN)/test.conll

# run a conversion of the original data into the treex format
# and store the results in 000_orig/
to_treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.conll $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/test.conll  $(WRITE0) path=$(DIR0)/test/

# make the trees as similar to the PDT-style as possible
# and store the result in 001_pdtstyle
SCEN1 = A2A::LA::CoNLL2PDTStyle A2A::SetSharedModifier
to_pdt:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/train/ -- $(DIR0)/train/*.treex.gz
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/  -- $(DIR0)/test/*.treex.gz

# This goal serves development and debugging of the CoNLL2PDTStyle block.
test:
	$(TREEX) $(SCEN1) $(WRITE) path=$(DIR1)/test/ -- $(DIR0)/test/*.treex.gz

clean:
	rm -rf $(DATADIR)/treex
	rm -rf $(DATADIR)/source


