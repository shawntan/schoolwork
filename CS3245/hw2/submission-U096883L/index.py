#!/usr/bin/python2
import nltk,re,os
from nltk.stem.porter import PorterStemmer
from skiplist import Posting


DIR_DELIM = '/'
non_alphanum = re.compile('\W') 
number = re.compile('[0-9]') 
def preprocess(word):
	w = non_alphanum.sub("",word)
	w = w.lower()
#	w = number.sub("#",w)
	return w


def index_file(directory,filename,post_list):
	f = open(directory + DIR_DELIM + filename,'r')
	words = set()
	for line in f:
		for w in line.split():
			w = preprocess(w)
			if w and w not in nltk.corpus.stopwords.words('english'):
				words.add(w)
	for word in words:post_list.add(word,filename.split(DIR_DELIM)[-1])

def index_dir(directory,post_list):
	file_list = [int(v) for v in os.listdir(directory)]
	file_list.sort()
	file_list.reverse()
	for i in file_list: index_file(directory,str(i),post_list)

post_list = Posting('test','r')
#index_dir('test_set',post_list)
#post_list.save_dic()
	
try:
	for i in post_list.postings('ship'): print i
except IOError as e:
	print "Nooo read..."


	
