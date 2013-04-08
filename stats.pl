#!/usr/bin/perl

# Cameron Bulock (cbulock@liquidweb.com) 3/20/2013 

use warnings;
use strict;
use Net::SNMP;
use Getopt::Long;

my $help = 0;
my @opt = ('CPU', 'RAM', 'Processes');

if ( @ARGV > 0 ) {
 GetOptions(
  'help|?'	=> \$help
 )
}
if ( $help ) {
 print "Usage: perl stats.pl [item]\n\n";
 print 'Item can be one of these values: ';
 my $values = '';
 foreach (@opt) {
  $values = $values . $_ . ", ";
 }
 $values =~ s/, +$//; 
 print $values;
 print "\n";
 exit 1;
}

if ( $ARGV[0] ) {
 @opt = ();
 push(@opt, $ARGV[0]);
}

my %services = (
 'CPU', '.1.3.6.1.2.1.25.3.2.1.3.768',
 'RAM', '.1.3.6.1.2.1.25.2.3.1.5.1',
 'Processes', '.1.3.6.1.2.1.25.1.6.0'
);

my @servicelist = ();
foreach (@opt) {
 push (@servicelist, $services{$_});
}

my ($session, $error) = Net::SNMP->session(
 -hostname  => $hostname,
 -community => $community
);

if (!defined $session) {
 printf "ERROR: %s.\n", $error;
 exit 1;
}

my $result = $session->get_request(-varbindlist => \@servicelist);

if (!defined $result) {
 printf "ERROR: %s.\n", $session->error();
 $session->close();
 exit 1;
}

foreach (@opt) {
 my $append = '';
 if ($_ eq 'RAM') {$append = 'K'};
 printf $_.": \t%s".$append." \n", $result->{$services{$_}};
}

exit 1;
