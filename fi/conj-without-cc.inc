my $punct = qr%^[-,:\x{2013}\x{2212}/;]$%;
if ("conj" eq $anode->conll_deprel) {
    my $adept = $anode->lbrother;
    if (! ref $adept
            or "cc" ne $adept->conll_deprel
            and $adept->lemma !~ $punct) {
        $adept = $anode->firstson;
        unless ($adept and $adept->lemma =~ $punct) {
            $adept = $anode->lbrother;
            if ($adept) {
                $adept = ($adept->children)[-1];
            }
            undef $adept if $adept and $adept->lemma !~ $punct;
        }
    }
    print "No adept\t", $anode->get_address, "\n" unless ref $adept;
}
