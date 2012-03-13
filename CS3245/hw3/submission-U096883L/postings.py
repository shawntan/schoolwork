import os
from dictionary import *
DELIM = ' '
POSTINGS_FILE	= None
DICTIONARY_FILE	= None
CORPUS_DIR		= None
dictionary		= None
doc_list 		= None

def initialise(post_file,dict_file):
	global POSTINGS_FILE,DICTIONARY_FILE
	POSTINGS_FILE = post_file
	DICTIONARY_FILE = dict_file
	load_doclist()
	load_dict()

def load_doclist():
	global POSTINGS_FILE,doc_list
	f = open(POSTINGS_FILE,'r')
	doc_list = f.readline().split()
	f.close()

def load_dict():
	#print "Loading dictionary"
	global dictionary,DICTIONARY_FILE
	dictionary = Dictionary()
	dictionary.read(DICTIONARY_FILE)

class AllPostings():
	complement = False
	def __init__(self):
		self.word = '*'
		self.est_size = len(doc_list)
	def __iter__(self):
		return ((None,0,i) for i in doc_list)
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



class PhrasePostings(AllPostings):

	def __init__(self,termlist):
		self.terms = termlist
		termlist = iter(termlist)
		self.merged = Postings(termlist.next())
		self.size = self.merged.estimate_size()
		self.postings = [self.merged]
		for term in termlist:
			p = Postings(term)
			self.merged = merge(self.merged,p,True,False,False,lambda x,y: x-y+1)
			self.size = min(self.size,p.estimate_size())
			self.postings.append(p)
	def __repr__(self):
		return "\"%s\""%(' '.join(repr(i) for i in self.postings))
	def __iter__(self):
		prev = None
		for i in self.merged:
			if i[2] != prev:
				yield i
				prev = i[2]
	def estimate_size(self):
		return self.size


class MergePostings(AllPostings):
	def __init__(self,op,post1,post2):
		self.op = op
		self.post1 = post1
		self.post2 = None
		self._insert(post2)

	def _insert(self,post):
		if self.post2 and post.estimate_size() >= self.post2.estimate_size():
			return post
		else:
			tmp = self.post2
			if 'op' not in dir(self.post1) or self.post1.op != self.op: #treat as 1 entity
				if self.post1.estimate_size() > post.estimate_size():
					self.post2 = self.post1
					self.post1 = post
				else:
					self.post2 = post
			else:
				self.post2 = self.post1._insert(post)
			return tmp

	def merge(self,op,post1,post2):
		s1 = post1.estimate_size()
		s2 = post2.estimate_size()
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
	def __repr__(self):
		return "%s(%s %s %s)"%('NOT' if self.complement else '',self.post1,self.op,self.post2)
	def estimate_size(self):
		s1 = self.post1.estimate_size()
		s2 = self.post2.estimate_size()
		if self.op == 'AND':
			est_size = min(s1,s2)
		elif self.op == 'OR':
			est_size = s1 + s2
		return est_size if not self.complement else len(doc_list) - est_size

class Postings(MergePostings):
	def __init__(self,word):
		global dictionary,POSTINGS_FILE
		self.FILE = open(POSTINGS_FILE,'r')
		self.dic_file = dictionary 
		(_,self.est_size,self.ptr),_,_ = dictionary[word]
		self.word = word
		self.prev = None
	def __iter__(self):
		if self.complement:
			return merge(AllPostings(),self,False,True,False)
		else:
			return self

	def next(self):
		tup = self.skip(self.ptr)
		while self.prev == tup[2]:
			tup = self.skip(self.ptr)
		self.prev = tup[2]
		return tup

	def skip(self,addr):
		if(self.ptr != -1):
			tup = self.readtuple(addr)
			self.ptr = int(tup[3])
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
		return "<%s%s,%d>"%('NOT ' if self.complement else '',self.word,self.estimate_size())
	def estimate_size(self):
		return self.est_size if not self.complement else len(doc_list) - self.est_size


def merge(post1,post2,eq_yield,post1_yield,post2_yield,fun=lambda x,y:0):
	"""
	General merge method with parameters to cater for:
	-	AND = True,False,False
	-	OR  = True,True,True
	-	AND NOT = False,True,False
				= False,False,True
	"""
	#print post1,post2,eq_yield,post1_yield,post2_yield
	post1_skip,post2_skip = 'skip' in dir(post1), 'skip' in dir(post2)
	post1,post2 = iter(post1) if not post1_skip else post1, iter(post2) if not post2_skip else post2
	doc1,doc2 = post1.next(), post2.next()
	try:
		while True:
			#print doc1,doc2,fun(int(doc1[1]),int(doc2[1]))
			if doc_comp(doc1[2],doc1[1],doc2[2],doc2[1],fun)==0:
				if eq_yield: yield doc2 #important to yield doc2. for phrasal queries
				doc1,doc2 = None,None
				doc1,doc2 = post1.next(),post2.next()
			else:
				if   post1_skip and len(doc1) > 4 and doc_comp(doc1[5],doc1[4],doc2[2],doc2[1],fun) < 0:
					doc1 = post1.skip(int(doc1[6]))
				elif post2_skip and len(doc2) > 4 and doc_comp(doc2[5],doc2[4],doc1[2],doc1[1],fun) < 0:
					doc2 = post2.skip(int(doc2[6]))
				elif doc_comp(doc1[2],doc1[1],doc2[2],doc2[1],fun) < 0:
					if post1_yield: yield doc1
					doc1 = None
					doc1 = post1.next()
				elif doc_comp(doc1[2],doc1[1],doc2[2],doc2[1],fun) > 0:
					if post2_yield: yield doc2
					doc2 = None
					doc2 = post2.next()
	except StopIteration:
		pass
	#Either post1 or post2 has no more documents, so should be ordered
	if post1_yield:
		if doc1: yield doc1
		for v in post1: yield v
	if post2_yield:
		if doc2: yield doc2
		for v in post2: yield v

def doc_comp(doc1,tpos1,doc2,tpos2,term_comp):
	tpos1,tpos2 = int(tpos1),int(tpos2)
	if doc1 == doc2:
		return term_comp(tpos1,tpos2)
	elif doc1 < doc2: return -1
	elif doc2 < doc1: return  1


if __name__ == "__main__":
	initialise('postings.txt','dictionary.txt')
	p = PhrasePostings("donald trump said".split())
	for i in p:
		print i
