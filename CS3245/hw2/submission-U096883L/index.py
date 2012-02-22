#!/usr/bin/python2
import nltk,re,os,sys,getopt
from nltk.stem.porter import PorterStemmer
from writepostings import *
initialise('/home/shawn/nltk_data/corpora/reuters/training','postings.txt','dictionary.txt')
DIR_DELIM = '/'
non_alphanum = re.compile('\W') 
number = re.compile('[0-9]')
splitter = re.compile('[\s\d\.\-\/]+')
stemmer = PorterStemmer()
stop_words = set(nltk.corpus.stopwords.words('english'))

def preprocess(word):
	w = non_alphanum.sub("",word)
	w = w.lower()
	if w not in stop_words:
		w = stemmer.stem_word(w)
	#	w = number.sub("#",w)
		return w


def index_file(directory,filename,post_list):
	f = open(directory + DIR_DELIM + filename,'r')
	words = set()
	for line in f:
		for w in splitter.split(line):
			w = preprocess(w)
			if w:
				words.add(w)
	for word in words:post_list.add(word,filename.split(DIR_DELIM)[-1])

def index_dir(directory,post_list):
	file_list = os.listdir(directory)
	file_list.sort()
	file_list.reverse()
	for i in file_list: index_file(directory,str(i),post_list)

if __name__ == "__main__":
	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"d:i:p:")
	params = {}
	for x,y in opts:params[x] = y
	"""
	index_dir(params['-i'],post_list)
	post_list.write_skip_pointers_and_close()
	"""
	post_list = WritePostings()
	index_dir('/home/shawn/nltk_data/corpora/reuters/training',post_list)
	post_list.write_skip_pointers_and_close()
