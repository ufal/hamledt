SHELL=bash
LANGUAGES = ar bg bn ca cs da de el en es et eu fa fi grc hi hu it ja la nl pt ro ru sk sl sv ta te tr

all:
	$(foreach lang,$(LANGUAGES),make LNG=$(lang) nonproj ; )
nonproj:
	treex -L$(LNG) -s Eval::Nonproj -- ../normalize/$(LNG)/data/treex/001_pdtstyle/{train,test}/*.treex.gz > $(LNG).nonproj.txt
