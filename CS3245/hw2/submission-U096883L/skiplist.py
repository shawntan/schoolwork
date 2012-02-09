import math
LEN_WORD = 31
LEN_FILE_ID = 15
LEN_FILEPOS = 15
DELIM = ' '
SKIP_PTR_OFFSET = LEN_WORD + len(DELIM) + LEN_FILE_ID + len(DELIM) +LEN_FILEPOS
MIN_COUNT = 10


class ReadPostings():
	def __init__(self,filename,dic_file="dictionary",word):
		self.FILE = open(filename,'r')
	def load_dic(self):
		f = open(self.dic_file,'r')
		word_freq = {}
		dic = {}
		for line in f:
			vals = line.split()
			word_freq[vals[0]] = int(vals[1])
			dic[vals[0]] = int(vals[2])
		return word_freq,dic
	

	def readtuple(self,addr):
		self.FILE.seek(addr)
		line =  self.FILE.readline()
		tup = tuple(v for v in line.split(DELIM) if v != '' and v!= '\n')
		return tup
	
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

		self.FILE.seek(0,2)


	

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
		tup = tuple(v for v in line.split(DELIM) if v != '' and v!= '\n')
		return tup				

