#!/usr/bin/python2
import nltk,re,os,sys,getopt
from nltk.stem.porter import PorterStemmer
from writepostings import *
from itertools import izip
DIR_DELIM = '/'
non_alphanum = re.compile('\W') 
number = re.compile('[0-9]')
splitter = re.compile('[\s\.\-\/]+')
stemmer = PorterStemmer()
stop_words = set(nltk.corpus.stopwords.words('english'))

def preprocess(word):
	w = non_alphanum.sub("",word)
	w = w.lower()
	if w in stop_words: return
	w = stemmer.stem_word(w)
#	w = number.sub("",w)
	return w

def index_file(directory,filename,post_list):
	f = open(directory + DIR_DELIM + filename,'r')
	words = splitter.split(f.read())
	words.reverse()
	index = len(words)-1
	for w in words:
		w = preprocess(w)
		if w:
			post_list.add(w,index,filename.split(DIR_DELIM)[-1])
		index -= 1

def index_dir(directory,post_list):
	file_list = os.listdir(directory)
	file_list.sort()
	file_list.reverse()
	for i in file_list: index_file(directory,str(i),post_list)

if __name__ == "__main__":
	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"d:i:p:")
	params = dict(opts)
	try:
		initialise(params['-i'],params['-p'],params['-d'])
		post_list = WritePostings()
		index_dir(params['-i'],post_list)
		post_list.write_skip_pointers_and_close()
	except KeyError:
		pass
