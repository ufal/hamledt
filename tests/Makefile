JOBS=120
VALLOG=validation.log
TESTLOG=test.log

validate:
	treex -p --survive --jobs $(JOBS) -- $(TMT_ROOT)/share/data/resources/normalized_treebanks/*/treex/001_pdtstyle/*/*treex 2>&1 | tee $(VALLOG)
	@echo
	@echo Output of the validation test stored in $(VALLOG)

resume_validation:
	cat $(VALLOG) | grep -v TREEX > errors.log

tests:
	treex -p --survive --jobs $(JOBS) \
	Util::SetGlobal language=mul \
	Test::A::MemberInEveryCoAp \
	Test::A::CoApAboveEveryMember \
	-- $(TMT_ROOT)/share/data/resources/normalized_treebanks/*/treex/001_pdtstyle/*/*treex \
	2>&1 | tee $(TESTLOG)

resume_tests:
	cat $(TESTLOG) | ./resume_tests.pl


clean:
	rm *.log