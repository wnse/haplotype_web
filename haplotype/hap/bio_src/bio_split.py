
import os, tempfile
import subprocess

def phasing(stringA):
	with tempfile.NamedTemporaryFile(mode='w+t', dir='.') as f:
		f.write(stringA)
		f.seek(0)
		commands = 'hap/bio_src/hap.sh '+(f.name)
		output = os.popen(commands)
		#output = subprocess.Popen(commands ,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
		return output.read()


