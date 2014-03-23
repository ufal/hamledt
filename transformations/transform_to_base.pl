#!/usr/bin/env perl

use strict;
use warnings;
use Treex::Core::Config;

my $langs_wildcard = '{' . join(',', @ARGV) . '}';
my $JOBS= 5 * @ARGV;

my $data_dir = Treex::Core::Config->share_dir()."/data/resources/hamledt";

my $command_line = "treex -p -j $JOBS "
     . "A2A::BackupTree to_selector=hamledt "
     . "HamleDT::DeleteAfunCoordWithoutMembers "                                # TODO this should be done already within the normalization.
     . "HamleDT::SetSharedModifier "                                            # Attributes is_shared_modifier and wild->is_coord_conjunction
     . "HamleDT::SetCoordConjunction "                                          # must be filled before running the transformation.
     . "HamleDT::Transform::CoordStyle from_style=fPhRsHcHpB style=fMhLsNcBpP " # Transform the zone with empty selector.
     . "HamleDT::Transform::CoordStyle from_style=fMhLsNcBpP style=fPhRsHcHpB " # Transform the zone with empty selector.
#     . "HamleDT::Transform::CoordStyle from_style=fPhRsHcHpB style=fPhRsHcHpB " # Transform the zone with empty selector.
     . "Write::Treex substitute={001_pdtstyle}{002_base} "                 # Save the resulting treex files to a new directory.      
     . "-- '!$data_dir/$langs_wildcard/treex/001_pdtstyle/t*/*.treex.gz'";  # Input files.

system $command_line;
