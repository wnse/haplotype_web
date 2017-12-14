#! /bin/sh
bin=`dirname $0`
#read input
input=$1
if test -s $input; then
	perl $bin/hap.1.effective.pl $input
	perl $bin/hap.2.process.eff.pl $input.meffective
	perl $bin/hap.2.process.eff.pl $input.peffective
	perl $bin/hap.3.mix.haplo.pl $input
	rm $input.*
else
	echo "NULL"
fi
