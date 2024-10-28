#!/usr/bin/env perl
# Vytvoří statistiku víceslovných výrazů v souboru CoNLL.
# Copyright © 2016 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');

while(<>)
{
    next if(m/^\#/);
    my @fields = split(/\s+/, $_);
    if(scalar(@fields) > 1)
    {
        my $form = $fields[1];
        my $lemma = $fields[2];
        my $tag = $fields[3];
        if($form =~ m/[^_]_[^_]/)
        {
            $form = lc($form) if($tag =~ m/^AD[PV]|AUX|S?CONJ|DET|NOUN|PRON|VERB$/);
            $hash{$tag}{$form}++;
        }
    }
}
my @znacky = sort(keys(%hash));
my $num_re = '((un_quart|(dos|tres)_quarts)_de_)?(\d+|una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce|una|dues|dos|tres|quatre|cinc|sis|set|vuit|nou|dies|deu|onze|dotze)';
my $month_re = 'enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre|'.
    'gener|febrer|març|abril|maig|juny|juliol|agost|setembre|octubre|novembre|desembre|'.
    'janeiro|fevereiro|março|abril|maio|junho|julho|agosto|setembro|outubro|novembro|dezembro';
my $dow_re = 'lunes|martes|miércoles|jueves|viernes|sábado|domingo|'.
    'dilluns|dimarts|dimecres|dijous|divendres|dissabte|diumenge';
my $timespec = 'gmt|de_la_mañana|de_la_tarde|de_la_noche|del_matí|de_la_matinada|del_migdia|de_la_tarda|del_vespre|de_la_nit';
my $ap = "'";
foreach my $znacka (@znacky)
{
    my @vyrazy = sort(keys(%{$hash{$znacka}}));
    foreach my $vyraz (@vyrazy)
    {
        # Classify the multi-word expressions.
        if($vyraz =~ m/^[-+0-9,.']+_(per_cent|por_ciento|%)$/) #'
        {
            $typy{percent}++;
        }
        elsif($vyraz =~ m/^(${num_re})([.:,]\d+)?_(hor[ae]s|(hor[ae]s_)?(${timespec}))$/i ||
              $vyraz =~ m/$dow_re/i ||
              $vyraz =~ m/^((d[íi]a_)?\d+_d[e${ap}]_)?${month_re}(_del?_\d+|_pasado)?$/i ||
              $vyraz =~ m/^(${month_re}_de_)?(año|any)s?_(\d+|pasado|próximo)$/i ||
              $vyraz =~ m/^(d[íi]a|dies)_\d+$/i ||
              $vyraz =~ m/^(siglo|segle)_[ivx]+$/i)
        {
            $typy{datetime}++;
        }
        elsif($znacka eq 'ADJ')
        {
            $typy{adjective}++;
        }
        elsif($znacka eq 'ADP')
        {
            $typy{adposition}++;
        }
        # Multi-word auxiliary verbs do not exist, these are annotation errors.
        # We do not what they are but we do not want to keep AUX, so we will put them under ADV.
        elsif($znacka =~ m/^ADV|AUX$/)
        {
            $typy{adverb}++;
        }
        elsif($znacka eq 'CONJ')
        {
            $typy{conjunction}++;
        }
        elsif($znacka eq 'SCONJ')
        {
            $typy{subjunction}++;
        }
        elsif($znacka =~ m/^DET|NUM|PRON$/)
        {
            $typy{determiner}++;
        }
        elsif($znacka eq 'INTJ')
        {
            $typy{interjection}++;
        }
        elsif($znacka eq 'NOUN')
        {
            $typy{noun}++;
        }
        elsif($znacka eq 'PROPN')
        {
            my @words = split(/_/, $vyraz);
            # The simplest structure: no function words.
            # None of the words starts with a lowercase letter.
            # Also, there is no article (it could be the first word and thus capitalized, hence we must enumerate them).
            my @fw = grep {m/^(el|la|los|las|l${ap}|els|os?|as?|u[nm]a?)$/i || lc($_) eq $_} (@words);
            if(scalar(@fw)==0)
            {
                $typy{propn_flat_name}++;
            }
            elsif(scalar(@fw)==1 && scalar(@words)==3 && $words[1] =~ m/^(de|d${ap}|dels?|dos?|das?)$/i)
            {
                $typy{propn_x_de_y}++;
            }
            else
            {
                $typy{propn}++;
                print("$vyraz\t$znacka\t$hash{$znacka}{$vyraz}\n");
            }
        }
        elsif($znacka eq 'VERB')
        {
            $typy{verb}++;
        }
        else
        {
            print("$vyraz\t$znacka\t$hash{$znacka}{$vyraz}\n");
            $typy{unknown}++;
        }
    }
}
