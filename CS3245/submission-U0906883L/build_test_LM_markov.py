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
	
	return markov_model(entries)

def markov_model(entries):
	cats = {}
	for cat,url in entries:
		category = cats[cat] = cats[cat] if cat in cats else {}
		
		for i in range(len(url)):
			last = i + (N-1)
			if last <= len(url):
				prior = url[i:last]
				pos = url[last] if last != len(url) else ''
				if prior not in category: category[prior] = {}
				freq = category[prior]
				if pos not in freq: freq[pos] = 0
				freq[pos] += 2
				CHAR_SET.add(pos)
		
	
	prob_count = {}
	for cat in cats:
		prob_count[cat] = {}
		for prior in cats[cat]:
			total = 0
			for pos in cats[cat][prior]: total += cats[cat][prior][pos]
			total += len(CHAR_SET)
			prob_count[cat][prior] = total

	return cats,prob_count

def test_url(model,url):
	freq_counts, prob_count = model
	max_prob, category = 0, None

	for cat in freq_counts:
		combined_prob = 1
		for i in range(len(url)):
			last = i + (N-1)
			if last <= len(url):
				prior = url[i:last] 
				pos = url[last] if last != len(url) else ''
				
				#Calculating  P(pos|prior,category)
				if prior in prob_count[cat]:
					if pos in freq_counts[cat][prior]:
						prob = (freq_counts[cat][prior][pos] + 1.0)/float(prob_count[cat][prior]) 
					else:
						prob =	1.0/float(prob_count[cat][prior]) 	# if not seen before, estimate
				else:
					prob = 1.0/float(len(CHAR_SET))				# assume uniform distribution
			combined_prob *= prob

		max_prob = max(combined_prob,max_prob)
		category = category if combined_prob < max_prob else cat
	#	print "%0.60f %s" % (combined_prob,cat)
	return category

def preprocess(in_file):
	FILE = open(in_file,'r')
	lines = FILE.readlines()

	lines = [tuple(urllib.unquote(l).split()) for l in lines]
	lines = [(l[0],re.sub("\d+","#",l[1][len('http://'):]).lower()) for l in lines]
	FILE.close()
	return lines 


def test_LM(in_file, out_file, LM):
	"""
	test the language models on new URLs
	each line of in_file contains an URL
	you should print the most probable label for each URL into out_file
	"""
	infile = open(in_file,'r')
	output = open(out_file,'w')
	urls = infile.readlines()
	infile.close()

	for url in urls:output.write(test_url(LM,url)+'\n')
	

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
