LANGCODE=ug
TREEBANK=ug
UDCODE=ug
UDNAME=Uyghur
POST_UD_BLOCKS=W2W::Translit
include ../common.mak
# Temporary source dir for one sample file.
#SOURCEDIR=/net/work/people/zeman/hamledt
SOURCEDIR=/net/work/people/zeman/unidep/UD_Uyghur
# $(SOURCEDIR)/uyDTwithPOS.xml

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	ugdt_xml_to_conllu.pl < $(SOURCEDIR)/test_changed.xml | conll_break_cycles.pl > $(IN)/train.conllu
	#cp $(IN)/train.conllu $(IN)/dev.conllu
	#cp $(IN)/train.conllu $(IN)/test.conllu

# Do not convert Universal Dependencies to the Prague style and then back to UD. Instead, read directly UD.
# Note that there will be just one tree per sentence, not three. (There are three trees per sentence for treebanks that are converted via Prague.)
ud: conllu_to_treex

# We have a specific workflow for Uyghur:
# - The original treebank is saved as /net/work/people/zeman/hamledt/uyDTwithPOS.xml.
# - It is converted using "make source" (the ugdt_xml_to_conllu.pl script) to data/source/train.conllu.
# - It is converted to multiple Treex files using "make ud", the result is in data/treex/02/train/*.treex.gz.
# - These files are given back to Marhaba.
# Manual work:
# - Marhaba re-annotates these files in Tred to something like UD v1+ (with extended coordination-ellipsis relations) and sends them back to me.
# - I save the files in the UD_Uyghur repository as not-to-release/manually-checked-treex/*.treex.gz.
# Postprocessing:
# - The folder with the manually checked Treex files has its own Makefile.
#   Running "make all" there will run the validator and convert the files to UD v1 CoNLL-U.
#   The CoNLL-U file is saved to the main part of the repository.
###!!! But we now also need to convert the file to UD v2!
