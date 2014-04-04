#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

my $fnas = "../PROPHAGES/HostPhinder/results/prophage_fnas";
my (%frac_qFreq, %frac_dFreq); #These hashes of array will count the frequency of right [1]and wrong [0]predictions per each value of frac_q and frac_d respectively
my ( $frac_qMAX, $frac_qmin, $frac_dMAX, $frac_dmin ) = ( 0 ) x 4;


################################################################################ READ tax_info ################################################################################

open ( IN, '<', "../PROPHAGES/tax_info" ) or die "Can't open the file: $!";
#Save the file into an array
my @taxonomies;
while ( <IN> ) {
	push @taxonomies, [ split ];
}
close IN;
############################################################# Open each profage for each bacgterium ###################################################################################################
#print $frac_qmin . "\n";
opendir ( FNAS, $fnas ) or die $!;
#read each bacteria
while ( my $bact = readdir ( FNAS ) ) {
	next if ( $bact =~ m/^\./ );
	opendir ( BACT, "$fnas/$bact" ) or die $!;
	#read each NC file
	my $NCN = 0;
	while ( my $NCid = readdir ( BACT ) ) {
		next if ( $NCid =~ m/^\./ );
		my $NCN += 1;
		#print "NC: $NCN\n";
		opendir ( NC, "$fnas/$bact/$NCid" );
		my $prophageN = 0;
		while ( my $prophage = readdir ( NC ) ) {
			next if ( $prophage =~ m/^\./ );
			$prophageN += 1;
			#print "prophage: $prophageN\n";
			my $pfilename = "$fnas/$bact/$NCid/$prophage";
			#save the name of the folders (bacterium and NC)
			my $sp_NC_names = $1 if "$bact/$NCid" =~ m/(.*?)_1$/;
			#print "\nFolder name: " . $sp_NC_names . "\n\n";
			#print "$pfilename\n";
#----------------------------------------------------------------------------------------------------------------------------------
#SORT HostPhinder PREDICTIONS
#----------------------------------------------------------------------------------------------------------------------------------
			#my $pfilename = "PROPHAGES/HostPhinder/results/prophage_fnas/Listeria_monocytogenes_J1_220_uid179735/NC_021830_1/prophage.1.fna_pred.new";

			open ( IN, '<', "$fnas/$bact/$NCid/$prophage" ) or die "Can't open the file: $!";

			#Read the file into array of arrays
			my @HPpredictions;
			#Jump to the second line
			my $i = 0;
			while ( defined ( my $line = <IN> ) ) {
				next if $line =~ m/^Template/;
				$HPpredictions[$i] = [ split " ", $line ];
				$i = 1;

			}
#-----------------------------------------------------------------			
################################################## Sort array of arrays according to frac_q ###########################################################################
			my $first_frac_q = "";
			my $new_frac_q = 0;
			my $first_frac_d = "";
			my $new_frac_d = 0;
			if ( $i == 1 ) {
				my @results_Q = sort_array_by_column ( 5, \@HPpredictions, $frac_qMAX, $frac_qmin );	#column number, reference to HPprediction, $frac_MAX, $frac_min
				# Return: prediction, frac, frac_MAX, $frac_min
				$first_frac_q = shift @results_Q;
				$new_frac_q = shift @results_Q;
				$frac_qMAX = shift @results_Q;
				$frac_qmin = shift @results_Q;
				my @results_D = sort_array_by_column ( 6, \@HPpredictions, $frac_dMAX, $frac_dmin );
				$first_frac_d = shift @results_D;
				$new_frac_d = shift @results_D;
				$frac_dMAX = shift @results_D;
				$frac_dmin = shift @results_D;

			}

################################################## Sort array of arrays according to frac_d ###########################################################################
=pod

			#Reverse sort the array of arrays according to the 7th element of each array (frac_d)
			my @frac_dAoA = sort { $b -> [6] <=> $a -> [6] } @HPpredictions;

		
			
			if ( $i == 1 ) {
				$first_frac_d = $1 if $frac_dAoA[0][10] =~ m/"(.*?)"/;
				$new_frac_d = $frac_dAoA[0][6];
				
				#print "$first_frac_d\n";
				$frac_dMAX = max($frac_dMAX, $new_frac_d);
				if ( $frac_dmin == 0 ) {
					$frac_dmin = $new_frac_d;
				} else {
					$frac_dmin = min($frac_dmin, $new_frac_d);
				}
				
				
			}
=cut
################################################################################################################################################################################
#READ tax_info
################################################################################################################################################################################
			
			my $right_species = "";
			
				for my $i ( 0 .. $#taxonomies ) {
					if ( $taxonomies[$i][0] =~ m/\/panfs1\/cge\/people\/henrike\/genomes\/tmp\/(.*?)\.gbk/ && $1 eq $sp_NC_names ) {
						$right_species = $taxonomies[$i][6];
						
						#print "#########################$1\t$right_species\n\n";
						

					}
					
				}
			
			

############################################################## Check for identities ##################################################################################################################
			
			if ( $i == 1 ) {
				if ( $right_species eq $first_frac_q && $right_species eq $first_frac_d ) {
					#print "Both the highest frac_q and highest frac_d give the right species: $right_species, $first_frac_q, $first_frac_d\n\n";
					$frac_qFreq{$new_frac_q}[1] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
				} elsif ( $right_species eq $first_frac_q ) {
					#print "The highest frac_q gives the right species: $right_species, $first_frac_q\n\n";
					$frac_qFreq{$new_frac_q}[1] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 0;
				} elsif ( $right_species eq $first_frac_d ) {
					#print "The highest frac_d gives the right species: $right_species, $first_frac_d\n\n";
					$frac_dFreq{$new_frac_d}[1] += 1;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_qFreq{$new_frac_q}[1] += 0;
				} else {
					#print "No match\n\n";
					$frac_qFreq{$new_frac_q}[0] += 1;
					$frac_qFreq{$new_frac_q}[1] += 0;
					$frac_dFreq{$new_frac_d}[0] += 1;
					$frac_dFreq{$new_frac_d}[1] += 0;
				}
			}
			

		}
		
	}

}

#foreach my $frac ( sort ( keys %frac_qFreq ) ) {
 #    print "These are the frequencies: $frac: @{ $frac_qFreq{$frac} }\n"
 #}


#my %matchesXrange = makeintervals ( $frac_qmin, $frac_qMAX, \%frac_qFreq);


my %q = makeintervals ( $frac_qmin, $frac_qMAX, \%frac_qFreq);

foreach my $key (sort ( keys %q ) ) {
	print "$key => $q{$key}\n";
}

my %d = makeintervals ( $frac_dmin, $frac_dMAX, \%frac_dFreq);

foreach my $key (sort ( keys %d ) ) {
	print "$key => $d{$key}\n";
}

sub max {
	my ( @numbers ) = @_;
	my $max;
	if ( $numbers[0] > $numbers[1]) {
		$max = $numbers[0];

	} else {
		$max = $numbers[1];
	}
	return ( $max );
}

sub min {	#returns minimum of two numnber
	my ( @numbers ) = @_;
	my $min;
	if ( $numbers[0] < $numbers[1] ) {
		$min = $numbers[0];

	} else {
		$min = $numbers[1];
	}
	return ( $min );
}
#----------
sub sort_array_by_column {	#column number, reference to HPprediction, $frac_MAX, $frac_min
	my $column = shift;
	my $HPpredictions_ref = shift;
	my $frac_MAX = shift;
	my $frac_min = shift;
	my @sortedAoA = sort { $b -> [$column] <=> $a -> [$column] } @{ $HPpredictions_ref };
	my $first_frac = "";
	my $new_frac = 0;
	my @return;
	
	$first_frac = $1 if $sortedAoA[0][10] =~ m/"(.*?)"/;
	push ( @return, $first_frac );
	$new_frac = $sortedAoA[0][$column] + 0;
	push ( @return, $new_frac );		
		#print "$first_frac_q\n";
	$frac_MAX = max($frac_MAX, $new_frac);
	push ( @return, $frac_MAX );
	if ( $frac_min == 0 ) {
		$frac_min = $new_frac;
	} else {
		$frac_min = min($frac_min, $new_frac);
	}
	push ( @return, $frac_min );			
	
# Return: prediction, frac, frac_MAX, $frac_min
	return @return;
}
=pod
#Reverse sort the array of arrays according to the 6th element of each array (frac_q)
			my @frac_qAoA = sort { $b -> [5] <=> $a -> [5] } @HPpredictions;

			my $first_frac_q = "";
			my $new_frac_q = 0;
			#if $i => 1 means that there is a least one result: see while loop up
			if ( $i == 1 ) {
				$first_frac_q = $1 if $frac_qAoA[0][10] =~ m/"(.*?)"/;
				$new_frac_q = $frac_qAoA[0][5] + 0;
				
				#print "$first_frac_q\n";
				$frac_qMAX = max($frac_qMAX, $new_frac_q);
				if ( $frac_qmin == 0 ) {
					$frac_qmin = $new_frac_q;
				} else {
					$frac_qmin = min($frac_qmin, $new_frac_q);
				}
				
				
			}



=cut
sub makeintervals { #arguments: $frac_min, $frac_max, \%frac_Freq
	my $min = shift;
	my $max = shift;
	my $frac_Freq_ref = shift;
	my $range = $max - $min;
	my $range_size = $range / 10;
	my %matchesXrange;
	my %matchratio;
	for my $i ( 0 .. 9 ) {
	
		my $howmany = 0;
		foreach my $key (sort ( keys %{$frac_Freq_ref} ) ) {
	        
	        if ( $i == 9 && $key >= $min ) {
	        	$matchesXrange{$i}[1] += $$frac_Freq_ref{$key}[1];
	        	$matchesXrange{$i}[0] += $$frac_Freq_ref{$key}[0];
	        	

	        } elsif ( $key >= $min && $key < $min + $range_size ) {

	        	$matchesXrange{$i}[1] += $$frac_Freq_ref{$key}[1];
	        	$matchesXrange{$i}[0] += $$frac_Freq_ref{$key}[0];
	        	
	        }
	        
		}
		
		$min += $range_size;
		
	}
	#return %matchesXrange;
#	print Dumper \%matchesXrange;
	foreach my $key ( sort ( keys %matchesXrange ) ) {
		#$matchratio = $matchesXrange{$key}[1]/$matchesXrange{$key}[0];
	    #print "$range: @{ $matchesXrange{$range} }\n";
	    #print "$matchesXrange{$key}[1]/$matchesXrange{$key}[0]\n";
	    print "$matchesXrange{$key}[1]/$matchesXrange{$key}[0]\n";
	    $matchratio{$key} = $matchesXrange{$key}[1]/$matchesXrange{$key}[0];
	    #push ( @matchratio, $matchesXrange{$range}[1]/$matchesXrange{$range}[0] ); 
	    #print "$matchratio\n";
	    
	 }
	 return %matchratio;
}


__END__
my $frac_qRange = $frac_qMAX - $frac_qmin;
#calculate range size
my $q_range_size = $frac_qRange / 10;
my %matchesXrange;


#Loop on each range
for my $i ( 0 .. 9 ) {
	#print "$frac_qmin\n" if $i == 0;
	my $howmany = 0;
	foreach my $key (sort ( keys %frac_qFreq ) ) {
        #print "$key\n";
        if ( $i == 9 && $key >= $frac_qmin ) {
        	$matchesXrange{$i}[1] += $frac_qFreq{$key}[1];
        	$matchesXrange{$i}[0] += $frac_qFreq{$key}[0];
        	$howmany += $frac_qFreq{$key};

        } elsif ( $key >= $frac_qmin && $key < $frac_qmin + $q_range_size ) {

        	#print "***$key\n";
        	#print "**$frac_qFreq{$key}**\n";
        	$matchesXrange{$i}[1] += $frac_qFreq{$key}[1];
        	$matchesXrange{$i}[0] += $frac_qFreq{$key}[0];
        	$howmany += $frac_qFreq{$key};
        }
        
	}
	print "$howmany\n";
	$frac_qmin += $q_range_size;
	print $frac_qmin ."\n";
}


foreach my $range ( sort ( keys %matchesXrange ) ) {
	$matchratio = $matchesXrange{$range}[1]/$matchesXrange{$range}[0];
    print "$range: @{ $matchesXrange{$range} }\n";
    #print "***$matchesXrange{$range}[1]/$matchesXrange{$range}[0]***\n";
    print "$matchratio\n";
 }




