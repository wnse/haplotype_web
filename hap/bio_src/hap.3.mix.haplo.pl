use warnings;

my $outdir=$ARGV[0];


my @maternal_effective;
my @maternal_effective_index;
my @paternal_effective;
my @paternal_effective_index;

my @maternal_effective_parental;
my @paternal_effective_parental;

my @maternal_double_heter;
my @paternal_double_heter;
my @maternal_double_heter_index;
my @paternal_double_heter_index;

my %hmaternal_effective;
my %hpaternal_effective;
my %hmaternal_double_heter;
my %hpaternal_double_heter;

my $sample_size;

open (FH1, "$outdir.meffective.haplo");
while(<FH1>){
	my @temp = split("\t",$_);
	my @local_effective;
	@maternal_effective_index = (@maternal_effective_index, $temp[0]);
	my @local_parental = ($temp[1], $temp[2]);
	push @maternal_effective_parental, [ @local_parental ];
	$sample_size = scalar(@temp)-3;
	for my $i (3..scalar(@temp)-2){
		@local_effective = (@local_effective, $temp[$i]);
	}
	push @maternal_effective, [ @local_effective ];
	$hmaternal_effective{$temp[0]} = \@local_effective;
}
close(FH1);

open (FH2, "$outdir.peffective.haplo");
while(<FH2>){
	my @temp = split("\t",$_);
	my @local_effective;
	@paternal_effective_index = (@paternal_effective_index, $temp[0]);
	
	my @local_parental = ($temp[1], $temp[2]);
	push @paternal_effective_parental, [ @local_parental ];
	
	for my $i (3..scalar(@temp)-2){
		@local_effective = (@local_effective, $temp[$i]);
	}
	push @paternal_effective, [ @local_effective ];
	$hpaternal_effective{$temp[0]} = \@local_effective;
}
close(FH2);

#open (FH3, "$outdir/05mdouble");
#while(<FH3>){
#	my @temp = split("\t",$_);
#	my @local_effective;
#	@maternal_double_heter_index = (@maternal_double_heter_index, $temp[0]);
#	for my $i (1..scalar(@temp)-2){
#		@local_effective = (@local_effective, $temp[$i]);
#	}
#	push @maternal_double_heter, [ @local_effective ];
#	$hmaternal_double_heter{$temp[0]} = \@local_effective;
#}
#close(FH3);
#
#open (FH4, "$outdir/05pdouble");
#while(<FH4>){
#	my @temp = split("\t",$_);
#	my @local_effective;
#	@paternal_double_heter_index = (@paternal_double_heter_index, $temp[0]);
#	for my $i (1..scalar(@temp)-2){
#		@local_effective = (@local_effective, $temp[$i]);
#	}
#	push @paternal_double_heter, [ @local_effective ];
#	$hpaternal_double_heter{$temp[0]} = \@local_effective;
#}
#close(FH4);

my %maternal_heter_homo;
my %paternal_heter_homo;
#my %double_heter_homo;
my $deletion_p=0;
my $deletion_m=0;

open (FH5, "$outdir.meffective.parental");
while(<FH5>){
	my @temp = split("\t",$_);
	my $local_effective;
	for my $i (1..scalar(@temp)-2){
		$local_effective = $local_effective.$temp[$i];
	}
	$maternal_heter_homo{$temp[0]} = $local_effective;
}
if (scalar keys %maternal_heter_homo == 0) {
	$deletion_m=1;
}

open (FH6, "$outdir.peffective.parental");
while(<FH6>){
	my @temp = split("\t",$_);
	my $local_effective;
	for my $i (1..scalar(@temp)-2){
		$local_effective = $local_effective.$temp[$i];
	}
	$paternal_heter_homo{$temp[0]} = $local_effective;
}
if (scalar keys %paternal_heter_homo == 0) {
	$deletion_p=1;
}

#open (FH7, "$outdir/05double_heter_homo");
#while(<FH7>){
#	my @temp = split("\t",$_);
#	my $local_effective;
#	for my $i (1..scalar(@temp)-2){
#		$local_effective = $local_effective.$temp[$i];
#	}
#	$double_heter_homo{$temp[0]} = $local_effective;
#}
#close(FH7);

close(FH5);
close(FH6);

#system("touch $outdir/06mm");
#open (FILE1, ">$outdir/06mm");
#system("touch $outdir/06pm");
#open (FILE2, ">$outdir/06pm");

my @maternal_total;
my @paternal_total;

@paternal_total=@paternal_effective;
@maternal_total=@maternal_effective;

my @maternal_total_index;
my @paternal_total_index;

@maternal_total_index=@maternal_effective_index;
@paternal_total_index=@paternal_effective_index;


#my $mpcount = 0;
#my $doublecount = 0;
#
#while($mpcount < scalar(@maternal_effective_index) || $doublecount < scalar(@maternal_double_heter_index)){
#	if ($mpcount == scalar(@maternal_effective_index)){
#		print FILE1 $maternal_double_heter_index[$doublecount]."\t";
#		@maternal_total_index = (@maternal_total_index, $maternal_double_heter_index[$doublecount]);
#		my $local = $maternal_double_heter[$doublecount];
#		compute_array(FILE1,@$local);
#		push @maternal_total, [ @$local ];
#		$doublecount = $doublecount + 1;
#		next;
#	}
#	if ($doublecount == scalar(@maternal_double_heter_index)){
#		print FILE1 $maternal_effective_index[$mpcount]."\t";
#		@maternal_total_index = (@maternal_total_index, $maternal_effective_index[$mpcount]);
#		my $local = $maternal_effective[$mpcount];
#		compute_array(FILE1,@$local);
#		push @maternal_total, [ @$local ];
#		$mpcount = $mpcount + 1;
#		next;
#	}
#	if ($maternal_effective_index[$mpcount] < $maternal_double_heter_index[$doublecount]){
#		print FILE1 $maternal_effective_index[$mpcount]."\t";
#		@maternal_total_index = (@maternal_total_index, $maternal_effective_index[$mpcount]);
#		my $local = $maternal_effective[$mpcount];
#		compute_array(FILE1,@$local);
#		push @maternal_total, [ @$local ];
#		$mpcount = $mpcount + 1;
#		next;
#	}
#	else{
#		print FILE1 $maternal_double_heter_index[$doublecount]."\t";
#		@maternal_total_index = (@maternal_total_index, $maternal_double_heter_index[$doublecount]);
#		my $local = $maternal_double_heter[$doublecount];
#		compute_array(FILE1,@$local);
#		push @maternal_total, [ @$local ];
#		$doublecount = $doublecount + 1;
#		next;
#	}
#}
#
#$mpcount = 0;
#$doublecount = 0;
#
#while($mpcount < scalar(@paternal_effective_index) || $doublecount < scalar(@paternal_double_heter_index)){
#	if ($mpcount == scalar(@paternal_effective_index)){
#		print FILE2 $paternal_double_heter_index[$doublecount]."\t";
#		@paternal_total_index = (@paternal_total_index, $paternal_double_heter_index[$doublecount]);
#		my $local = $paternal_double_heter[$doublecount];
#		compute_array(FILE2, @$local);
#		push @paternal_total, [ @$local ];
#		$doublecount = $doublecount + 1;
#		next;
#	}
#	if ($doublecount == scalar(@paternal_double_heter_index)){
#		print FILE2 $paternal_effective_index[$mpcount]."\t";
#		@paternal_total_index = (@paternal_total_index, $paternal_effective_index[$mpcount]);
#		my $local = $paternal_effective[$mpcount];
#		compute_array(FILE2, @$local);
#		push @paternal_total, [ @$local ];
#		$mpcount = $mpcount + 1;
#		next;
#	}
#	if ($paternal_effective_index[$mpcount] < $paternal_double_heter_index[$doublecount]){
#		print FILE2 $paternal_effective_index[$mpcount]."\t";
#		@paternal_total_index = (@paternal_total_index, $paternal_effective_index[$mpcount]);
#		my $local = $paternal_effective[$mpcount];
#		compute_array(FILE2, @$local);
#		push @paternal_total, [ @$local ];
#		$mpcount = $mpcount + 1;
#		next;
#	}
#	else{
#		print FILE2 $paternal_double_heter_index[$doublecount]."\t";
#		@paternal_total_index = (@paternal_total_index, $paternal_double_heter_index[$doublecount]);
#		my $local = $paternal_double_heter[$doublecount];
#		compute_array(FILE2, @$local);
#		push @paternal_total, [ @$local ];
#		$doublecount = $doublecount + 1;
#		next;
#	}
#}
#close(FILE1);
#close(FILE2);

my $temp_maternal_crossover = count_crossover(scalar(@maternal_total)-1,$sample_size-1,@maternal_total);
my @maternal_crossover = @$temp_maternal_crossover;
my $temp_paternal_crossover = count_crossover(scalar(@paternal_total)-1,$sample_size-1,@paternal_total);
my @paternal_crossover = @$temp_paternal_crossover;

my @maternal_crossover_revise;
my @paternal_crossover_revise;
my @maternal_crossover_pos;
my @paternal_crossover_pos;

my @maternal_dominate;
my @paternal_dominate;

for my $j (0..scalar(@maternal_crossover)-1){
#	if ($maternal_crossover[$j] == 0){
#		@maternal_crossover_revise = (@maternal_crossover_revise, 0);
#		@maternal_dominate = (@maternal_dominate, $maternal_total[0][$j]);
#		next;
#	}
	my $previous = -1;
	my $cross_count = 0;
	my $cross_pos;
	my $pos=0;
	for my $i (0..scalar(@maternal_total_index)-1){
		next if $maternal_total[$i][$j] > 1;
		my $local_homo_heter; 
		if (exists $maternal_heter_homo{$maternal_total_index[$i]}){
			$local_homo_heter = $maternal_heter_homo{$maternal_total_index[$i]};
			next if substr($local_homo_heter,$maternal_total[$i][$j],1) == 0;
			if ($previous > -1){
				#next if $previous == $maternal_total[$i][$j];
				if ($previous == $maternal_total[$i][$j]) {
					$maternal_total_index[$i]=~/(\d+)/;
					$pos="$1";
					next;
				}
				$previous = $maternal_total[$i][$j];
				$cross_count = $cross_count + 1;
				$maternal_total_index[$i]=~/(\d+)/;
				$cross_pos.="$pos".":"."$1"."|";
				$pos="$1";
			}
			else{
				$maternal_total_index[$i]=~/(\d+)/;
				$pos="$1";
				$previous = $maternal_total[$i][$j];
			}
		}
=note
else{
			$local_homo_heter = $double_heter_homo{$maternal_total_index[$i]};
			next if substr($local_homo_heter,$j,1) != 1;
			if ($previous > -1){
#				next if $previous == $maternal_total[$i][$j];
				if ($previous == $maternal_total[$i][$j]) {
					$maternal_total_index[$i]=~/(\d+)/;
					$pos="$1";
					next;
				}
				$previous = $maternal_total[$i][$j];
				$cross_count = $cross_count + 1;
				$maternal_total_index[$i]=~/(\d+)/;
				$cross_pos.="$pos".":"."$1"."|";
			}
			else{
				$maternal_total_index[$i]=~/(\d+)/;
				$pos="$1";
				$previous = $maternal_total[$i][$j];
			}
		}
=cut
	}
	@maternal_crossover_pos = (@maternal_crossover_pos, $cross_pos);
	@maternal_crossover_revise = (@maternal_crossover_revise, $cross_count);
	@maternal_dominate = (@maternal_dominate, $previous);
}


for my $j (0..scalar(@paternal_crossover)-1){
#	if ($paternal_crossover[$j] == 0){
#		@paternal_crossover_revise = (@paternal_crossover_revise, 0);
#		@paternal_dominate = (@paternal_dominate, $paternal_total[0][$j]);
#		next;
#	}
	my $previous = -1;
	my $cross_count = 0;
	my $cross_pos;
	for my $i (0..scalar(@paternal_total_index)-1){
		next if $paternal_total[$i][$j] > 1;
		my $local_homo_heter; 
		if (exists $paternal_heter_homo{$paternal_total_index[$i]}){
			$local_homo_heter = $paternal_heter_homo{$paternal_total_index[$i]};
			next if substr($local_homo_heter,$paternal_total[$i][$j],1) == 0;
			if ($previous > -1){
			#	next if $previous == $paternal_total[$i][$j];
				if ($previous == $paternal_total[$i][$j]) {
					$paternal_total_index[$i]=~/(\d+)/;
					$pos="$1";
					next;
				}
				$previous = $paternal_total[$i][$j];
				$cross_count = $cross_count + 1;
				$paternal_total_index[$i]=~/(\d+)/;
				$cross_pos.="$pos".":"."$1"."|";
				$pos="$1";
			}
			else{
				$paternal_total_index[$i]=~/(\d+)/;
				$pos="$1";
				$previous = $paternal_total[$i][$j];
			}
		}
=note
		else{
			$local_homo_heter = $double_heter_homo{$paternal_total_index[$i]};
			next if substr($local_homo_heter,$j,1) != 1;
			if ($previous > -1){
				#next if $previous == $paternal_total[$i][$j];
				if ($previous == $paternal_total[$i][$j]) {
					$paternal_total_index[$i]=~/(\d+)/;
					$pos="$1";
					next;
				}
				$previous = $paternal_total[$i][$j];
				$cross_count = $cross_count + 1;
				$paternal_total_index[$i]=~/(\d+)/;
				$cross_pos.="$pos".":"."$1"."|";
			}
			else{
				$paternal_total_index[$i]=~/(\d+)/;
				$pos="$1";
				$previous = $paternal_total[$i][$j];
			}
		}
=cut
	}
	@paternal_crossover_pos =(@paternal_crossover_pos, $cross_pos);
	@paternal_crossover_revise = (@paternal_crossover_revise, $cross_count);
	@paternal_dominate = (@paternal_dominate, $previous);
}

for my $j (0..scalar(@maternal_crossover_revise)-1){
	if (defined $paternal_dominate[$j]) {
		next if $paternal_dominate[$j] > -1 && $maternal_dominate[$j] > -1;
		next if $paternal_dominate[$j] == -1 && $maternal_dominate[$j] == -1;
	}
	my $previous = -1;
	my $cross_count = 0;
	if ($maternal_dominate[$j] == -1){
		for my $i (0..scalar(@paternal_total_index)-1){
			next if $paternal_total[$i][$j] > 1;
			my $local_homo_heter; 
			if (exists $paternal_heter_homo{$paternal_total_index[$i]}){
				$local_homo_heter = $paternal_heter_homo{$paternal_total_index[$i]};
				next if substr($local_homo_heter,$paternal_total[$i][$j],1) == 0;
				if ($previous > -1){
					next if $previous == $paternal_total[$i][$j];
					$previous = $paternal_total[$i][$j];
					$cross_count = $cross_count + 1;
				}
				else{
					$previous = $paternal_total[$i][$j];
				}
			}
			else{
				$local_homo_heter = $double_heter_homo{$paternal_total_index[$i]};
				next if substr($local_homo_heter,$j,1) != 1;
				if ($previous > -1){
					next if $previous == $paternal_total[$i][$j];
					$previous = $paternal_total[$i][$j];
					$cross_count = $cross_count + 1;
				}
				else{
					$previous = $paternal_total[$i][$j];
				}
			}
		}
		$paternal_dominate[$j] = $previous;
	}
	else{
		for my $i (0..scalar(@maternal_total_index)-1){
			if ($maternal_total[$i][$j] > 1){
				next;
			}
			my $local_homo_heter; 
			if (exists $maternal_heter_homo{$maternal_total_index[$i]}){
				$local_homo_heter = $maternal_heter_homo{$maternal_total_index[$i]};
				next if substr($local_homo_heter,$maternal_total[$i][$j],1) == 0;
				if ($previous > -1){
					next if $previous == $maternal_total[$i][$j];
					$previous = $maternal_total[$i][$j];
					$cross_count = $cross_count + 1;
				}
				else{
					$previous = $maternal_total[$i][$j];
				}
			}
			else{
				$local_homo_heter = $double_heter_homo{$maternal_total_index[$i]};
				next if substr($local_homo_heter,$j,1) != 1;
				if ($previous > -1){
					next if $previous == $maternal_total[$i][$j];
					$previous = $maternal_total[$i][$j];
					$cross_count = $cross_count + 1;
				}
				else{
					$previous = $maternal_total[$i][$j];
				}
			}
		}
		$maternal_dominate[$j] = $previous;
	}
}

my %geno_eff_m;
my %geno_eff_p;

open (TFH1, "$outdir.meffective.geno");
while(<TFH1>){
	my @temp = split("\t",$_);
	my @local_effective;
	
	for my $i (1..scalar(@temp)-2){
		my @temp_i=split//,$temp[$i];
		$temp[$i]=join "|",@temp_i;
		@local_effective = (@local_effective, $temp[$i]);
	}
	$geno_eff_m{$temp[0]} = \@local_effective;
}
close(TFH1);


open (TFH2, "$outdir.peffective.geno");
while(<TFH2>){
	my @temp = split("\t",$_);
	my @local_effective;
	
	for my $i (1..scalar(@temp)-2){
		my @temp_i=split//,$temp[$i];
		$temp[$i]=join "|",@temp_i;
		@local_effective = (@local_effective, $temp[$i]);
	}
	$geno_eff_p{$temp[0]} = \@local_effective;
}
close(TFH2);


my %total_dropout_m;
my %total_dropout_p;

for my $j (0..scalar(@maternal_crossover_revise)-1){
	next if $maternal_crossover[$j] == $maternal_crossover_revise[$j];
	next if $maternal_dominate[$j] == -1;
	next if $maternal_crossover_revise[$j] != 0;
	for my $i (0..scalar(@maternal_total_index)-1){
		next if $maternal_total[$i][$j] > 1;	
		next if $maternal_total[$i][$j] == $maternal_dominate[$j];
		my $local_key = $maternal_total_index[$i]."_".$j;
		
		if (exists $geno_eff_m{$maternal_total_index[$i]}) {
			my $temp_local_geno = $geno_eff_m{$maternal_total_index[$i]};
			my @local_geno = @$temp_local_geno;
			my $m_gt = $local_geno[0];
			my $p_gt = $local_geno[1];
			my $off_gt = $local_geno[$j+2];
			if ($off_gt eq $p_gt) {
				$total_dropout_m{$local_key} = "m";
			}else{
				$total_dropout_p{$local_key} = "m";
			}
		}

	}
}


for my $j (0..scalar(@paternal_crossover_revise)-1){
	next if $paternal_crossover[$j] == $paternal_crossover_revise[$j];
	next if $paternal_dominate[$j] == -1;
	next if $paternal_crossover_revise[$j] != 0;
	for my $i (0..scalar(@paternal_total_index)-1){
		next if $paternal_total[$i][$j] > 1;	
		next if $paternal_total[$i][$j] == $paternal_dominate[$j];
		my $local_key = $paternal_total_index[$i]."_".$j;

		if (exists $geno_eff_p{$paternal_total_index[$i]}) {
			my $temp_local_geno = $geno_eff_p{$paternal_total_index[$i]};
			my @local_geno = @$temp_local_geno;
			my $m_gt = $local_geno[0];
			my $p_gt = $local_geno[1];
			my $off_gt = $local_geno[$j+2];
			if ($off_gt eq $m_gt) {
				$total_dropout_p{$local_key} = "p";
			}else{
				$total_dropout_m{$local_key} = "p";
			}
		}

	}
}


my %total_cross_over;

for my $j (0..scalar(@maternal_crossover_revise)-1){
	next if $maternal_crossover_revise[$j] == 0;
	next if $maternal_dominate[$j] == -1;
	my $previous = -1;
	my $pre_hap;

	for my $i (0..scalar(@maternal_total_index)-1){
		next if $maternal_total[$i][$j] > 1;
		if (exists $maternal_heter_homo{$maternal_total_index[$i]}){
			$local_homo_heter = $maternal_heter_homo{$maternal_total_index[$i]};
			next if substr($local_homo_heter,$maternal_total[$i][$j],1) == 0;
			if ($previous > -1){
				next if $previous == $maternal_total[$i][$j];
				my $local_key = $maternal_total_index[$i]."_".$j;
				$total_cross_over{$local_key} = "m";
				$previous = $maternal_total[$i][$j];
				$pre_hap.= "$maternal_total[$i][$j]" . "|";
			}
			else{
				$previous = $maternal_total[$i][$j];
				$pre_hap.= "$maternal_total[$i][$j]" . "|";
			}
		}
		my @hap=split /\|/, $pre_hap;
		my $pre=-1;
		foreach my $hap (@hap) {
			if ($pre == -1 && $hap == 1) {
				$maternal_dominate[$j] = "10";
				last;
			}elsif ($pre == -1 && $hap == 0) {
				$maternal_dominate[$j] = "01";
				last;
			}else{
				$maternal_dominate[$j] = "01";
				print "Something wrong is in $j about maternal hap!\n";
			}
		}
	}
}


for my $j (0..scalar(@paternal_crossover_revise)-1){
	next if $paternal_crossover_revise[$j] ==0;
	next if $paternal_dominate[$j] == -1;
	my $previous = -1;
	my $pre_hap;

	for my $i (0..scalar(@paternal_total_index)-1){
		next if $paternal_total[$i][$j] > 1;
		my $local_homo_heter; 
		if (exists $paternal_heter_homo{$paternal_total_index[$i]}){
			$local_homo_heter = $paternal_heter_homo{$paternal_total_index[$i]};
			next if substr($local_homo_heter,$paternal_total[$i][$j],1) == 0;
			if ($previous > -1){
				next if $previous == $paternal_total[$i][$j];
				my $local_key = $paternal_total_index[$i]."_".$j;
				$total_cross_over{$local_key} = "p";
				$previous = $paternal_total[$i][$j];
				$pre_hap.="$paternal_total[$i][$j]" . "|";
			}
			else{
				$previous = $paternal_total[$i][$j];
				$pre_hap.="$paternal_total[$i][$j]"."|";
			}
		}
		my @hap=split /\|/, $pre_hap;
		my $pre=-1;
		foreach my $hap (@hap) {
			if ($pre == -1 && $hap == 1) {
				$paternal_dominate[$j] = "10"; 
				last;
			}elsif ($pre == -1 && $hap == 0) {
				$paternal_dominate[$j] = "01";
				last;
			}else{
				print "Something wrong is in $j about paternal hap!\n";
				$paternal_dominate[$j] = "01";
			}
		}
	}
}



#my @double_geno_type;
#my %geno_double;
#
#open (TFH3, "$outdir/05double_geno");
#my $TFH3_count = 0;
#while(<TFH3>){
#	my @temp = split("\t",$_);
#	
#	if ($TFH3_count == 0){
#		for my $i (3..scalar(@temp)-2){
#			@double_geno_type = (@double_geno_type, $temp[$i]);
#		}	
#		$TFH3_count = $TFH3_count + 1;
#		next;
#	}
#	
#	my @local_effective;
#	for my $i (1..scalar(@temp)-2){
#		@local_effective = (@local_effective, $temp[$i]);
#	}
#	$geno_double{$temp[0]} = \@local_effective;
#}
#close(TFH3);



open (FH4, "$outdir");
my $genotype_count = 0;
my $genotype_cell_num;
my @genotype_name;
my @genotype; 
my $input_size;

while(<FH4>){

next if $_ =~ /^\s*$/;
my @temp = split(/\s+/,$_);
if ($genotype_count == 0){
$genotype_cell_num = scalar(@temp)-2;
for my $i (1..$genotype_cell_num){
	chomp($temp[$i]) if $i == $genotype_cell_num;
	@genotype_name = (@genotype_name, $temp[$i]);
}
$genotype_count = $genotype_count + 1;
next;
}

@temp = split(/\s+/,$_);
my @local;
for my $i (1..$genotype_cell_num){
	chomp($temp[$i]) if $i == $genotype_cell_num;
	my @temp_i=split//,$temp[$i];
	$temp[$i]=join "|",@temp_i;
	@local = (@local,$temp[$i]);
}

$input_size = $temp[0];
push @genotype, [ @local ];
$genotype_count = $genotype_count + 1;

}
close(FH4);

#print "N name\nC count for crossover\nG Genotype\nd double heterogeneous\nm maternal effective site\np paternal effective site\n3a three alleles\n* dropout\np| paternal crossover\nm| maternal crossover\n";


print "\tN\t";
for my $i (0..scalar(@maternal_dominate)+1){
	print $genotype_name[$i]."\t";
}
print "\n";


print "\tC\t"."00\t"."00\t";
for my $i (0..scalar(@maternal_dominate)-1){
	print $maternal_crossover_revise[$i]."|".$paternal_crossover_revise[$i]."\t";
}
print "\n";


print "\tG\t";
my %M_hap;
my %P_hap;
open HAP, ">$outdir.Haplotype";
if ($deletion_m==1){
	print "M0\t";
	print HAP "$genotype_name[0]\tM0\tMaternal\n";
}else{
	print "M0|M1\t";
	print HAP "$genotype_name[0]\tM0/M1\tMaternal\n";
}
if ($deletion_p==1) {
	print "F0\t";
	print HAP "$genotype_name[1]\tF0\tPaternal\n";
}else{
	print "F0|F1\t";
	print HAP "$genotype_name[1]\tF0/F1\tPaternal\n";
}

for my $i(0..scalar(@maternal_dominate)-1) {
	my $tag="";
	my $hap_tmp="";
	if (defined $paternal_dominate[$i]) {
		$hap_tmp="M".$maternal_dominate[$i]."|"."F".$paternal_dominate[$i]."\t";
		$M_hap{$genotype_name[$i+2]}="M".$maternal_dominate[$i];
		$P_hap{$genotype_name[$i+2]}="F".$maternal_dominate[$i];
	}else{
		$hap_tmp="M".$maternal_dominate[$i]."\t";
		$M_hap{$genotype_name[$i+2]}="M".$maternal_dominate[$i];
	}

	if ($maternal_crossover_revise[$i]>1) {
		$tag.="M_duplication[$maternal_crossover_pos[$i]]|";
	}
	elsif ($maternal_crossover_revise[$i]==1) {
		$tag.="M_cross_over[$maternal_crossover_pos[$i]]";
	}
	if ($paternal_crossover_revise[$i]>1) {
		$tag.="P_duplication[$paternal_crossover_pos[$i]]|";
	}
	elsif ($paternal_crossover_revise[$i]==1) {
		$tag.="P_cross_over[$paternal_crossover_pos[$i]]";
	}
	if (defined $maternal_dominate[$i]) {}
	else{
	#	if ($maternal_dominate[$i] eq "" || $maternal_dominate[$i] == -1) {
			
			if (all_homo($i+2) == 0) {
				$tag.="M_deletion|";
				$hap_tmp="F".$paternal_dominate[$i]."\t";
				$P_hap{$genotype_name[$i+2]}="F".$paternal_dominate[$i];
			}else{
				if ($deletion_m==1) {
					$hap_tmp="M0"."|"."F".$paternal_dominate[$i]."\t";
					$M_hap{$genotype_name[$i+2]}="M0";
					$P_hap{$genotype_name[$i+2]}="F".$paternal_dominate[$i];
				}
			}
	#	}
	}
	if (defined $paternal_dominate[$i]) {}
	else{
	#	if ($paternal_dominate[$i] eq "" || $paternal_dominate[$i] == -1) {
			if (all_homo($i+2) == 0){
				$tag.="P_deletion|";
				$hap_tmp="M".$maternal_dominate[$i]."\t";
				$M_hap{$genotype_name[$i+2]}="M".$maternal_dominate[$i];
			}else{
				if ($deletion_p==1) {
					$hap_tmp="M".$maternal_dominate[$i]."|"."F0"."\t";
					$M_hap{$genotype_name[$i+2]}="M".$maternal_dominate[$i];
					$P_hap{$genotype_name[$i+2]}="F0";
				}
			}
	#	}
	}

	print HAP "$genotype_name[$i+2]\t";

	#	$maternal_dominate[$i] = substr($double_geno_type[$i],0,1) if $maternal_dominate[$i] == 4;
	#	$paternal_dominate[$i] = substr($double_geno_type[$i],1,1) if $paternal_dominate[$i] == 4;
		print $hap_tmp;
		$hap_tmp=~s/\|/\//;
		print HAP $hap_tmp;
	print HAP "$tag\n";
}
print "\n";

close HAP;

for my $i (0..$input_size){
	print $i."\t";
	if (exists $geno_eff_m{$i}){
		print "m\t"; 
		my $temp_local_geno = $geno_eff_m{$i};
		my @local_geno = @$temp_local_geno;
		my $temp_hmaternal_effective = $hmaternal_effective{$i};
		my @local_hmaternal_effective = @$temp_hmaternal_effective;
		print $local_geno[0]."\t".$local_geno[1]."\t";
		for my $j (0..scalar(@local_hmaternal_effective)-1){
#			my $label = "";
			my $label = $local_geno[$j+2];
			my $local_key = $i."_".$j;
			if (exists $total_dropout_p{$local_key}){
				$label = $label."*";
			}
			if (exists $total_dropout_m{$local_key}) {
				$label = "*".$label;
			}
			if (exists $total_cross_over{$local_key}){
				$label = "^".$label;
			}
			if ($local_hmaternal_effective[$j] == 3){
				$label = $label."*";
			}
			if ($local_hmaternal_effective[$j] == 2){
				$label = $label."2";
			}
			if ($local_geno[$j+2] ne "."){
				if (homo_heter($local_geno[$j+2]) eq "homo" ) {
					if ($local_geno[$j+2] ne $local_geno[1]){
						$label = $label."*";
					}
					
				}
			}
			print $label."\t";
#			print $local_geno[$j+2].$label."\t";
		}
		print "\n";
		next;
	}

	if (exists $geno_eff_p{$i}){
		print "p\t"; 
		my $temp_local_geno = $geno_eff_p{$i};
		my @local_geno = @$temp_local_geno;
		my $temp_hpaternal_effective = $hpaternal_effective{$i};
		my @local_hpaternal_effective = @$temp_hpaternal_effective;
		print $local_geno[0]."\t".$local_geno[1]."\t";
		for my $j (0..scalar(@local_hpaternal_effective)-1){
#			my $label = "";
			my $label = $local_geno[$j+2];
			my $local_key = $i."_".$j;
			if (exists $total_dropout_m{$local_key}){
				$label = "*".$label;
			}
			if (exists $total_dropout_p{$local_key}) {
				$label = $label."*";
			}
			if (exists $total_cross_over{$local_key}){
				$label = $label."^";
			}
			if ($local_hpaternal_effective[$j] == 3){
				$label = $label."*";
			}
			if ($local_hpaternal_effective[$j] == 2){
				$label = $label."2";
			}
			if ($local_geno[$j+2] ne "."){
				if (homo_heter($local_geno[$j+2]) eq "homo" ) {
					if ($local_geno[$j+2] ne $local_geno[0]){
						$label = "*".$label;
					}
					
				}
			}
			print $label."\t";
#			print $local_geno[$j+2].$label."\t";
		}
		print "\n";
		next;
	}
=note	
	if (exists $geno_double{$i}){
		print "d\t";
		my $temp_local_geno = $geno_double{$i};
		my @local_geno = @$temp_local_geno;
		my $temp_hmaternal_double = $hmaternal_double_heter{$i};
		my @local_hmaternal_double = @$temp_hmaternal_double;
		print $local_geno[0]."\t".$local_geno[1]."\t";
		for my $j (0..scalar(@local_hmaternal_double)-1){
			my $label = "";
			my $local_key = $i."_".$j;
			if (exists $total_dropout_p{$local_key}){
				$label = $label."*";
			}
			if (exists $total_dropout_m{$local_key}) {
				$label = "*".$label;
			}
			if (exists $total_cross_over{$local_key}){
				$label = $label."|";
			}
			if ($local_hmaternal_double[$j] == 3){
				$label = $label."*";
			}
			if ($local_hmaternal_double[$j] == 2){
				$label = $label."2";
			}
			print $local_geno[$j+2].$label."\t";
		}
		print "\n";
		next;
	}
	if (three_allele($genotype[$i][0],$genotype[$i][1])){
		print "3a\t";
	}
	else{
		print " \t";
	}
=cut	
	if ($genotype[$i][0] ne "." && $genotype[$i][1] ne "."){
		if (homo_heter($genotype[$i][0]) eq homo_heter($genotype[$i][1]) && homo_heter($genotype[$i][1]) eq "homo"){
			print " \t";
			if ($genotype[$i][1] ne $genotype[$i][0]){
				print $genotype[$i][0]."\t".$genotype[$i][1]."\t";
				for my $j (2..$genotype_cell_num-1){
					if ($genotype[$i][$j] eq "."){
						print $genotype[$i][$j]."\t";
						next;
					}
				
					if (homo_heter($genotype[$i][$j]) eq "homo"){
						if ($genotype[$i][$j] eq "$genotype[$i][1]"){
							print "*".$genotype[$i][$j]."\t";
						}else{
							print $genotype[$i][$j]."*\t";
						}
						next;
					}
					my $x0 = substr($genotype[$i][$j],0,1);
					my $x1 = substr($genotype[$i][$j],2,1);
					my $y0 = substr($genotype[$i][0],0,1);
					my $y1 = substr($genotype[$i][1],0,1);
					if ($x0 eq $y0){
						if ($x1 eq $y1){
							print $y0."|".$y1."\t";
						}
						else{
							print $genotype[$i][$j]."x\t";
						}
					}
					else{
						if ($x0 eq $y1 && $x1 eq $y0){
							print $y0."|".$y1."\t";
						}
						else{
							print $genotype[$i][$j]."x\t";
						}
					}
				}
				print "\n";
				next;
			}
		}else{
			if (homo_heter($genotype[$i][0]) eq "heter" && homo_heter($genotype[$i][1]) eq "homo") {
				print "m\t";

				my $M0="";my $M1="";my %M0=();my %M1=();
				for my $j (2..$genotype_cell_num-1){
					if (homo_heter($genotype[$i][$j]) eq "homo") {
						$base[0] = substr($genotype[$i][0],0,1);
						$base[1] = substr($genotype[$i][0],2,1);
						if (exists $M_hap{$j+1} && $M_hap{$j+1} eq "M0") {
							my $M=substr($genotype[$i][$j],0,1);
							if ($base[0] eq substr($genotype[$i][$j],0,1)) {
								$M0{$base[0]}++;
								$M1{$base[1]}++;
							}elsif ($base[1] eq substr($genotype[$i][$j],0,1)) {
								$M0{$base[1]}++;
								$M1{$base[0]}++;
							}
						}elsif (exists $M_hap{$j+1} && $M_hap{$j+1} eq "M1") {
							if ($base[0] eq substr($genotype[$i][$j],0,1)) {
								$M1{$base[0]}++;
								$M0{$base[1]}++;
							}elsif ($base[1] eq substr($genotype[$i][$j],0,1)) {
								$M1{$base[1]}++;
								$M0{$base[0]}++;
							}
						}
					}
				}
				if (%M0 || %M1) {
					my $max_0=0;
					foreach my $base (keys %M0) {
						if ($M0{$base} > $max_0) {
							$max_0=$M0{$base};
							$M0=$base;
						}
					}
					my $max_1=0;
					foreach my $base (keys %M1) {
						if ($M1{$base} > $max_1) {
							$max_1=$M1{$base};
							$M1=$base;
						}
					}
					if ($M0 eq $M1) {
						if ($max_0 > $max_1) {
							if (substr($genotype[$i][0],0,1) eq $M0) {
								$M1=substr($genotype[$i][0],2,1);
							}else{
								$M1=substr($genotype[$i][0],0,1);
							}
						}else{
							if (substr($genotype[$i][0],0,1) eq $M1) {
								$M0=substr($genotype[$i][0],2,1);
							}else{
								$M0=substr($genotype[$i][0],0,1);
							}
						}
					}
				}else{
						$M0 = substr($genotype[$i][0],0,1);
						$M1 = substr($genotype[$i][0],2,1);
				}
				if ($M0 eq "") {
					if ($M1 eq substr($genotype[$i][0],0,1)) {
						$M0=substr($genotype[$i][0],2,1);
					}elsif ($M1 eq substr($genotype[$i][0],2,1)) {
						$M0=substr($genotype[$i][0],0,1);
					}
				}
				if ($M1 eq "") {
					if ($M0 eq substr($genotype[$i][0],0,1)) {
						$M1=substr($genotype[$i][0],2,1);
					}elsif ($M0 eq substr($genotype[$i][0],2,1)) {
						$M1=substr($genotype[$i][0],0,1);
					}
				}
				print "$M0"."|"."$M1\t";
				print "$genotype[$i][1]\t";
				for my $j (2..$genotype_cell_num-1){
					if ($genotype[$i][$j] eq "."){
						print $genotype[$i][$j]."\t";
						next;
					}
					if (homo_heter($genotype[$i][$j]) eq "homo"){
						if ($genotype[$i][$j] eq "$genotype[$i][1]"){
							print $genotype[$i][$j]."\t";
						}else{
							print $genotype[$i][$j]."*\t";
						}
						next;
					}
					my $x0 = substr($genotype[$i][$j],0,1);
					my $x1 = substr($genotype[$i][$j],2,1);
					my $y1 = substr($genotype[$i][1],0,1);
					if ($x0 eq $y1){
						if ($x1 eq $M1 || $x1 eq $M0){
							print $x1."|".$x0."\t";
						}
						else{
							print "x"."$genotype[$i][$j]"."\t";
						}
					}
					elsif ($x1 eq $y1){
						if ($x0 eq $M1 || $x0 eq $M0){
							print $x0."|".$x1."\t";
						}
						else{
							print "x".$genotype[$i][$j]."\t";
						}
					}else{
						if ($x0 eq $M0 || $x0 eq $M1) {
							print $genotype[$i][$j]."*\t";
						}else{
							print $genotype[$i][$j]."x\t";
						}
					}
				}
				print "\n";
				next;

			}elsif (homo_heter($genotype[$i][1]) eq "heter" && homo_heter($genotype[$i][0]) eq "homo") {
				print "p\t";

				my $F0="";my $F1="";my %F0=();my %F1=();
				for my $j (2..$genotype_cell_num-1){
					if (homo_heter($genotype[$i][$j]) eq "homo") {
						$base[0] = substr($genotype[$i][1],0,1);
						$base[1] = substr($genotype[$i][1],2,1);
						if (exists $P_hap{$j+1} && $P_hap{$j+1} eq "F0") {
							my $F=substr($genotype[$i][$j],0,1);
							if ($base[0] eq substr($genotype[$i][$j],0,1)) {
								$F0{$base[0]}++;
								$F1{$base[1]}++;
							}elsif ($base[1] eq substr($genotype[$i][$j],0,1)) {
								$F0{$base[1]}++;
								$F1{$base[0]}++;
							}
						}elsif (exists $P_hap{$j+1} && $P_hap{$j+1} eq "F1") {
							if ($base[0] eq substr($genotype[$i][$j],0,1)) {
								$F1{$base[0]}++;
								$F0{$base[1]}++;
							}elsif ($base[1] eq substr($genotype[$i][$j],0,1)) {
								$F1{$base[1]}++;
								$F0{$base[0]}++;
							}
						}
					}
				}
				if (%F0 || %F1) {
					my $max_0=0;
					foreach my $base (keys %F0) {
						if ($F0{$base} > $max_0) {
							$max_0=$F0{$base};
							$F0=$base;
						}
					}
					my $max_1=0;
					foreach my $base (keys %F1) {
						if ($F1{$base} > $max_1) {
							$max_1=$F1{$base};
							$F1=$base;
						}
					}
					if ($F0 eq $F1) {
						if ($max_0 > $max_1) {
							if (substr($genotype[$i][1],0,1) eq $F0) {
								$F1=substr($genotype[$i][1],2,1);
							}else{
								$F1=substr($genotype[$i][1],0,1);
							}
						}else{
							if (substr($genotype[$i][1],0,1) eq $F1) {
								$F0=substr($genotype[$i][1],2,1);
							}else{
								$F0=substr($genotype[$i][1],0,1);
							}
						}
					}
				}else{
						$F0 = substr($genotype[$i][1],0,1);
						$F1 = substr($genotype[$i][1],2,1);
				}
				if ($F0 eq "") {
					if ($F1 eq substr($genotype[$i][1],0,1)) {
						$F0=substr($genotype[$i][1],2,1);
					}elsif ($F1 eq substr($genotype[$i][1],2,1)) {
						$F0=substr($genotype[$i][1],0,1);
					}
				}
				if ($F1 eq "") {
					if ($F0 eq substr($genotype[$i][1],0,1)) {
						$F1=substr($genotype[$i][1],2,1);
					}elsif ($F0 eq substr($genotype[$i][1],2,1)) {
						$F1=substr($genotype[$i][1],0,1);
					}
				}
				print "$genotype[$i][0]\t";
				print "$F0"."|"."$F1\t";
				for my $j (2..$genotype_cell_num-1){
					if ($genotype[$i][$j] eq "."){
						print $genotype[$i][$j]."\t";
						next;
					}
					if (homo_heter($genotype[$i][$j]) eq "homo"){
						if ($genotype[$i][$j] eq "$genotype[$i][0]"){
							print $genotype[$i][$j]."\t";
						}else{
							print "*".$genotype[$i][$j]."\t";
						}
						next;
					}
					my $x0 = substr($genotype[$i][0],0,1);
					my $y0 = substr($genotype[$i][$j],0,1);
					my $y1 = substr($genotype[$i][$j],2,1);
					if ($x0 eq $y0){
						if ($y1 eq $F1 || $y1 eq $F0){
							print $y0."|".$y1."\t";
						}
						else{
							print "$genotype[$i][$j]"."x"."\t";
						}
					}
					elsif ($x0 eq $y1){
						if ($y0 eq $F1 || $y0 eq $F0){
							print $y1."|".$y0."\t";
						}
						else{
							print $y1."|".$y0."x\t";
						}
					}else{
						if ($y1 eq $F0 || $y1 eq $F1) {
							print "*"."$genotype[$i][$j]"."\t";
						}else{
							print "x"."$genotype[$i][$j]"."\t";
						}
					}
				}
				print "\n";
				next;

			}
		}
	}

	for my $j (0..$genotype_cell_num-1){
		if ($j<2) {
			print $genotype[$i][$j]."\t";
		}
		else{
			print ".\t";
		}
	}
	print "\n";
}




sub compute_array{
	my ($file, @input) = @_;

	for my $i (0..scalar(@input)-1){
		print $file $input[$i]."\t";
	}
	print $file "\n";
}


sub count_crossover{
	my ($n,$m,@total) = @_;
	my @crossover;
	for my $j(0..$m-1){
		my $local_crossover = 0;
		my $pre = -1;
		for my $i (0..$n){
			next if $total[$i][$j]>1;
			if ($pre == -1){
				$pre = $total[$i][$j];
				next;
			}
			else{
				next if $total[$i][$j] == $pre;
				$local_crossover = $local_crossover + 1;
				$pre = $total[$i][$j];
				next;
			}
		
		}
		@crossover = (@crossover, $local_crossover);
	}
	return \@crossover;
}



sub homo_heter{
	my ($geno) = @_;
	if ($geno eq ".") {
		return NULL;
	}
#	return "homo" if substr($geno,0,1) eq substr($geno,1,1);
	return "homo" if substr($geno,0,1) eq substr($geno,2,1);
	return "heter";
}

sub three_allele{
	my ($parenta1, $parenta2) = @_;
	return 0 if $parenta1 eq "." || $parenta2 eq ".";
	my $geno1 = homo_heter($parenta1);
	my $geno2 = homo_heter($parenta2);
	return 0 if $geno1 eq $geno2;

	my $homo;
	if ($geno1 eq "homo"){
		$homo = substr($parenta1,0,1);
		if (substr($parenta2,0,1) ne $homo && substr($parenta2,2,1) ne $homo){
			return 1;
		}
		else{
			return 0;
		}
	}
	else{
		$homo = substr($parenta2,0,1);
		if (substr($parenta1,0,1) ne $homo && substr($parenta1,2,1) ne $homo){
			return 1;
		}
		else{
			return 0;
		}
	}
}


sub all_homo{
	my $index=$_[0];
	my $out=0;
#	for my $i (0..scalar(@paternal_effective_index)-1) {
#		if (homo_heter($geno_eff_p[$paternal_effective_index[$i]][$index]) eq "heter") {
#			$out=1;
#			return $out;
#		}
#	}
	foreach my $j (sort keys %geno_eff_m) {
		if (${$geno_eff_m{$j}}[$index] eq ".") {
			next;
		}
		if (homo_heter(${$geno_eff_m{$j}}[$index]) eq "heter") {
			$out=1;
		}
	}
	foreach my $j (sort keys %geno_eff_p) {
		if (${$geno_eff_p{$j}}[$index] eq ".") {
			next;
		}
		if (homo_heter(${$geno_eff_p{$j}}[$index]) eq "heter") {
			$out=1;
		}
	}

#	for my $i (0..scalar(@maternal_effective_index)-1) {
#		if (homo_heter($geno_eff_m[$maternal_effective_index[$i]][$index]) eq "heter") {
#			print "$i\t$maternal_effective_index[$i]\n";
#			$out=1;
#			return $out;
#		}
#	}
	return $out;

}
