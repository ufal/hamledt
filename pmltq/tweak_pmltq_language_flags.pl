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
# Common style for all language subclasses.
my $langall = '{background-image:url(24c3ea8e1c7e63e7cebcdc15ebaa3873.png);background-repeat:no-repeat}';

# All languages for which the system currently knows flags. Note that there may
# be languages that are not yet registered in the UD infrastructure.
my $langstyles0 = '.lang.ab,.lang.af,.lang.aii,.lang.ajp,.lang.akk,.lang.am,.lang.apu,.lang.aqz,.lang.ar,.lang.as,.lang.az,.lang.ba,.lang.be,.lang.bg,.lang.bho,.lang.bm,.lang.bn,.lang.bo,.lang.br,.lang.bxr,.lang.ca,.lang.ce,.lang.ckb,.lang.ckt,.lang.co,.lang.cop,.lang.cs,.lang.cu,.lang.cv,.lang.cy,.lang.da,.lang.dar,.lang.de,.lang.dsb,.lang.el,.lang.en,.lang.eo,.lang.es,.lang.et,.lang.eu,.lang.fa,.lang.fi,.lang.fo,.lang.fr,.lang.fro,.lang.fy,.lang.ga,.lang.gd,.lang.gl,.lang.got,.lang.grc,.lang.gsw,.lang.gu,.lang.gun,.lang.hak,.lang.he,.lang.hi,.lang.hr,.lang.hsb,.lang.hu,.lang.hy,.lang.id,.lang.is,.lang.it,.lang.ja,.lang.ka,.lang.kaa,.lang.kfm,.lang.kk,.lang.km,.lang.kmr,.lang.kn,.lang.ko,.lang.koi,.lang.kpv,.lang.krl,.lang.ks,.lang.ky,.lang.la,.lang.lb,.lang.lo,.lang.lt,.lang.lv,.lang.lzh,.lang.mdf,.lang.mk,.lang.ml,.lang.mn,.lang.mr,.lang.mt,.lang.my,.lang.myu,.lang.myv,.lang.ne,.lang.nl,.lang.nn,.lang.no,.lang.nyq,.lang.oc,.lang.olo,.lang.or,.lang.orv,.lang.os,.lang.otk,.lang.pa,.lang.pbv,.lang.pcm,.lang.pl,.lang.ps,.lang.pt,.lang.qhe,.lang.qtd,.lang.rm,.lang.rmn,.lang.ro,.lang.ru,.lang.sa,.lang.sah,.lang.sc,.lang.sd,.lang.shp,.lang.sk,.lang.sl,.lang.sme,.lang.sms,.lang.so,.lang.soj,.lang.sq,.lang.sr,.lang.sv,.lang.sw,.lang.swl,.lang.ta,.lang.te,.lang.tg,.lang.th,.lang.tk,.lang.tl,.lang.tpn,.lang.tr,.lang.tt,.lang.ug,.lang.uk,.lang.ur,.lang.uz,.lang.vi,.lang.wbp,.lang.wo,.lang.xal,.lang.yi,.lang.yo,.lang.yue,.lang.zh';
# Individual styles for the currently known languages.
my $langstyles00 = '.lang.grc{background-position:-109px 0}.lang.grc,.lang.yue{width:17px;height:11px}.lang.yue{background-position:-151px -11px}.lang.tt{background-position:-239px -88px;width:22px;height:11px}.lang.br{background-position:-77px -11px;width:17px;height:11px}.lang.myv{background-position:-139px -22px}.lang.kk,.lang.myv{width:22px;height:11px}.lang.kk{background-position:-112px -44px}.lang.be{background-position:-20px -11px;width:22px;height:11px}.lang.gl{background-position:0 -33px}.lang.fro,.lang.gl{width:17px;height:11px}.lang.fro{background-position:-107px -66px}.lang.bn{background-position:-42px -11px;width:18px;height:11px}.lang.cop{background-position:0 -22px;width:11px;height:11px}.lang.eu{background-position:0 -11px;width:20px;height:11px}.lang.orv{background-position:-124px -66px;width:21px;height:11px}.lang.he{background-position:-114px -33px;width:15px;height:11px}.lang.kmr{background-position:-221px -44px}.lang.kmr,.lang.tr{width:17px;height:11px}.lang.tr{background-position:-51px -99px}.lang.ab{background-position:0 0}.lang.ab,.lang.xal{width:22px;height:11px}.lang.xal{background-position:-17px -44px}.lang.qhe{background-position:-146px -33px}.lang.qhe,.lang.sd{width:17px;height:11px}.lang.sd{background-position:-199px -77px}.lang.zh{background-position:-202px -11px;width:17px;height:11px}.lang.tpn{background-position:-35px -99px;width:16px;height:11px}.lang.kfm{background-position:-151px -44px;width:19px;height:11px}.lang.sah{background-position:0 -110px;width:22px;height:11px}.lang.ky{background-position:-238px -44px;width:18px;height:11px}.lang.ne{background-position:-19px -66px;width:9px;height:11px}.lang.hy{background-position:-159px 0;width:22px;height:11px}.lang.id{background-position:-200px -33px;width:17px;height:11px}.lang.wbp{background-position:-210px -99px;width:22px;height:11px}.lang.lt{background-position:-33px -55px}.lang.lt,.lang.mdf{width:18px;height:11px}.lang.mdf{background-position:-197px -55px}.lang.hr{background-position:-29px -22px;width:22px;height:11px}.lang.apu{background-position:-126px 0;width:16px;height:11px}.lang.gd{background-position:-147px -77px;width:18px;height:11px}.lang.af{background-position:-22px 0}.lang.af,.lang.gu{width:17px;height:11px}.lang.gu{background-position:-80px -33px}.lang.ar{background-position:-142px 0}.lang.ar,.lang.nl{width:17px;height:11px}.lang.nl{background-position:-100px -22px}.lang.oc{background-position:-73px -66px}.lang.oc,.lang.pa{width:17px;height:11px}.lang.pa{background-position:-35px -77px}.lang.akk{background-position:-39px 0}.lang.akk,.lang.koi{width:17px;height:11px}.lang.koi{background-position:-170px -44px}.lang.os{background-position:-179px -66px;width:22px;height:11px}.lang.ks{background-position:-95px -44px;width:17px;height:11px}.lang.hsb{background-position:-119px -99px;width:18px;height:11px}.lang.bxr{background-position:-129px -11px;width:22px;height:11px}.lang.kpv{background-position:-187px -44px;width:17px;height:11px}.lang.is{background-position:-185px -33px}.lang.is,.lang.yi{width:15px;height:11px}.lang.yi{background-position:-22px -110px}.lang.la{background-position:0 -55px;width:11px;height:11px}.lang.fy{background-position:-245px -22px}.lang.fy,.lang.so{width:17px;height:11px}.lang.so{background-position:-41px -88px}.lang.no{background-position:-43px -66px;width:15px;height:11px}.lang.soj{background-position:-22px -88px;width:19px;height:11px}.lang.rm{background-position:-86px -77px;width:11px;height:11px}.lang.tl{background-position:-178px -88px;width:22px;height:11px}.lang.cy{background-position:-232px -99px}.lang.cy,.lang.pbv{width:17px;height:11px}.lang.pbv{background-position:-237px -66px}.lang.uz{background-position:-171px -99px;width:22px;height:11px}.lang.ko{background-position:-204px -44px}.lang.ko,.lang.ps{width:17px;height:11px}.lang.ps{background-position:-201px -66px}.lang.bo{background-position:-17px -99px;width:18px;height:11px}.lang.ba{background-position:-254px 0;width:17px;height:11px}.lang.pl{background-position:0 -77px;width:18px;height:11px}.lang.eo{background-position:-161px -22px;width:17px;height:11px}.lang.gun{background-position:-177px -55px;width:20px;height:11px}.lang.tk{background-position:-85px -99px;width:17px;height:11px}.lang.cv{background-position:-236px -11px}.lang.cv,.lang.swl{width:18px;height:11px}.lang.swl{background-position:-149px -88px}.lang.cu{background-position:-90px -66px;width:17px;height:11px}.lang.tg{background-position:-200px -88px;width:22px;height:11px}.lang.sc{background-position:-131px -77px;width:16px;height:11px}.lang.km{background-position:-134px -44px}.lang.as,.lang.km{width:17px;height:11px}.lang.as{background-position:-181px 0}.lang.dar{background-position:-83px -22px;width:17px;height:11px}.lang.en{background-position:-117px -22px;width:22px;height:11px}.lang.kn{background-position:-39px -44px}.lang.ce,.lang.kn{width:17px;height:11px}.lang.ce{background-position:-185px -11px}.lang.ml{background-position:-126px -55px;width:17px;height:11px}.lang.sv{background-position:-131px -88px;width:18px;height:11px}.lang.shp{background-position:-182px -77px}.lang.rmn,.lang.shp{width:17px;height:11px}.lang.rmn{background-position:-52px -77px}.lang.or{background-position:-162px -66px}.lang.ka,.lang.or{width:17px;height:11px}.lang.ka{background-position:-17px -33px}.lang.qtd{background-position:-68px -99px}.lang.lzh,.lang.qtd{width:17px;height:11px}.lang.lzh{background-position:-254px -11px}.lang.mt{background-position:-143px -55px;width:17px;height:11px}.lang.sms{background-position:-216px -77px;width:15px;height:11px}.lang.mn{background-position:-215px -55px;width:22px;height:11px}.lang.it{background-position:-239px -33px;width:17px;height:11px}.lang.dsb{background-position:-68px -55px;width:18px;height:11px}.lang.myu{background-position:-237px -55px;width:16px;height:11px}.lang.nyq{background-position:0 -66px;width:19px;height:11px}.lang.ru{background-position:-97px -77px;width:17px;height:11px}.lang.pcm{background-position:-253px -55px;width:22px;height:11px}.lang.th{background-position:0 -99px;width:17px;height:11px}.lang.ajp{background-position:-75px -88px;width:22px;height:11px}.lang.sq{background-position:-72px 0;width:15px;height:11px}.lang.ckb{background-position:-58px -88px}.lang.ckb,.lang.el{width:17px;height:11px}.lang.el{background-position:-63px -33px}.lang.te{background-position:-261px -88px;width:17px;height:11px}.lang.fo{background-position:-195px -22px;width:15px;height:11px}.lang.mk{background-position:-104px -55px;width:22px;height:11px}.lang.sk{background-position:-231px -77px}.lang.bm,.lang.sk{width:17px;height:11px}.lang.bm{background-position:-237px 0}.lang.et{background-position:-178px -22px}.lang.et,.lang.my{width:17px;height:11px}.lang.my{background-position:-112px -11px}.lang.fa{background-position:-218px -66px;width:19px;height:11px}.lang.co{background-position:-11px -22px;width:18px;height:11px}.lang.cs{background-position:-51px -22px}.lang.bho,.lang.cs{width:17px;height:11px}.lang.bho{background-position:-60px -11px}.lang.ta{background-position:-222px -88px;width:17px;height:11px}.lang.sl{background-position:0 -88px;width:22px;height:11px}.lang.lo{background-position:-256px -44px}.lang.ckt,.lang.lo{width:17px;height:11px}.lang.ckt{background-position:-219px -11px}.lang.hu{background-position:-163px -33px;width:22px;height:11px}.lang.uk{background-position:-102px -99px;width:17px;height:11px}.lang.yo{background-position:-37px -110px;width:22px;height:11px}.lang.de{background-position:-34px -33px;width:18px;height:11px}.lang.nn{background-position:-58px -66px;width:15px;height:11px}.lang.ga{background-position:-217px -33px}.lang.az,.lang.ga{width:22px;height:11px}.lang.az{background-position:-215px 0}.lang.sme{background-position:-28px -66px;width:15px;height:11px}.lang.olo{background-position:-51px -55px;width:17px;height:11px}.lang.lb{background-position:-86px -55px;width:18px;height:11px}.lang.ca{background-position:-168px -11px}.lang.ca,.lang.krl{width:17px;height:11px}.lang.krl{background-position:-78px -44px}.lang.hi{background-position:-129px -33px;width:17px;height:11px}.lang.kaa{background-position:-56px -44px}.lang.kaa,.lang.lv{width:22px;height:11px}.lang.lv{background-position:-11px -55px}.lang.fr{background-position:-228px -22px}.lang.fr,.lang.mr{width:17px;height:11px}.lang.mr{background-position:-160px -55px}.lang.ro{background-position:-69px -77px}.lang.pt,.lang.ro{width:17px;height:11px}.lang.pt{background-position:-18px -77px}.lang.hak{background-position:-97px -33px}.lang.aii,.lang.hak{width:17px;height:11px}.lang.aii{background-position:-198px 0}.lang.am{background-position:-87px 0;width:22px;height:11px}.lang.vi{background-position:-193px -99px;width:17px;height:11px}.lang.gsw{background-position:-167px -88px;width:11px;height:11px}.lang.bg{background-position:-94px -11px;width:18px;height:11px}.lang.ug{background-position:-154px -99px;width:17px;height:11px}.lang.aqz{background-position:-56px 0;width:16px;height:11px}.lang.otk{background-position:-145px -66px}.lang.otk,.lang.wo{width:17px;height:11px}.lang.wo{background-position:-249px -99px}.lang.sa{background-position:-114px -77px}.lang.sa,.lang.ur{width:17px;height:11px}.lang.ur{background-position:-137px -99px}.lang.da{background-position:-68px -22px;width:15px;height:11px}.lang.sw{background-position:-114px -88px;width:17px;height:11px}.lang.fi{background-position:-210px -22px;width:18px;height:11px}.lang.got{background-position:-52px -33px;width:11px;height:11px}.lang.es{background-position:-97px -88px}.lang.es,.lang.sr{width:17px;height:11px}.lang.sr{background-position:-165px -77px}.lang.ja{background-position:0 -44px;width:17px;height:11px}';

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

# Parse the individual styles copied from the original file.
my $langstyles = parse_styles($langstyles00);

# For languages that are known in UD, label the styles by country/flag codes.
my @lcodes = sort(keys(%{$udlanguages}));
my %flags;
foreach my $lcode (@lcodes)
{
    my $fcode = $udlanguages->{$lcode}{flag};
    if(!exists($flags{$fcode}) && exists($langstyles->{$lcode}))
    {
        $flags{$fcode} = $langstyles->{$lcode};
    }
}
# For languages that are known in UD but did not have a style so far, check
# whether the flag has its style because of another language.
foreach my $lcode (@lcodes)
{
    my $fcode = $udlanguages->{$lcode}{flag};
    if(exists($flags{$fcode}) && !exists($langstyles->{$lcode}))
    {
        $langstyles->{$lcode} = $flags{$fcode};
        my $filler = length($lcode) == 2 ? ' ' : '';
        print("NEW '$lcode'$filler => '$langstyles->{$lcode}',\n");
    }
}
# Group languages that have the same flag.
my %styles;
my @styles;
my @lcodes = sort(keys(%{$langstyles}));
foreach my $lcode (@lcodes)
{
    my $style = $langstyles->{$lcode};
    if(!exists($styles{$style}))
    {
        push(@styles, $style);
    }
    push(@{$styles{$style}}, $lcode);
}
# Compile the final style string.
my $stylestring = $lang;
$stylestring .= join(',', map {'.lang.'.$_} (@lcodes)).$langall;
foreach my $style (@styles)
{
    $stylestring .= join(',', map {'.lang.'.$_} (@{$styles{$style}})).'{'.$style.'}';
}
print("$stylestring\n");
# Modify the style file.
my $stylefile = '067a15c7538a679f56989044170937c9-admin.css';
if(-f $stylefile)
{
    my $sfcontent;
    open(SF, $stylefile) or die("Cannot read '$stylefile': $!");
    while(<SF>)
    {
        chomp;
        if(s/\.lang.*//)
        {
            $_ .= $stylestring;
        }
        $sfcontent .= $_."\n";
    }
    close(SF);
    open(SF, ">$stylefile") or die("Cannot write '$stylefile': $!");
    print SF ($sfcontent);
    close(SF);
}



#------------------------------------------------------------------------------
# Parses language flag styles from a CSS string. Returns a hash indexed by
# language codes, where the value is a style string (semicolon-separated, no
# curly brackets around).
#------------------------------------------------------------------------------
sub parse_styles
{
    my $css = shift; # should contain only .lang or .lang.xx, the style in {}, and nothing else (not even extra spaces or line breaks)
    my @current_languages;
    my %langstyles;
    while($css ne '')
    {
        if($css =~ s/^\.lang\.([a-z]+)//)
        {
            push(@current_languages, $1);
        }
        elsif($css =~ s/^,//)
        {
            # Do nothing.
        }
        elsif($css =~ s/^\{(.*?)\}//)
        {
            my $style = $1;
            foreach my $l (@current_languages)
            {
                push(@{$langstyles{$l}}, $style);
            }
            @current_languages = ();
        }
        else
        {
            die("Cannot parse '$css'");
        }
    }
    my @lcodes = sort(keys(%langstyles));
    foreach my $lcode (@lcodes)
    {
        my $style = join(';', sort {$a =~ m/^width/i && $b =~ m/^height/i ? -1 : $a =~ m/^height/i && $b =~ m/^width/i ? 1 : $a cmp $b} (split(/;/, join(';', @{$langstyles{$lcode}}))));
        #my $filler = length($lcode) == 2 ? ' ' : '';
        #print("    '$lcode'$filler => '$style',\n");
        $langstyles{$lcode} = $style;
    }
    return \%langstyles;
}
