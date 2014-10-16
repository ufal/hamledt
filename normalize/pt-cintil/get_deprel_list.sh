perl -CSDA -e 'while(<>){next if(m/^\s*$/); my @f=split(/\t/, $_); $map{$f[7]}++;} my @labels = sort keys %map; foreach my $l (@labels) {print "$l\t$map{$l}\n";}' < Cintil2USD.conll

