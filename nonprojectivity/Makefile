SHELL=bash
LANGUAGES = ar bg bn ca cs da de el en es et eu fa fi grc hi hr hu it ja la nl pl pt ro ru sk sl sv ta te tr
UD1LANGUAGES = de en es fi fr ga hu it sv cs
UD11LANGUAGES = $(UD1LANGUAGES) bg da el eu fa he hr id

all: ud1 ud11
	$(foreach lang,$(LANGUAGES),make LNG=$(lang) TBK=$(lang) qnonproj ; )
ud1:
	$(foreach lang,$(UD1LANGUAGES),make LNG=$(lang) TBK=$(lang)-ud1 qnonproj ; )
ud11:
	$(foreach lang,$(UD11LANGUAGES),make LNG=$(lang) TBK=$(lang)-ud11 qnonproj ; )
nonproj:
	treex -L$(LNG) Eval::Nonproj -- ../normalize/$(TBK)/data/treex/02/{train,dev,test}/*.treex.gz > $(TBK).nonproj.txt
qnonproj:
	treex -p --jobs 100 --priority 0 -L$(LNG) Eval::Nonproj -- ../normalize/$(TBK)/data/treex/02/{train,dev,test}/*.treex.gz > $(TBK).qnonproj.txt
	cat $(TBK).qnonproj.txt | grep -v -P '_(orig|prague)' | perl -e 'while(<>) { if(m:\t(\d+)/(\d+)\t:) { $$x+=$$1; $$n+=$$2; }} printf("%d/%d = %f\n", $$x, $$n, $$x/$$n);'
