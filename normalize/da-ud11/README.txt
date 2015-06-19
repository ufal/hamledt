Danish Universal Dependencies / Danish Dependency Treebank
released via LINDAT/CLARIN on 15.5.2015
http://universaldependencies.github.io/docs/da/overview/introduction.html
http://hdl.handle.net/11234/LRT-1478

License: GNU Public License, version 2

training size    = 4868 sentences, 88540 tokens
development size =  322 sentences,  5846 tokens
test size        =  322 sentences,  5852 tokens

## DESCRIPTION

The Danish UD treebank has been converted from the Danish
Dependency Treebank (Buch-Kromman,2003) into Universal Dependencies
(UD). It consists of 5,512 sentences (100,238 words). The Danish
source texts and the Danish part-of-speech tags were created by the PAROLE-DK
project (Keson 1998) by the Danish Society for Language and Literature.

In the DDT formalism, determiners head nouns, and auxiliaries head
verbs. In order to promote content words to heads, we have applied a
cascade of graph transformations that make function words (determiners,
auxiliaries, conjunctions, etc) leaves in the dependency tree, instead
of intermediate elements between content heads.

The part-of-speech tags and labels from the original treebank have been
partially converted using mappings, and partially using the new
calculated tree structure as a reference to assign labels.


## NOTES FOR NEXT RELEASE

The current release contains the original tokenization of DDT, where
multiword units like *i_dag* (today) or *selv_om* (even though) have
been underscored together. These units are made up of more than one
syntactic word and need to be split, with a subsequent reattaching of
the dependency tree, for the treebank to be fully compliant with UD
tokenization.

Relations across clauses are not labeled in this scheme, i.e. the
current conversion does not assign labels like csubj.

## CONTRIBUTORS (in order of last names)

- Anders Johannsen <ajohannsen@hum.ku.dk>
- Héctor Martínez Alonso <alonso@hum.ku.dk>
- Barbara Plank <bplank@cst.dk>

## REFERENCES

* Buch-Kromann, Matthias T., Line Mikkelsen, and Stine Kern Lynge.
  "Danish dependency treebank.". TLT. 2003.

* Keson, Britt (1998). Documentation of The Danish Morpho-syntactically Tagged PAROLE Corpus.
Technical report, DSL
