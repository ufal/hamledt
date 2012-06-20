SHELL=bash
JOBS=100
VALLOG=validation.log
TESTLOG=test.log
# You can also specify the languages and datasets you are interested in (you should also set e.g. JOBS=10)
#LANGS={en,cs}
LANGS=*
SETS={train,test}
FILES=$(TMT_ROOT)/share/data/resources/hamledt/$(LANGS)/treex/*_pdtstyle/$(SETS)/*.treex.gz

validate:
	treex -p --jobs=$(JOBS) --survive -- $(FILES)  2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

filelist:
	echo $(FILES) | tr " " "\n"

summarize_validation:
	grep -v TREEX $(VALLOG) || exit 0

tests:
	treex  -p --jobs=$(JOBS) --survive \
	Util::SetGlobal language=mul \
	Test::A::CoApAboveEveryMember \
	Test::A::LeafAux \
	Test::A::MemberInEveryCoAp \
	Test::A::NonemptyAttr \
	Test::A::NonleafAuxC \
	Test::A::NonleafAuxP \
	Test::A::SubjectBelowVerb \
	Test::A::AfunKnown \
	Test::A::AfunDefined \
	Test::A::PredUnderRoot \
	-- $(FILES) 2> test.err > $(TESTLOG)

table:
	cat $(TESTLOG) | ./summarize_tests.pl


clean:
	rm -rf *.log ???-cluster-run-*
