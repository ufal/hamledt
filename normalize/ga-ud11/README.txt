Irish Universal Dependencies / Irish Dependency Treebank (IDT)
released via LINDAT/CLARIN on 15.5.2015
http://universaldependencies.github.io/docs/ga/overview/introduction.html
http://hdl.handle.net/11234/LRT-1478

License: CC BY-SA 3.0

training size    = 720 sentences, 16701 tokens
development size = 150 sentences,  3164 tokens
test size        = 150 sentences,  3821 tokens

The Irish UD Treebank is a conversion of the Irish Dependency Treebank (IDT). IDT development is a work-in-progress as part of a PhD research project by Teresa Lynn at Dublin City University, Ireland. The IDT data has not yet been officially released. The Treebank contains 1020 sentences taken from the New Corpus of Ireland-Irish (NCII), with text from books, newswire, websites and other media. These sentences are a subset of a gold-standard POS-tagged corpus for Irish 

The conversion from the IDT annotation scheme to the UD annotation scheme was designed by Teresa Lynn and Jennifer Foster at Dublin City University, Ireland.

The UD Treebank is split into three sets: 
* 150 trees (test)
* 150 trees (dev)
* 720 trees (train)


STATISTICS

Trees: 1020
Token count: 23686
Dependency Relations: 36 of which 10 language specific
POS tags: 16
No morphological features


TOKENISATION

The tokenisation of the Irish data is the output of a Xerox Finite State tokenizer implemented by Uí Dhonnchadha (2002)

Note:
 - compound prepositions are connected as one token with '_'. Example: in aghaidh 'against' => in\_aghaidh

The Irish data does not contain any other multi-word tokens.



SYNTAX

The Irish UD treebank uses 26 of the UD dependency labels. A further 10 language specific labels were introduced to deal with certain linguistic phenomena in Irish:

- acl:relcl for relative clauses
- case:voc for vocative particles
- compound:prt for verb particle heads
- csubj:cleft for cleft subjects
- csubj:cop for copular clausal subject
- mark:prt for (most) particles
- nmod:poss for possessive pronouns
- nmod:prep for pronominal prepositions
- nmod:tmod for nominal temporal modifiers
- xcomp:pred for predicates of the substantive verb "to be"


MORPHOLOGICAL DATA

Note that the current version of the UD Irish treebank does not contain morphological features. This section of work has not yet been completed for the IDT. When it is, it will be migrated to the UD version. 




REFERENCES

Uí Dhonnchadha, E. 2002. An Analyser and Generator for Irish Inflectional Morphology using Finite State Transducers, School of Computing, Dublin City University: Unpublished MSc Thesis.

Uí Dhonnchadha, E. 2009. Part-of-Speech Tagging and Partial Parsing for Irish using Finite-State Transducers and Constraint Grammar (PhD thesis)

Stenson, N, 1981. Studies in Irish Syntax, Tübingen: Gunter Narr Verlag.

Christian Brothers, 1988. New Irish Grammar, Dublin: C J Fallon



CHANGELOG

15-05-2015

* Changed POS tag for "féin" to PRON instead of NOUN
* Fixed the labelling and attachment of English (foreign) text strings
* Changed the labels for subjects of cleft constructions from 'nsubj' to 'csubj:cleft'
