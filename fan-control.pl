#!/usr/bin/perl
# Provide fan curve to hit a specific degree heat target
#
use strict;
use Term::ANSIColor qw(colored);

my %gpu;
my $targettemp=68;

my @listgpus = `lspci | grep VGA`;
my $gpucount = scalar @listgpus -1;
my $columns = `tput cols`;
# How many 17 characters fit the width of the terminal window?
my $gpusperrow = int($columns/17);

start:

my @fanspeeds = `nvidia-settings -q all | grep TargetFanSpeed  | grep fan: | awk {'print $3 $4'} | cut -d: -f3,4`;

my @gputemps = `nvidia-settings -q all | grep GPUCoreTemp | grep gpu: | awk {'print $3 $4'} | cut -d: -f3,4`;

if ( $#fanspeeds != $gpucount ) { die "Didn't find any GPUs!\n"; }

for my $fans ( @fanspeeds ) {
	if ( $fans =~ m/(\d+)\]\)\: (\d+)/ ) {
		#print $1."=".$2."\n";
		my $gpu = "gpu:".$1;
		$gpu{$gpu}{fanpercentage} = $2;
	}
}
for my $temps ( @gputemps ) {
	if ( $temps =~ m/(\d+)\]\)\: (\d+)/ ) {
		#print $1."=".$2."\n";
		my $gpu = "gpu:".$1;
		$gpu{$gpu}{temperature} = $2;
	}
}

my $columnscounter=1;
for (my $i=0; $i<=$gpucount; $i++){
	my $gpu = "gpu:".$i;
	my $fan = "fan:".$i;
	my $changevalue=1;
	my $tempdiff = $gpu{$gpu}{temperature} - $targettemp;

	my $out = sprintf( "%s[", $gpu);
	if ( $tempdiff > 1) { # Colder than target temp
		if ( $tempdiff > 2 ) { $changevalue=2; }
		if ( $tempdiff > 5 ) { $changevalue=5; }
		if ( $tempdiff > 10 ) { $changevalue=10; }
		if ( $tempdiff > 20 ) { $changevalue=20; }
		if ( $tempdiff > 30 ) { $changevalue=30; }
		my $setfanpercentage = $gpu{$gpu}{fanpercentage}+$changevalue;
		if ( $setfanpercentage > 99 ) { $setfanpercentage=100; }
		`nvidia-settings -a [$fan]/GPUTargetFanSpeed=$setfanpercentage`;
		if ( $gpu{$gpu}{fanpercentage} > 79 ) {
			$out .= sprintf( "%s+%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'red'), $changevalue );
		} elsif ( $gpu{$gpu}{fanpercentage} > 69 ) {
			$out .= sprintf( "%s+%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'yellow'), $changevalue );
		} else { 
			$out .= sprintf( "%s+%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'green'), $changevalue );
		}
		if ( $gpu{$gpu}{temperature} > 79 ) {
		       $out .= sprintf("%s] ", colored($gpu{$gpu}{temperature}.'C', 'red') );
		} elsif ( $gpu{$gpu}{temperature} > 69 ) {
		       $out .= sprintf("%s] ", colored($gpu{$gpu}{temperature}.'C', 'yellow') );
		} else { 
		       $out .= sprintf("%s] ", colored($gpu{$gpu}{temperature}.'C', 'green') );
		}
	} elsif ( $tempdiff < -1 ) { # Hotter than target temp
		if ( $tempdiff < -2 ) { $changevalue=2; }
		if ( $tempdiff < -5 ) { $changevalue=5; }
		if ( $tempdiff < -10 ) { $changevalue=10; }
		if ( $tempdiff < -20 ) { $changevalue=20; }
		if ( $tempdiff < -30 ) { $changevalue=30; }
		my $setfanpercentage = $gpu{$gpu}{fanpercentage}-$changevalue;
		if ( $setfanpercentage < 1 ) { $setfanpercentage=0; }
		`nvidia-settings -a [$fan]/GPUTargetFanSpeed=$setfanpercentage`;
		if ( $gpu{$gpu}{fanpercentage} > 79 ) {
			$out .= sprintf( "%s-%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'red'), $changevalue );
		} elsif ( $gpu{$gpu}{fanpercentage} > 69 ) {
			$out .= sprintf( "%s-%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'yellow'), $changevalue );
		} else { 
			$out .= sprintf( "%s-%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'green'), $changevalue );
		}
		if ( $gpu{$gpu}{temperature} > 79 ) {
		       $out .= sprintf( "%s] ", colored($gpu{$gpu}{temperature}.'C', 'red') );
		} elsif ( $gpu{$gpu}{temperature} > 69 ) {
		       $out .= sprintf( "%s] ", colored($gpu{$gpu}{temperature}.'C', 'yellow') );
		} else { 
		       $out .= sprintf( "%s] ", colored($gpu{$gpu}{temperature}.'C', 'green') );
		}
	} else { # No Fan changes needed
		if ( $gpu{$gpu}{fanpercentage} > 79 ) {
			$out .= sprintf( "%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'red') );
		} elsif ( $gpu{$gpu}{fanpercentage} > 69 ) {
			$out .= sprintf( "%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'yellow') );
		} else { 
			$out .= sprintf( "%s:", colored($gpu{$gpu}{fanpercentage}.'%', 'green') );
		}
		if ( $gpu{$gpu}{temperature} > 79 ) {
			$out .= sprintf( "%s] ", colored($gpu{$gpu}{temperature}.'C', 'red') );
		} elsif ( $gpu{$gpu}{temperature} > 69 ) {
			$out .= sprintf( "%s] ", colored($gpu{$gpu}{temperature}.'C', 'yellow') );
		} else { 
			$out .= sprintf( "%s] ", colored($gpu{$gpu}{temperature}.'C', 'green') );
		}
	}

	if ( $columnscounter <= $gpusperrow ) {
		print $out;
		$columnscounter++;
	} else {
	       print "\n".$out;
	       $columnscounter=1;
	}
}
print "\n";
sleep(15);
goto start;

