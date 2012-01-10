LANGCODE=is
include ../common.mak

source:
	mkdir -p $(DATADIR)
	mkdir -p $(IN)
	cat /net/data/icelandic-phc/psd/*.psd > $(IN)/all.psd
	###!!! TO DO: split all.psd to train.psd and test.psd by taking every tenth sentence for test, and the rest for training.
