use warnings;

$ARGV[0]=~/(\S+)\/(\S+)$/;
my $outdir=$1;
my $input=$ARGV[0];
main(@ARGV);

sub main{

open (FH1, "$input");
my $genotype_count = 0;
my $genotype_cell_num;
my @genotype_name;
my @genotype; 

while(<FH1>){
#chomp;
next if $_ =~ /^\s*$/;
my @temp = split(/\s+/,$_);
if ($genotype_count == 0){
$genotype_cell_num = scalar(@temp)-1;
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
	@local = (@local,$temp[$i]);
}
		
push @genotype, [ @local ];
$genotype_count = $genotype_count + 1;

}
close(FH1);




########################################
######  module 2 effective site  #######
########################################

system("touch $input.meffective");
open (FILE1, ">$input.meffective");

system("touch $input.peffective");
open (FILE2, ">$input.peffective");


for my $i (0..scalar(@genotype)-1){
	my $maternal = $genotype[$i][0];
	my $paternal = $genotype[$i][1];
	next if ($maternal=~m/"/ || $paternal=~m/"/);
	next if ($maternal=~m/\?/ || $paternal=~m/\?/);
	next if ($maternal=~m/\./ || $paternal=~m/\./);
	next if judge_effective($maternal,$paternal) == 0;
	
	my $heter;
	$heter = FILE2 if substr($maternal,0,1) eq substr($maternal,1,1);
	$heter = FILE1 if substr($paternal,0,1) eq substr($paternal,1,1);
	
	print $heter $i."\t".$maternal."\t".$paternal."\t";
	print $heter $genotype[$i][2];
	for my $j (3..$genotype_cell_num-1){   
		print $heter "\t".$genotype[$i][$j];	
	}
	print $heter "\n";
	
}
}

close FILE1;
close FILE2;

sub homo_heter{
my ($geno) = @_;
return "homo" if substr($geno,0,1) eq substr($geno,1,1);
return "heter";
}


sub judge_effective{
my ($maternal,$paternal) = @_;

if (homo_heter($maternal) ne homo_heter($paternal)){
return 1;
}
return 0;
}
