#!/usr/bin/env perl
# Last modified: Sun Jul 27 2025 05:54:26 PM -04:00 [EDT]
# First created: Thu Jul 24 2025 12:47:02 PM -04:00 [EDT]
use strict;
use v5.18;
use utf8;
use warnings;

our (@Bare, @Wanted);
# ---------------------- ### ---------------------- #
BEGIN {
  @Wanted = map { push @Bare=> $_; q%@% .$_ } grep {
                   $_ eq "PERL5LIB"
                   || /[_A-Z0-9]*PATH$/ } sort keys %ENV;
  eval "use Env qw/@Wanted/ ;";
}
# ---------------------- ### ---------------------- #
=head1 SYNOPSIS

Use as a modulino by executing this file directly (perl EnvPath_2yaml.pm).
Or write code that uses the subroutines and include this module by the
common syntax of C<-MEnvPath_2yaml>.

=cut

{
    package Env_Path_2yaml; 

    our @EXPORT = qw/ PathToYaml /;
    use Exporter;
    our @ISA = qw/ Exporter /;

# @PATH is same as "split $Config::Config{path_sep}, $PATH;"
    sub PathToYaml {
        my $Key = shift;
        my @pathels = @_;
        my $header = qq[$Key]  . qq[:\n];
        my @listing = map { qq[  - $_\n] } @pathels;
     #  print $header, @listing;
        unshift( @listing, $header ) ;
        return \@listing; # Ready to load as YAML
    }

}  # // Env_Paths_2yaml::

if (!caller() and $0 eq __FILE__)
{
   sub ::main {
     use YAML::Any;
     use Data::Dump::Color;
#    my @ko = @Env_Paths_2yaml::Wanted;
# Its messy to hard-code it this way but this stuff in my env is just in the way:
     @Bare = grep { $_ ne 'ORIGINAL_PATH'
                 && $_ ne 'AMDRMSDKPATH'
                 && $_ ne 'HOMEPATH' } @Bare;

  #  say q[---]; # Beginning of document.
     my ($accumulator, $documents);
  #  my $stff = Env_Paths_2yaml::ToYaml( 'INFOPATH' => @INFOPATH );
     for my $kstr ( @Bare ) {
         no strict 'refs'; # a symbolic reference below:
         my $seq = Env_Path_2yaml::PathToYaml( $kstr, @{$kstr} );
         my $yaml_segment = join q[]=> @$seq;
         push @$documents => $yaml_segment;
         $accumulator .= qq[\n---\n] . $yaml_segment;
     }

   # Let's see the YAML
     print $accumulator;
   # Load YAML here
     for my $doc (@$documents) {
         my $y = Load( $doc );
   # Add a blank line and Dump the YAML as perl data in color
         say '';
         dd ($y);
     }
  }
  ::main();
} else { 1; }
__END__

# vim: ft=perl et sw=4 ts=4 :
