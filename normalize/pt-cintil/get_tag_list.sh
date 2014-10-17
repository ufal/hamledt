perl -CSDA -e 'while(<>){next if(m/^\s*$/); my @f=split(/\t/, $_); my $tag = "$f[3]\t$f[4]\t$f[5]"; $map{$tag}++;} my @labels = sort keys %map; foreach my $l (@labels) {print "$l\t$map{$l}\n";}' < Cintil2USD.conll

