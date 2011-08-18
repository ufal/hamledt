my $punct = qr%^[-,:\x{2013}\x{2212}/;]$%;
if ("conj" eq $anode->conll_deprel
    and not grep "cc" eq $_->conll_deprel,
        $anode->parent->children) {
    my $bad;
    my $adept = $anode;
    $adept = $adept->lbrother while $adept
        and $adept !~ $punct
        and ($adept == $anode
             or "conj" eq $adept->conll_deprel);
    unless ($adept) {
        ($adept) = grep $_->lemma =~ $punct,
            $anode->children;
    }
    print $anode->get_address, "\n" unless $adept;
}
