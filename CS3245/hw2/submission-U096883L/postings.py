import os
DELIM = ' '
POSTINGS_FILE	= None
DICTIONARY_FILE	= None
CORPUS_DIR		= None
dictionary		= {}
word_freq		= {}
doc_list 		= None
def initialise(corpus,post_file,dict_file):
	global POSTINGS_FILE,DICTIONARY_FILE,CORPUS_DIR,doc_list
	POSTINGS_FILE = post_file
	DICTIONARY_FILE = dict_file
	CORPUS_DIR = corpus
	doc_list = os.listdir(corpus)
	doc_list.sort()
	load_dict()
def load_dict():
	print "Loading dictionary"
	global word_freq,dictionary
	for line in open(DICTIONARY_FILE,'r'):
		vals = line.split()
		word_freq[vals[0]] = int(vals[1])
		dictionary[vals[0]] = int(vals[2])

class MergePostings():
	complement = False
	def __init__(self,op,post1,post2):
		self.op = op
		self.post1 = post1
		self.post2 = post2
	def merge(self,op,post1,post2):
		s1 = post1.estimate_size() if not post1.complement else len(doc_list)-post1.estimate_size()
		s2 = post2.estimate_size() if not post2.complement else len(doc_list)-post2.estimate_size()
		if op == 'AND':
			self.est_size = min(s1,s2)
			yeq = True if not post1.complement and not post2.complement else False
			y1 = post2.complement if not yeq else False
			y2 = post1.complement if not yeq else False
			
			if not (yeq,y1,y2) == (False,False,False): self.merged = merge(post1,post2,yeq,y1,y2)
			else: self.merged = merge(AllPostings(),merge(post1,post2,True,True,True),False,True,False)
		elif op == 'OR':
			self.est_size = s1 + s2
			if not(post1.complement or post2.complement):
				self.merged = merge(post1,post2,True,True,True)
			else:
				p1 = post1 if not post1.complement else merge(AllPostings(),post1,False,True,False)
				p2 = post2 if not post2.complement else merge(AllPostings(),post2,False,True,False)
				self.merged = merge(p1,p2,True,True,True)
	
	def __iter__(self):
		self.merge(self.op,self.post1,self.post2)
		return self.merged
	def estimate_size(self):
		return self.est_size 

class Postings(MergePostings):
	complement = False
	def __init__(self,word):
		global dictionary,word_freq,POSTINGS_FILE
		self.FILE = open(POSTINGS_FILE,'r')
		self.dic_file = dictionary 
		self.ptr = dictionary[word]
		self.est_size = word_freq[word]
		self.word = word
	def __iter__(self):
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
		tup = tuple(v for v in line.split())
		return tup 
	def __repr__(self):
		return "<%s,%d>"%(self.word,self.estimate_size())
class AllPostings(MergePostings):
	def __init__(self):
		self.word = '*'
		self.est_size = len(doc_list)
	def __iter__(self):
		return ((None,i) for i in doc_list)



def merge(post1,post2,eq_yield,post1_yield,post2_yield):
	"""
	General merge method with parameters to cater for:
	 -	AND = True,False,False
	 -	OR  = True,True,True
	 -	AND NOT = False,True,False
	 			= False,False,True
	"""
	print post1,post2,eq_yield,post1_yield,post2_yield
	post1_skip,post2_skip = 'skip' in dir(post1),'skip' in dir(post2)
	post1,post2 = iter(post1) if not post1_skip else post1, iter(post2) if not post2_skip else post2
	doc1,doc2 = post1.next(), post2.next()
	try:
		while True:
			if doc1[1] == doc2[1]:
				if eq_yield: yield doc1
				doc1,doc2 = post1.next(),post2.next()
			else:
				if post1_skip and len(doc1) > 3 and doc1[3] < doc2[1]:
					doc1 = post1.skip(int(doc1[4]))
				elif post2_skip and len(doc2) > 3 and doc1[1] > doc2[3]:
					doc2 = post2.skip(int(doc2[4]))
				elif doc1[1] < doc2[1]:
					if post1_yield: yield doc1 
					doc1 = post1.next()
				elif doc1[1] > doc2[1]:
					if post2_yield: yield doc2
					doc2 = post2.next()
	except StopIteration:
		pass
	#Either post1 or post2 has no more documents, so should be ordered
	if post1_yield:
		for v in post1: yield v
	if post2_yield:
		for v in post2: yield v

if __name__ == "__main__":
	initialise('/home/shawn/nltk_data/corpora/reuters/training','postings.txt','dictionary.txt')
	test1 = Postings('oil')
	test1.complement = False 
	test2 = Postings('read')
	print test1.estimate_size()
	print test2.estimate_size()
	for i in MergePostings('AND',test1,test2):
		print i
