Finnish Universal Dependencies / FinnTreeBank
released via LINDAT/CLARIN on 15.5.2015
http://universaldependencies.github.io/docs/fi/overview/introduction.html
http://hdl.handle.net/11234/LRT-1478

License: GNU LGPL v3 or later

training size    = 11459 sentences, 97165 tokens, 175 fused tokens spanning 350 nodes, i.e. 96990 total surface tokens
development size =  3819 sentences, 32439 tokens, 66 fused tokens spanning 132 nodes, i.e. 32373 total surface tokens
test size        =  3819 sentences, 32380 tokens, 61 fused tokens spanning 122 nodes, i.e. 32319 total surface tokens

* Origin

The UD version of FinnTreeBank 1 was derived from FinnTreeBank 1 2014
by a scripted mapping of labels and some restructuring in an attempt
to conform approximately to the UD Finnish model.

Unannotated linguistic material in FinnTreeBank 1 2014 was adapted
from the examples in Ison suomen kieliopin verkkoversio (The Web
Version of the Large Grammar of Finnish, VISK), available on-line as
<http://scripta.kotus.fi/visk>, and annotations originally produced
and further revised in FIN-CLARIN projects in the Department of Modern
Languages, University of Helsinki.


* Differences from the UD Finnish model

Some differences from the UD Finnish model remain unaddressed.

Surface words that have an adverb or a conjunction fused with a
following negative verb are separated into two tokens in the
FinnTreeBank model. The UD version keeps them as such but adds the
unannotated joined token before the two.

A small number of multiword sequences remain as single tokens.

Most punctuation tokens are linked to a nearby token instead of a
clause head.

The xcomp relation is not used in the mapping (the distinction between
xcomp and comp is not supported in the underlying FinnTreeBank model).

As a catchall, the dep relation is used as intended when a more proper
mapping could not be determined.

Some FinnTreeBank annotations are retained in the MISC field.


* Splitting

The treebank was split into training, development, and test sets by
repeatedly taking 8 sentences into training set, 1 into development
set, and 1 into test set.


* Statistics

Tree count:  19097
Word count:  161984
Token count: 161682
Dep. relations: 26 of which 2 language specific
POS tags: 14
Category=value feature pairs: 64


* Sources

VISK = Auli Hakulinen, Maria Vilkuna, Riitta Korhonen, Vesa Koivisto,
Tarja Riitta Heinonen and Irja Alho 2004: Iso suomen
kielioppi. Helsinki: Suomalaisen Kirjallisuuden Seura. Online version.
Available: http://scripta.kotus.fi/visk URN:ISBN:978-952-5446-35-7

<http://www.ling.helsinki.fi/kieliteknologia/tutkimus/treebank/>

fin-clarin@helsinki.fi
