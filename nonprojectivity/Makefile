SHELL=bash
LANGUAGES = ar bg bn ca cs da de el en es et eu fa fi grc hi hr hu it ja la nl pl pt ro ru sk sl sv ta te tr
UD1LANGUAGES = de en es fi fr ga hu it sv cs

all:
	$(foreach lang,$(LANGUAGES),make LNG=$(lang) TBK=$(lang) nonproj ; )
ud:
	$(foreach lang,$(UD1LANGUAGES),make LNG=$(lang) TBK=$(lang)-ud1 nonproj ; )
nonproj:
	treex -L$(LNG) Eval::Nonproj -- ../normalize/$(TBK)/data/treex/02/{train,dev,test}/*.treex.gz > $(TBK).nonproj.txt
