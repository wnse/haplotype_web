
import os, tempfile
import subprocess

def jabrehoo(stringA):
	path = os.path.dirname(__file__)
	with tempfile.NamedTemporaryFile(mode='w+t') as f:
		f.write(stringA)
		f.seek(0)
		commands = os.path.join(path, 'hap.sh') + ' ' +(f.name)
		output = os.popen(commands)
		return output.read()


def method2(stringA):
	path = os.path.dirname(__file__)
	with tempfile.NamedTemporaryFile(mode='w+t') as f:
		f.write(stringA)
		f.seek(0)
		commands = 'perl' + ' ' + os.path.join(path,'phaseHMM.pl') + ' ' + (f.name)
		output = os.popen(commands)
		return output.read()
