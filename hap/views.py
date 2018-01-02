from django.shortcuts import render
from .bio_src import phaseMethod
# Create your views here.

def phase(request):
	final_out=""
	get = {}
	phaseM = ""
	if request.POST:
		get['output'] = request.POST['input'] 
	#	phaseM = request.POST['phase_method']
	#	if phaseM == "method1":
		final_out = phaseMethod.jabrehoo(get['output'])
	#	else:
	#		final_out = phaseMethod.method2(get['output'])
	#return render(request, 'phase.html', {'output':final_out,'method':phaseM})
	return render(request, 'phase.html', {'output':final_out})
	
def about(request):
	return render(request, 'about.html')

def home(request):
#	return render(request,"introduction.html")
	return render(request,"index.html")

def example(request):
	return render(request,'example.html')


