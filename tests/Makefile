SHELL=bash
JOBS=200
VALLOG=validation.log
TESTLOG=test.log
# You can also specify the languages and datasets you are interested in (you should also set e.g. JOBS=10)
#LANGS={en,cs}
LANGS=*
SETS={train,test}
FILES=$(TMT_ROOT)/share/data/resources/normalized_treebanks/$(LANGS)/treex/???_pdtstyle/$(SETS)/*treex

validate:
	treex -p --survive --jobs $(JOBS) -- $(FILES)  2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

filelist:
	echo $(FILES) | tr " " "\n"

summarize_validation:
	grep -v TREEX $(VALLOG) || exit 0

tests:
	treex -p --survive --jobs $(JOBS) \
	Util::SetGlobal language=mul \
	Test::A::CoApAboveEveryMember \
	Test::A::LeafAux \
	Test::A::MemberInEveryCoAp \
	Test::A::NonemptyAttr \
	Test::A::NonleafAuxC \
	Test::A::NonleafAuxP \
	Test::A::SubjectBelowVerb \
	-- $(FILES) 2> $(TESTLOG)

summarize_tests:
	cat $(TESTLOG) | ./summarize_tests.pl


clean:
	rm *.log