from django.shortcuts import render
from .bio_src import bio_split
# Create your views here.

def index(request):
	final_out=""
	get = {}
	if request.POST:
		get['output'] = request.POST['input'] 
		final_out = bio_split.phasing(get['output'])
	return render(request, 'index.html', {'output':final_out})
	
def example(request):
	return render(request, 'example.html')


