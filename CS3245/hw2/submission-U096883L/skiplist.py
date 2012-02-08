LEN_WORD = 31
LEN_FILE_ID = 15
LEN_FILEPOS = 15
DELIM = ' '

class Posting():
	"""
	Reversed storage on the file, files have to be added in reverse
	"""
	def __init__(self,filename,rw = 'r+',dic_file="dictionary"):
		self.FILE = open(filename,rw)
		print "Open file"
		self.dic_file = dic_file
		try:
			self.word_freq,self.dic = self.load_dic()
		except IOError as e:
			print "Starting new dictionary..."
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
		skip_ph = LEN_FILEPOS*DELIM
		self.FILE.write(
			word + DELIM +
			file_id + DELIM +
			pointer_ph + DELIM +
			skip_ph + DELIM +
			"\n"
		)

		self.FILE.seek(0,2)
	
	def postings(self,word):
		if word in self.dic:
			addr = self.dic[word]
			while(addr != -1):
				tup = self.readtuple(addr)
				addr = int(tup[2])
				yield tup
	
	def readtuple(self,addr):
		self.FILE.seek(addr)
		line =  self.FILE.readline()
		tup = tuple(v for v in line.split(DELIM) if v != '' and v!= '\n')
		return tup
	
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
	def load_dic(self):
		f = open(self.dic_file,'r')
		word_freq = {}
		dic = {}
		for line in f:
			vals = line.split()
			word_freq[vals[0]] = int(vals[1])
			dic[vals[0]] = int(vals[2])
		return word_freq,dic




