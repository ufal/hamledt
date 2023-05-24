#!/usr/bin/env perl
# Hacks the flags at the PML-TQ server.
# Copyright © 2023 Dan Zeman <zeman@ufal.mff.cuni.cz>
# License: GNU GPL

use utf8;
use open ':utf8';
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');
binmode(STDERR, ':utf8');
use Getopt::Long;
use udlib;

sub usage
{
    print STDERR ("Usage: $0 --udlanguages \$(UDPATH)/docs-automation/codes_and_flags.yaml\n");
}

my $udlanglistpath;
GetOptions
(
    'udlanguages=s' => \$udlanglistpath
);
if(!defined($udlanglistpath))
{
    usage();
    die("Unknown path to the YAML file with UD languages");
}

# 2023-05-24: I found the relevant files at the following locations. I verified
# that modifying them really projects to the presentation of the flags on the
# web. What I don't know is whether these files may get overwritten automatically
# during some regular events on the server. We will see.

# The bitmap file that contains all the flags:
# https://lindat.mff.cuni.cz/services/pmltq/24c3ea8e1c7e63e7cebcdc15ebaa3873.png
# /opt/pmltq-web/24c3ea8e1c7e63e7cebcdc15ebaa3873.png

# The stylesheet that maps languages to particular areas of the bitmap:
# https://lindat.mff.cuni.cz/services/pmltq/067a15c7538a679f56989044170937c9-admin.css
# /opt/pmltq-web/067a15c7538a679f56989044170937c9-admin.css
# (The relevant styles are defined on the penultimate line of the file.)
# Note that this file is accompanied by another file,
# /opt/pmltq-web/067a15c7538a679f56989044170937c9-admin.css.map
# but I don't think the other file is important for us.

# Main .lang style.
my $lang = '.lang{display:inline-block;vertical-align:baseline;margin:0 .5em 0 0;text-decoration:inherit;speak:none;font-smoothing:antialiased;-webkit-backface-visibility:hidden;backface-visibility:hidden}';

# All languages for which the system currently knows flags. Note that there may
# be languages that are not yet registered in the UD infrastructure. (Full
# disclosure: I added manually .hyw, .aln and .hit, only then I copied the list.)
my $langstyles0 = '.lang.ab,.lang.af,.lang.aii,.lang.ajp,.lang.akk,.lang.am,.lang.apu,.lang.aqz,.lang.ar,.lang.as,.lang.az,.lang.ba,.lang.be,.lang.bg,.lang.bho,.lang.bm,.lang.bn,.lang.bo,.lang.br,.lang.bxr,.lang.ca,.lang.ce,.lang.ckb,.lang.ckt,.lang.co,.lang.cop,.lang.cs,.lang.cu,.lang.cv,.lang.cy,.lang.da,.lang.dar,.lang.de,.lang.dsb,.lang.el,.lang.en,.lang.eo,.lang.es,.lang.et,.lang.eu,.lang.fa,.lang.fi,.lang.fo,.lang.fr,.lang.fro,.lang.fy,.lang.ga,.lang.gd,.lang.gl,.lang.got,.lang.grc,.lang.gsw,.lang.gu,.lang.gun,.lang.hak,.lang.he,.lang.hi,.lang.hr,.lang.hsb,.lang.hu,.lang.hy,.lang.hyw,.lang.id,.lang.is,.lang.it,.lang.ja,.lang.ka,.lang.kaa,.lang.kfm,.lang.kk,.lang.km,.lang.kmr,.lang.kn,.lang.ko,.lang.koi,.lang.kpv,.lang.krl,.lang.ks,.lang.ky,.lang.la,.lang.lb,.lang.lo,.lang.lt,.lang.lv,.lang.lzh,.lang.mdf,.lang.mk,.lang.ml,.lang.mn,.lang.mr,.lang.mt,.lang.my,.lang.myu,.lang.myv,.lang.ne,.lang.nl,.lang.nn,.lang.no,.lang.nyq,.lang.oc,.lang.olo,.lang.or,.lang.orv,.lang.os,.lang.otk,.lang.pa,.lang.pbv,.lang.pcm,.lang.pl,.lang.ps,.lang.pt,.lang.qhe,.lang.qtd,.lang.rm,.lang.rmn,.lang.ro,.lang.ru,.lang.sa,.lang.sah,.lang.sc,.lang.sd,.lang.shp,.lang.sk,.lang.sl,.lang.sme,.lang.sms,.lang.so,.lang.soj,.lang.sq,.lang.aln,.lang.sr,.lang.sv,.lang.sw,.lang.swl,.lang.ta,.lang.te,.lang.tg,.lang.th,.lang.tk,.lang.tl,.lang.tpn,.lang.tr,.lang.hit,.lang.tt,.lang.ug,.lang.uk,.lang.ur,.lang.uz,.lang.vi,.lang.wbp,.lang.wo,.lang.xal,.lang.yi,.lang.yo,.lang.yue,.lang.zh';

# Get the list of languages known in UD.
my $udlanguages = udlib::get_language_hash_by_lcodes($udlanglistpath);

my @lcodes0 = map {m/^\.lang\.([a-z]+)$/; $1} (split(/,/, $langstyles0));
foreach my $lcode (@lcodes0)
{
    if(!exists($udlanguages->{$lcode}))
    {
        print("$lcode\n");
    }
}
