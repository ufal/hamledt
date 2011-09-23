#!/usr/bin/env perl
# Usage:
# coordination_samples.pl | treex -Lmul Read::CoNLLX Write::Treex
# ttred noname.treex.gz &
use utf8;
use open ':utf8';
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

my @coord_sample = (

'cs' => 'praha' =>
'jablka , pomeranče a citróny',
'4 4 4 0 4',
'XXX_M AuxX XXX_M Coord XXX_M',

'sl' => 'praha' =>
'jabolka , pomaranče in limone',
'4 4 4 0 4',
'XXX AuxX XXX Coord XXX',

'la' => 'praha' =>
'pomis , oranges et lemons',
'4 4 4 0 4',
'XXX_CO AuxX XXX_CO COORD XXX_CO',

'el' => 'praha' =>
'μήλα , πορτοκάλια και λεμόνια',
'4 4 4 0 4',
'XXX_Co AuxX XXX_Co Coord XXX_Co',

'grc' => 'praha' =>
'μήλα , πορτοκάλια και λεμόνια',
'4 4 4 0 4',
'XXX_CO AuxX XXX_CO COORD XXX_CO',

'ar' => 'praha' =>
# alnfáh wa albrtqál wa allímún
'التفاح و البرتقال و الليمون',
'4 4 4 0 4',
'XXX AuxY XXX Coord XXX',

'ta' => 'praha' =>
# áppiļ , áraňču maŗŗum pařaŋkaļ
'ஆப்பிள் , ஆரஞ்சு மற்றும் பழங்கள்',
'4 4 4 0 4',
'XXX_Co AuxX XXX_Co Coord XXX_Co',

'nl' => 'praha' =>
'appels , sinaasappels en citroenen',
'4 1 4 0 4',
'cnj punct cnj XXX cnj',

'hi' => 'praha' =>
# séba , sañtaré aura níñbú
'सेब , संतरे और नींबू',
'4 1 4 0 4',
'ccof rsym ccof XXX ccof',

'bn' => 'praha' =>
# ápéla , kamalá ébañ lébu
'আপেল , কমলা এবং লেবু',
'4 1 4 0 4',
'ccof rsym ccof XXX ccof',

'te' => 'praha' =>
# ápilla , náriñdža mariju nimmapañđu
'ఆపిల్ల , నారింజ మరియు నిమ్మపండు',
'4 1 4 0 4',
'ccof adv ccof XXX ccof',

'eu' => 'praha' =>
'sagarrak , laranjak eta limoiak',
'4 1 4 0 4',
'lot PUNC lot XXX lot',

# Note: Estonian treebank is originally constituent-based.
# "Original" dependency style is thus what we created during conversion.
'et' => 'praha' =>
'õunad , apelsinid ja sidrunid',
'4 4 4 0 4',
'NR NR NR NR NR',

# Note: Romanian treebank does not include punctuation.
'ro' => 'praha-budapest' =>
'mere portocale şi lămâi',
'0 3 0 3',
'XXX rel.conj. XXX rel.conj.',

'zh' => 'taibei' =>
# pínguǒ , chéngzǐ hé níngméng
'蘋果 ， 橙子 和 檸檬',
'2 4 2 0 4',
'DUMMY1 DUMMY1 DUMMY2 DUMMY DUMMY2',
# according to 001.treex#161?
# Similar to nested coordination in Praguian style.
# But it seems that this is semantically a 3-member coordination rather than two nested structures.

'sv' => 'moskva' =>
'äpplen , apelsiner och citroner',
'0 3 1 5 3',
'XXX IK CC ++ CC',

'de' => 'moskva' =>
'Äpfel , Orangen und Zitronen',
'0 1 1 3 3',
'XXX PUNC CJ CD CJ',

'en' => 'moskva' =>
'apples , oranges and lemons',
'0 1 1 3 4',
'XXX P COORD COORD CONJ', #! second member and conjunction both have COORD!

# Note: Russian treebank does not include punctuation.
'ru' => 'moskva' =>
'яблоки апельсины и лимоны',
'0 1 2 3',
'XXX сочин сочин соч-союзн',

'tr' => 'moskvaR' =>
'elma , portakal ve limon',
'2 3 4 5 0',
'XXX COORDINATION XXX COORDINATION XXX',

'ja' => 'moskvaR' =>
# ringo to orendži to remon
'リンゴ と オレンジ と レモン',
'3 1 5 3 0',
'HD MRK HD MRK XXX',
# 001.treex#80:  2-member coordination, 'to' attached to following member
# 001.treex#165: 3-member coordination?, 'to' attached to previous member

'bg' => 'stanford' =>
'ябълки , портокали и лимони',
'0 1 1 1 1',
'XXX punct conjarg conj conjarg',

'pt' => 'stanford' =>
'maçãs , laranjas e limões',
'0 1 1 1 1',
'XXX PUNC CJT CO CJT',

'es' => 'stanford' =>
'manzanas, naranjas y limones',
'0 1 1 1 1',
'XXX f sn coord sn',

'ca' => 'stanford' =>
'pomes , taronges i llimones',
'0 1 1 1 1',
'XXX PUNC CONJUNCT CO CONJUNCT',

'it' => 'stanford' =>
'mele , arance e limoni',
'0 1 1 1 1',
'XXX con cong con cong',

'fi' => 'stanford' =>
'omenat , appelsiinit ja sitruunat',
'0 1 1 1 1',
'XXX punct conj cc conj',

'da' => 'stanford2' =>
'æbler , appelsiner og citroner',
'0 1 1 1 4',
'XXX pnct conj coord conj',

'hu' => 'budapest' =>
'alma , narancs és citrom' =>
'0 0 0 0 0',
'XXX PUNCT XXX CONJ XXX',

#is: epli, appelsínur og sítrónur
# Icelandic treebank has not been converted to Treex

);



my @samples = read_samples(@coord_sample);
# Print trees in CoNLL format.
foreach my $sample (@samples)
{
    my $i = 0;
    for($i = 0; $i<=$#{$sample->{forms}}; $i++)
    {
        print($i+1, "\t$sample->{forms}[$i]\t_\t_\t_\t_\t$sample->{links}[$i]\t$sample->{afuns}[$i]\t_\t_\n");
    }
    print($i+1, "\t$sample->{language}\t_\t_\t_\t_\t0\t$sample->{style}\t_\t_\n");
    print("\n");
}



sub read_samples
{
    my @input = @_;
    my @samples;
    for(my $i = 0; $i<=$#input; $i += 5)
    {
        my @forms = split(/\s+/, $input[$i+2]);
        my @links = split(/\s+/, $input[$i+3]);
        my @afuns = split(/\s+/, $input[$i+4]);
        my %record =
        (
            'language' => $input[$i],
            'style' => $input[$i+1],
            'forms' => \@forms,
            'links' => \@links,
            'afuns' => \@afuns
        );
        push(@samples, \%record);
    }
    return @samples;
}



#------------------------------------------------------------------------------
# Převede stromečky do LaTeXové notace.
#------------------------------------------------------------------------------
sub latex
{
    my @samples = @_;
    foreach my $sample (@samples)
    {
        # Vzorek má n uzlů, chybí prvek pro kořen a museli bychom neustále přepočítávat indexy.
        # Raději tedy nejdříve přidáme kořen s indexem 0.
        my @forms = @{$sample->{forms}};
        unshift(@forms, '');
        my @links = @{$sample->{links}};
        unshift(@links, -1);
        die if(scalar(@forms)!=scalar(@links));
        # Přepsat uzly do matice.
        # x-ová souřadnice uzlu je jeho pořadí ve větě.
        # y-ová souřadnice uzlu je jeho hloubka.
        my @depths;
        my @matrix;
        for(my $i = 0; $i<=$#links; $i++)
        {
            # Zjistit hloubku i-tého uzlu.
            my $h = 0;
            for(my $j = $i; $j>0; $j = $links[$j])
            {
                $h++;
            }
            $depths[$i] = $h;
            # Vypsat slovo.
            if($i>0)
            {
                $matrix[$i][$h] .= "\\K{$forms[$i]}";
                # Víme, že rodič má hloubku o 1 nižší, můžeme tedy rovnou vygenerovat i hranu od něj k nám.
                my $r = $links[$i];
                my $arc = 'd';
                # Jestliže je rodič napravo od nás, hrana povede doleva.
                if($r>$i)
                {
                    $arc .= join('', map {'l'} (0..($r-$i)));
                }
                # Jestliže je rodič nalevo od nás, hrana povede doprava.
                else
                {
                    $arc .= join('', map {'r'} (0..($i-$r)));
                }
                $matrix[$r][$h-1] .= "\\B{$arc}";
            }
        }
        # Matice je hotová, vypsat tabulku.
        print(join(" \\\\\n", map {join(' & ', @{$_})} (@matrix)), "\n");
    }
}
