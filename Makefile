LANGUAGES = ar bg bn ca cs da de el en es et eu fi grc hi hu it ja la nl pt ro ru sl sv ta te tr

all:
	$(foreach lang,$(LANGUAGES),make LANG=$(lang) nonproj ; )
nonproj:
	treex -L$(LANG) -s Eval::Nonproj -- $(LANG)/data/treex/001_pdtstyle/train/*.treex.gz $(LANG)/data/treex/001_pdtstyle/test/*.treex.gz >> $(LANG).nonproj.txt
