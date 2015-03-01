#!/usr/bin/perl -T
#loldns number generator

use warnings;
use strict;

if ($#ARGV != 2)
{
	print<<EOU;
Usage: ./generate.pl hostname first-ip number > data
In the hostname, a # will represent your number
eg ./generate.pl static#lolware.net 192.168.0.1 24
EOU
exit;
}

my $host = $ARGV[0];
my $ip = $ARGV[1];
my $number = $ARGV[2];


for(my $i = 1; $i<=$number; $i++)
{
	my $tmp = $host;
	$tmp =~ s/#/$i/;
	$tmp = "=$tmp:$ip\n";
	die "Invalid IP" unless $ip =~ m/^(.*\.)(\d+)$/;
	$ip = $1  . ($2+1);
	print $tmp;
}

