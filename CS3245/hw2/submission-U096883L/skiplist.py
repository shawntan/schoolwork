import math,os
LEN_WORD = 31
LEN_FILE_ID = 15
LEN_FILEPOS = 15
DELIM = ' '
SKIP_PTR_OFFSET = LEN_WORD + len(DELIM) + LEN_FILE_ID + len(DELIM) +LEN_FILEPOS
MIN_COUNT = 10


class Postings():
	estimate_size = {
			(True,False,False): lambda post1,post2: min(post1.size(),post2.size()),
			(True,True,True):   lambda post1,post2: post1.size()+post2.size(),
			(False,True,False):   lambda post1,post2: post1.size(),
			(False,False,True):   lambda post1,post2: post2.size(),
		}
	def __init__(self,post1,post2,
			equal_yield,	#yield when both has
			post1_yield,    #yield when post1 has but other doesn't
			post2_yield     #yield when post2 has but self doesn't
		):
		self.post1 = post1
		self.post2 = post2
		self.equal_yield = equal_yield
		self.post1_yield = post1_yield
		self.post2_yield = post2_yield
		self.post1_skip = 'skip' in dir(post1) if not post1_yield else False
		self.post2_skip = 'skip' in dir(post2) if not post2_yield else False
	
	def __len__(self):
		return Postings.estimate_size[
				self.equal_yield,
				self.post1_yield,
				self.post2_yield
			](self.post1,self.post2)

	def __iter__(self):
		"""
		General merge method with parameters to cater for:
		 -	AND = True,False,False
		 -	OR  = True,True,True
		 -	AND NOT = False,True,False
		 			= False,False,True
		"""
		doc1,doc2 = self.post1.next(),self.post2.next()
		while doc1 and doc2:
			if doc1[1] == doc2[1]:
				if self.equal_yield: yield doc1
				doc1,doc2 = self.post1.next(),self.post2.next()
			else:
				if self.post1_skip and len(doc1) > 3 and doc1[3] < doc2[1]:
					doc1 = self.post1.skip(int(doc1[4]))
				elif self.post2_skip and len(doc2) > 3 and doc1[1] > doc2[3]:
					doc2 = self.post2.skip(int(doc2[4]))
				elif doc1[1] < doc2[1]:
					if self.post1_yield: yield doc1 
					doc1 = self.post1.next()
				elif doc1[1] > doc2[1]:
					if self.post2_yield: yield doc2
					doc2 = self.post2.next()
		#Either self.post1 or self.post2 has no more documents, so should be ordered
		while doc1 and self.post1_yield: 
			yield doc1
			doc1 = self.post1.next()
		while doc2 and self.post2_yield:
			yield doc2
			doc2 = self.post2.next()



class ReadPostings(Postings):
	word_freq = None
	dic = None
	def __init__(self,word,filename,dic_file="dictionary"):
		self.FILE = open(filename,'r')
		self.dic_file = dic_file
		if not ReadPostings.dic:
			ReadPostings.word_freq,ReadPostings.dic = self.load_dic()
		self.ptr = ReadPostings.dic[word]
		self.word = word
	
	def load_dic(self):
		print "Loading dictionary"
		word_freq = {}
		dic = {}
		for line in open(self.dic_file,'r'):
			vals = line.split()
			word_freq[vals[0]] = int(vals[1])
			dic[vals[0]] = int(vals[2])
		return word_freq,dic
	def __len__(self):
		return ReadPostings.word_freq[self.word]

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
		tup = tuple(v for v in line.split(DELIM)
					if v != '' and v!= '\n')
		return tup
	def __repr__(self):
		return "<%s,%d>"%(self.word,self.size())


class AllPostings(Postings):
	def __init__(self,directory):
		self.file_list = os.listdir(directory)
		self.file_list.sort()
		self.file_iter = (('*',i) for i in self.file_list)
	def next(self):
		try:
			return self.file_iter.next()
		except StopIteration as s:
			pass
	def size(self):
		return len(self.file_list)



class WritePostings():
	"""
	Reversed storage on the file, files have to be added in reverse
	"""
	def __init__(self,filename,dic_file="dictionary"):
		self.filename = filename
		self.FILE = open(filename,'w')
		self.dic_file = dic_file
		self.dic = {} 
		self.word_freq = {}	

	def add(self,word,file_id):
		pos = self.FILE.tell()
		if word not in self.dic:
			self.word_freq[word] = 0
			prev_pos = str(-1)
		else:
			prev_pos = str(self.dic[word])

		self.dic[word] = pos
		self.word_freq[word] += 1

		word = word + (LEN_WORD - len(word))*DELIM
		file_id = file_id + (LEN_FILE_ID - len(file_id))*DELIM
		pointer_ph = prev_pos + (LEN_FILEPOS-len(prev_pos))*DELIM
		skip_val = LEN_FILE_ID*DELIM
		skip_ph = LEN_FILEPOS*DELIM
		self.FILE.write(
			word + DELIM +
			file_id + DELIM +
			pointer_ph + DELIM +
			skip_val + DELIM +
			skip_ph + DELIM +
			"\n"
		)

	def save_dic(self):
		f = open(self.dic_file,'w')
		for key in self.dic:
			f.write(key)
			f.write(DELIM)
			f.write(str(self.word_freq[key]))
			f.write(DELIM)
			f.write(str(self.dic[key]))
			f.write('\n')
		f.close()
	

	def write_skip_pointers_and_close(self):
		for key in self.dic:
			postcount = self.word_freq[key]
			skipcount = int(math.sqrt(self.word_freq[key]))
			if postcount > MIN_COUNT:
				prev_ptr = None
				count = 0
				write_loc = self.dic[key]+ SKIP_PTR_OFFSET
				for word,file_id,ptr in self.postings(key):
					count += 1
					if count == skipcount+1:
						self.FILE.seek(write_loc)
						self.FILE.write(
								file_id + (LEN_FILE_ID - len(file_id))*DELIM +
								prev_ptr + (LEN_FILEPOS - len(prev_ptr))*DELIM)
						write_loc = int(prev_ptr) + SKIP_PTR_OFFSET
						count = 0
					prev_ptr = ptr
		self.save_dic()
		self.FILE.close()

	def postings(self,word):
		fil = open(self.filename,'r')
		if word in self.dic:
			addr = self.dic[word]
			while(addr != -1):
				tup = self.readtuple(fil,addr)
				addr = int(tup[2])
				yield tup
	
	def readtuple(self,fil,addr):
		fil.seek(addr)
		line =  fil.readline()
		tup = tuple(v for v in line.split(DELIM)
					if v != '' and v!= '\n')
		return tup

if __name__ == "__main__":
	word1 = ReadPostings('oil','posting.txt')
	word2 = ReadPostings('oil','posting.txt')
	oandt = Postings(word1,word2,True,False,False)

	
