#!/usr/bin/python2
import nltk,re,os
from nltk.stem.porter import PorterStemmer
from skiplist import WritePostings


DIR_DELIM = '/'
non_alphanum = re.compile('\W') 
number = re.compile('[0-9]')
splitter = re.compile('[\s\d\.\-]+')
stemmer = PorterStemmer()
def preprocess(word):
	if word in nltk.corpus.stopwords.words('english'):return ''
	w = non_alphanum.sub("",word)
	w = w.lower()
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

post_list = WritePostings('posting.txt')
index_dir('test_set',post_list)
post_list.write_skip_pointers_and_close()
	



	
