


def split_a_string(stringA):
	file_name="this.is.a.test.txt"
	with open (file_name,'w') as file_object:
		file_object.write(stringA)
	out = len (stringA)
	return out
	

#print (split_a_string("return render(request, 'index.html', {'output':final_out})"))

