HamleDT (HArmonized Multi-LanguagE Dependency Treebank) is a compilation of
existing dependency treebanks (or dependency conversions of other treebanks),
transformed so that they all conform to the same annotation style. For more
information please see the project website at

http://ufal.mff.cuni.cz/hamledt

This repository contains makefiles and support scripts needed for HamleDT
development. You also need Treex and Interset, which are in separate
repositories. In particular, the tree transformation and harmonization code
is part of Treex (implemented as Treex blocks), see the ufal/treex Github
repository.



History:

These files were originally stored in the TectoMT Subversion repository
(https://svn.ms.mff.cuni.cz/svn/tectomt_devel/trunk/treex/devel/hamledt).
Some important points in time:

r5974  (2011-06-27 zabokrtsky) ... created treex/devel/normalize_treebanks
r7684  (2011-12-31) .............. HamleDT 0.9 or 1.0 approximate date (not fixed and archived)
r8819  (2012-06-11 popel) ........ normalize_treebanks renamed to hamledt
r11004 (2013-08-28 rosa) ......... hamledt copied to hamledt2
r11606 (2014-02-15 zeman) ........ HamleDT release 1.5 (Prague, article in LRE)
r11870 (2014-03-14 zeman) ........ removed old hamledt (after checking all languages for HamleDT release 2.0)
r11991 (2014-03-23 zeman) ........ hamledt2 renamed to hamledt
r12700 (2014-05-24 zeman) ........ HamleDT release 2.0 (Prague + Stanford)
r14841 (2015-04-23 zeman) ........ pruned large generatable files, hamledt with history copied to Github ufal/hamledt

See also

https://svn.ms.mff.cuni.cz/trac/tectomt_devel/

(password-protected access, only for ÚFAL members).



Notes on migration to Github:

Created a users.txt file following the instructions in
http://git-scm.com/book/es/v2/Git-and-Other-Systems-Migrating-to-Git

git svn clone https://svn.ms.mff.cuni.cz/svn/tectomt_devel --authors-file=users.txt --no-metadata --trunk=trunk/treex/devel/hamledt --prefix=svn/

Tag statistics and similar files that were comparably large and that could be
generated again if necessary were removed from the repository. The history was
then pruned using the BFG repo-cleaner (https://rtyley.github.io/bfg-repo-cleaner/),
with the blob size limit set to 400K. Subsequently the git garbage collection
was invoked as recommended in the BFG documentation:

java -jar bfg-1.12.3.jar --private -b 400K hamledt
cd hamledt
git reflog expire --expire=now --all && git gc --prune=now --aggressive

git remote add origin https://github.com/ufal/hamledt.git
git push -u origin master
