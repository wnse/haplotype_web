
import os, tempfile
import subprocess

def phasing(stringA):
	with tempfile.NamedTemporaryFile(mode='w+t', dir='.', delete=False) as f:
		f.write(stringA)
		f.seek(0)
		outfile = f.name+".out"
		commands = '/home/yangk/git/haplotype_web/haplotype/hap/bio_src/hap.sh '+(f.name)#+' >' + outfile
		print (commands)
		output = subprocess.Popen(commands ,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
	return output.stdout.read().decode('utf-8')


