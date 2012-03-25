import os
from search import *

DELIM = ' '
POSTINGS_FILE	= None
DICTIONARY_FILE	= None
CORPUS_DIR		= None
dictionary		= {}
word_freq		= {}
doc_list 		= None

def initialise(post_file,dict_file):
	global POSTINGS_FILE,DICTIONARY_FILE
	POSTINGS_FILE = post_file
	DICTIONARY_FILE = dict_file
	load_dict()

def load_dict():
	#print "Loading dictionary"
	global doc_list,word_freq,dictionary
	FILE = open(DICTIONARY_FILE,'r')
	doc_list = FILE.readline().split()
	for line in FILE:
		vals = line.split()
		word_freq[vals[0]] = int(vals[1])
		dictionary[vals[0]] = int(vals[2])

class AllPostings():
	complement = False
	def __init__(self):
		self.word = '*'
		self.est_size = len(doc_list)
	def __iter__(self):
		return ((None,i) for i in doc_list)
	def estimate_size(self):
		return self.est_size

class EmpPostings(AllPostings):
	def __init__(self):
		self.word = '~'
		self.est_size = 0
	def __iter__(self):
		return (i for i in [])
	def estimate_size(self):
		return 0

class Postings(AllPostings):
	def __init__(self,word):
		global dictionary,word_freq,POSTINGS_FILE
		self.FILE = open(POSTINGS_FILE,'r')
		self.dic_file = dictionary 
		self.ptr = dictionary[word]
		self.est_size = word_freq[word]
		self.word = word
	def __iter__(self):
		if self.complement:
			return merge(AllPostings(),self,False,True,False)
		else:
			return self
	def next(self):
		return self.skip(self.ptr)
	def skip(self,addr):
		if(self.ptr != -1):
			tup = self.readtuple(addr)
			self.ptr = int(tup[2])
			return tup
		else:
			self.FILE.close()
			raise StopIteration
	def readtuple(self,addr):
		self.FILE.seek(addr)
		line =  self.FILE.readline()
		tup = line.split()
		tup[2] = int(tup[2])
		tup[3] = {self.word : int(tup[3])}
		if len(tup) > 4:
			tup[5] = int(tup[5])
		tup = tuple(tup)
		return tup 
	def __repr__(self):
		return "<%s%s,%d>"%('NOT ' if self.complement else '',self.word,self.estimate_size())
	def estimate_size(self):
		return self.est_size if not self.complement else len(doc_list) - self.est_size


def merge(post1,post2,eq_yield=True,post1_yield=True,post2_yield=True):
	"""
	General merge method with parameters to cater for:
	 -	AND = True,False,False
	 -	OR  = True,True,True
	 -	AND NOT = False,True,False
	 			= False,False,True
	"""
	#print post1,post2,eq_yield,post1_yield,post2_yield
	post1_skip,post2_skip = 'skip' in dir(post1),'skip' in dir(post2)
	post1,post2 = iter(post1) if not post1_skip else post1, iter(post2) if not post2_skip else post2
	doc1,doc2 = post1.next(), post2.next()
	try:
		while True:
			if doc1[1] == doc2[1]:
				yield (None,doc1[1],None,dict(doc1[3].items()+doc2[3].items()))
				doc1,doc2 = None,None
				doc1,doc2 = post1.next(),post2.next()
			else:
				if doc1[1] < doc2[1]:
					yield doc1 
					doc1 = None
					doc1 = post1.next()
				elif doc1[1] > doc2[1]:
					yield doc2
					doc2 = None
					doc2 = post2.next()
	except StopIteration:
		pass
	#Either post1 or post2 has no more documents, so should be ordered
	if doc1:yield doc1
	for v in post1: yield v
	if doc2:yield doc2
	for v in post2: yield v


def cosine_sim(query,doc):
	N = len(doc_list)
	sqr_sum_q = 0
	sqr_sum_d = 0
	sum_prod = 0
	for term in query:
		if term in word_freq:
			pre_tf = float(doc.get(term,0))
			tf_d = ( 1 + math.log(pre_tf,10)      ) if pre_tf > 0 else 0
			tf_q =   1 + math.log(float(query[term]),10)
			idf = math.log(N/float(word_freq[term]))
			tf_idf_q = tf_q*idf
			sum_prod  += tf_idf_q*tf_d
			sqr_sum_q += tf_idf_q**2
	return float(sum_prod)/(math.sqrt(sqr_sum_q))
if __name__ == "__main__":
	import heapq
	initialise("postings.txt","dictionary.txt")
	query = {"money":1,"market":1}
	top = []
	for i in merge(Postings("money"),Postings("market")):
		item = (cosine_sim(query,i[3],doc_list,word_freq),i)
		if len(top) > 10 :
			heapq.heappushpop(top,item)
		else:heapq.heappush(top,item)
	
	while top:
		print heapq.heappop(top)
	
