Slovak National Corpus (SNK)
data that we got access to during visit of Daniela Majchráková, for experiments with Slovak t-layer and SloValLex

License: no agreement at the moment; so: research only, do not distribute, contact authors if you intend to publish any results
The treebank has not been released yet. The data we have often contain two independent annotations of the same file, unmerged.
https://svn.ms.mff.cuni.cz/svn/slovallex/trunk/
/ha/home/zeman/network/slovallex

training size = ...
test size     = sentences, tokens



Subject: informácia o syntakticky anotovaných textoch
Date: Fri, 14 Feb 2014 16:09:06 +0100
From: Agata Karcova <agatak@korpus.juls.savba.sk>
To: Jan Hajič <hajic@ufal.mff.cuni.cz>

Dobrý deň,

posielam základné informácie o opravách syntakticky anotovaných textov
(R. Brída, A. Karčová), ktoré sme nahrali do repozitára SVN (R. Garabík).
Prvú časť súborov sme nahrávali koncom januára 2014, druhú časť 13.
februára 2014.
Pred nahratím sme urobili niekoľko kontrol a základných opráv, ktoré sa
zameriavali hlavne na to, aby:

- každý text bol vo formátoch a, m, w
- texty, ktoré boli zanotované dvojmo, boli rozdelené do priečinkov
anotator1, anotator2
- názvy súborov navzájom korešpondovali a každý obsahoval informáciu o
anotátorovi (identifikátor je názov súboru po znak '_')
- boli zaradené len zanotované súbory (v niektorých sa ešte môžu
objavovať otázniky (???) namiesto určenia vetného člena, ale nemali by
tam byť celé nezanotované súbory)
- texty neobsahovali chybne kódované znaky (opravili sme niekoľko
chybných lem aj tvarov, zle kódované úvodzovky; niekoľko chybných znakov
však pravdepodobne ostalo)

Ďalej sme vyradili defektné súbory (nedali sa otvoriť), súbory s tým
istým kódom, ale rozličným počtom slov a pod.

V prvom termíne sme do hlavného adresára nahrali tieto súbory s textami
(všetky sú párne, t. j. zanotované dvoma anotátormi):

BallekPomocnik
blogSME
Durovic
Inzine
MilosFerko
MilosFerko2
MojaPrvaLaska
Mucska
Orwell1984
Patmos
ProgramVyhlasenie
PsiaKoza
RaczovaOslov
Rozpravky
SME
Wikipedia

V druhom termíne sme do hlavného adresára pridali adresár Wikipedia2
(ďalšie texty z Wikipédie anotované dvojmo); do adresára
'single_annotator' sme nahrali ďalšie texty zanotované len jedným
anotátorom:

blogSME
DominoForum
HvoreckyLovciaZberaci
KralikMorus
Lenco
RaczovaRoman
Stavebnictvo
zber1-zvysne (ide o súbory, ktoré sme odfiltrovali z 1. súboru textov;
nie sú defektné, len nemajú pár)

Chcela by som upozorniť aj na skutočnosť, že iba niektoré texty, ktoré
sú syntakticky anotované, boli predtým ručne morfologicky anotované
(Orwell1984, MojaPrvaLaska, Mucska, MilosFerko, MilosFerko2, Patmos,
PsiaKoza a niektoré ďalšie).

Prajem vám úspešný deň.

S pozdravom

Agáta Karčová
SNK JÚĽŠ SAV v Bratislave

