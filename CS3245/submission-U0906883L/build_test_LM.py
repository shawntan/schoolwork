#!/usr/bin/python2
import re
import nltk
import sys
import getopt
import urllib

N = 5
CHAR_SET = set()

def build_LM(in_file):
	"""
	build language models for each label
	each line in in_file contains a label and an URL separated by a tab(\t)
	"""
	entries = preprocess(in_file)
	return ngram_model(entries)

def ngram_model(entries):
	"""
	Takes entries, and outputs a tuple of the frequency count table,
	and the total count for each category.
	"""
	cats = {}
	prob_count = {}
	for cat,url in entries:
		category = cats[cat] = cats[cat] if cat in cats else {} 			#assign if null
		prob_count[cat] = prob_count[cat] + 1 if cat in prob_count else 1
		for i in range(len(url)):
			last = i + N
			if last <= len(url):
				ngram = url[i:last]
				category[ngram] = category[ngram] + 1 if ngram in category else 1
				CHAR_SET.add(ngram)
	return cats,prob_count

def test_url(model,url,orig_url):
	freq_counts,prob_count = model
	max_prob, category = 0, None
	for cat in freq_counts:
		combined_prob = 1
		for i in range(len(url)-N):				#iterate through ngrams in url
			
			last = i + N
			ngram = url[i:last]
			if ngram in freq_counts[cat]:
				prob = (freq_counts[cat][ngram] + 1.0)/float(prob_count[cat] + len(CHAR_SET))
			elif ngram in CHAR_SET:
				prob = 1.0/float(prob_count[cat] + len(CHAR_SET))
			else:
				prob = 1 					#ignore if word not in vocabulary

			combined_prob *= prob
		max_prob = max(combined_prob,max_prob)
		category = category if combined_prob < max_prob else cat
	return category+"\t"+orig_url
		
def preprocess(in_file):
	"""
	Preproccessing steps for lines coming in from file
	"""
	FILE = open(in_file,'r')
	lines = FILE.readlines()									
	lines = [tuple(urllib.unquote(l).split()) for l in lines]	# split lines into tuple entries (CLASS,URL)
	lines = [(l[0],process_line(l[1])) for l in lines]			# process each line further
	FILE.close()
	return lines 

def process_line(line):
	line = line[len('http://'):-1] 			#strip out http and new line character at the back
	line = re.sub("\d+","#",line)			#convert numbers to # sign
	line = re.sub("[\.\/_\?\&]","-",line)	#convert other symbols to dash
	line = line.lower()						#change all to lower case
	#line = (N-1)*'^' + line + (N-1)*'$'		#padding
	return line 					

def test_LM(in_file, out_file, LM):
	"""
	test the language models on new URLs
	each line of in_file contains an URL
	you should print the most probable label for each URL into out_file
	"""
	infile = open(in_file,'r')
	output = open(out_file,'w')
	orig_urls = infile.readlines()
	urls = [process_line(l) for l in orig_urls]
	infile.close()

	for i in range(len(urls)):
		output.write(test_url(LM,urls[i],orig_urls[i]))
	output.close()

def usage():
	print "usage: " + sys.argv[0] + " -b input-file-for-building-LM -t input-file-for-testing-LM -o output-file"

input_file_b = input_file_t = output_file = None
try:
	opts, args = getopt.getopt(sys.argv[1:], 'b:t:o:')
except getopt.GetoptError, err:
	usage()
	sys.exit(2)
for o, a in opts:
	if o == '-b':
		input_file_b = a
	elif o == '-t':
		input_file_t = a
	elif o == '-o':
		output_file = a
	else:
		assert False, "unhandled option"
if input_file_b == None or input_file_t == None or output_file == None:
	usage()
	sys.exit(2)

LM = build_LM(input_file_b)
test_LM(input_file_t, output_file, LM)
