#!/usr/bin/perl
# Provide fan curve to hit a specific degree heat target

use strict;
use Term::ANSIColor qw(colored);

# Set your desired GPU temperature in Celsius below:
my $targettemp=68;
# Set the duration between captures in Seconds below:
my $timetosleep=30;

############ Nothing to change below here
my %gpu;
my @listgpus = `lspci | grep VGA`;
my $gpucount = scalar @listgpus -1;
my $columns = `tput cols`;
my $gpusperrow = int($columns/16);

start:

my @fanspeeds = `nvidia-settings -q all | grep TargetFanSpeed  | grep fan: | awk {'print $3 $4'} | cut -d: -f3,4`;

my @gputemps = `nvidia-settings -q all | grep GPUCoreTemp | grep gpu: | awk {'print $3 $4'} | cut -d: -f3,4`;

if ( $#fanspeeds != $gpucount ) { die "Didn't find any GPUs!\n"; }

for my $fans ( @fanspeeds ) {
	if ( $fans =~ m/(\d+)\]\)\: (\d+)/ ) {
		my $gpu = "gpu:".$1;
		$gpu{$gpu}{fanpercentage} = $2;
	}
}

for my $temps ( @gputemps ) {
	if ( $temps =~ m/(\d+)\]\)\: (\d+)/ ) {
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
	$out =~ s/://;
	if ( $tempdiff > 1) { # Colder than target temp
		if ( $tempdiff > 2 ) { $changevalue=2; }
		if ( $tempdiff > 5 ) { $changevalue=5; }
		if ( $tempdiff > 10 ) { $changevalue=10; }
		if ( $tempdiff > 20 ) { $changevalue=20; }
		if ( $tempdiff > 30 ) { $changevalue=30; }
		my $setfanpercentage = $gpu{$gpu}{fanpercentage}+$changevalue;
		if ( $setfanpercentage > 99 ) { $setfanpercentage=100; }
		`nvidia-settings -a [$fan]/GPUTargetFanSpeed=$setfanpercentage`;
		$out .= &output('%s+%s:', $gpu{$gpu}{fanpercentage}, '%', $changevalue );
		$out .= &output('%s] ', $gpu{$gpu}{temperature}, 'C' );
	} elsif ( $tempdiff < -1 ) { # Hotter than target temp
		if ( $tempdiff < -2 ) { $changevalue=2; }
		if ( $tempdiff < -5 ) { $changevalue=5; }
		if ( $tempdiff < -10 ) { $changevalue=10; }
		if ( $tempdiff < -20 ) { $changevalue=20; }
		if ( $tempdiff < -30 ) { $changevalue=30; }
		my $setfanpercentage = $gpu{$gpu}{fanpercentage}-$changevalue;
		if ( $setfanpercentage < 1 ) { $setfanpercentage=0; }
		`nvidia-settings -a [$fan]/GPUTargetFanSpeed=$setfanpercentage`;
		$out .= &output('%s-%s:', $gpu{$gpu}{fanpercentage}, '%', $changevalue );
		$out .= &output('%s] ', $gpu{$gpu}{temperature}, 'C' );
	} else { # No Fan changes needed
		$out .= &output('%s:', $gpu{$gpu}{fanpercentage}, '%' );
		$out .= &output('%s] ', $gpu{$gpu}{temperature}, 'C' );
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
sleep($timetosleep);
goto start;

sub output {
	my ($format, $currentvalue, $unit, $changevalue) = @_;

	my $out;
	if ( $currentvalue > 79 ) {
		$out .= sprintf( $format, colored($currentvalue.$unit, 'red'), $changevalue );
	} elsif ( $currentvalue > 69 ) {
		$out .= sprintf( $format, colored($currentvalue.$unit, 'yellow'), $changevalue );
	} else { 
		$out .= sprintf( $format, colored($currentvalue.$unit, 'green'), $changevalue );
	}

	return $out;
}

