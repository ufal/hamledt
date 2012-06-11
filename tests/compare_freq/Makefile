AFUNS=afuns.txt

collect:
	treex -p --jobs=100 --survive Util::Eval language=mul anode='print $$anode->get_zone->language."\t".($$anode->afun||"")."\n"' -- /net/projects/tectomt_shared/data/resources/hamledt/*/treex/*_pdtstyle/t*/*.treex.gz > $(AFUNS)

table:
	cat $(AFUNS) | ./print_table.pl