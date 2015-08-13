LANGCODE=ro
TREEBANK=ro
include ../common.mak
# Do not make the following path derived from TMT_ROOT!
# We need the fixed path to the ÚFAL location where the data really is!
# Even if we are building a custom revision of HamleDT with modified TMT_ROOT, which is not linked to the ÚFAL shared folder.
ORIG_TREEBANK=/net/projects/tectomt_shared/data/resources/treebanks/ro

source: $(IN)/train.xml $(IN)/dev.xml $(IN)/test.xml

$(IN)/%.xml: $(ORIG_TREEBANK)/*.xml
	mkdir -p $(IN)
	echo '<?xml version="1.0" encoding="utf-8"?>' > $@
	echo '<!DOCTYPE DGAdoc SYSTEM "dga.dtd">' >> $@
	echo '<DGAdoc>' >> $@
	if [[ $* == train ]] ; then SOURCE='tp[0-9][0-9].xml' ; \
	elif [[ $* == dev ]] ; then SOURCE='tp[0-9].xml' ; \
	else SOURCE='t[0-9]*.xml' ; fi ; \
	echo $$SOURCE ;\
	for FILE in $(ORIG_TREEBANK)/$$SOURCE ; do\
	  head -n -1 $$FILE | tail -n +5 | iconv -f l1 -t utf8  >> $@;\
        done
	echo '</DGAdoc>' >> $@

IMPORT = Read::DGA bundles_per_doc=100
treex:
	$(TREEX) $(IMPORT) from=$(IN)/train.xml $(WRITE0) path=$(DIR0)/train/
	$(TREEX) $(IMPORT) from=$(IN)/dev.xml   $(WRITE0) path=$(DIR0)/dev/
	$(TREEX) $(IMPORT) from=$(IN)/test.xml  $(WRITE0) path=$(DIR0)/test/

# ud should map either to prague_to_ud, or to conllu_to_treex.
ud: prague_to_ud
