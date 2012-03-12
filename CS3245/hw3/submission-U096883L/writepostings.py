import math,os
from dictionary import *
POSTINGS_FILE	= None
DICTIONARY_FILE	= None
CORPUS_DIR		= None
LEN_WORD = 31
LEN_FILE_ID = 15	#file id
LEN_FILEPOS = 15	#pointer to the start of the list of words
LEN_TERMPOS = 15	#position of the term in the file
DELIM = ' '
SKIP_PTR_OFFSET = LEN_WORD + len(DELIM) + LEN_TERMPOS + len(DELIM) + LEN_FILE_ID + len(DELIM) +LEN_FILEPOS + len(DELIM)
MIN_COUNT = 10

def initialise(corpus,postings,dictionary):
	global POSTINGS_FILE,DICTIONARY_FILE,CORPUS_DIR
	POSTINGS_FILE = postings
	DICTIONARY_FILE = dictionary
	CORPUS_DIR = corpus

def write_doclist(f):
	doclist = os.listdir(CORPUS_DIR)
	doclist.sort()
	f.write(' '.join(doclist)+'\n')

class WritePostings():
	"""
	Reversed storage on the file, files have to be added in reverse
	"""
	def __init__(self):
		self.filename = POSTINGS_FILE 
		self.FILE = open(POSTINGS_FILE,'w')
		write_doclist(self.FILE)
		self.dic_file = DICTIONARY_FILE
		self.dic = Dictionary()

	def add(self,word,word_pos,file_id):
		pos = self.FILE.tell()
		prev_pos = str(self.dic.set_ptr(word,pos))
		word_pos = str(word_pos)

		word		= word		+ (LEN_WORD		- len(word)		)*DELIM
		word_pos	= word_pos	+ (LEN_TERMPOS	- len(word_pos)	)*DELIM
		file_id		= file_id	+ (LEN_FILE_ID	- len(file_id)	)*DELIM
		pointer_ph	= prev_pos	+ (LEN_FILEPOS	- len(prev_pos)	)*DELIM
		skip_pos	= LEN_TERMPOS*DELIM
		skip_val	= LEN_FILE_ID*DELIM
		skip_ph		= LEN_FILEPOS*DELIM
		self.FILE.write(
			word + DELIM +
			word_pos + DELIM +
			file_id + DELIM +
			pointer_ph + DELIM +
			skip_pos + DELIM +
			skip_val + DELIM +
			skip_ph + DELIM +
			"\n"
		)

	def save_dic(self):
		self.dic.write(self.dic_file)

	def write_skip_pointers_and_close(self):
		for key,postcount,ptr in self.dic:
			skipcount = int(math.sqrt(postcount))
			if postcount > MIN_COUNT :
				prev_ptr = None
				count = 0
				addr = ptr
				write_loc = addr + SKIP_PTR_OFFSET
				for  tup in self.postings(key):
					word,word_pos,file_id,ptr = tup
					count += 1
					if count == skipcount+1:
						self.FILE.seek(write_loc)
						self.FILE.write(
								word_pos	+ (LEN_TERMPOS - len(word_pos))	*DELIM + DELIM +
								file_id		+ (LEN_FILE_ID - len(file_id))	*DELIM + DELIM +
								prev_ptr	+ (LEN_FILEPOS - len(prev_ptr))	*DELIM + DELIM +
								'\n'
						)
						write_loc = int(prev_ptr) + SKIP_PTR_OFFSET
						count = 0
					prev_ptr = ptr
		self.save_dic()
		self.FILE.close()

	def postings(self,word):
		fil = open(self.filename,'r')
		(_,freq,addr),_,_ = self.dic[word]
		if freq:
			while(addr != -1):
				tup = self.readtuple(fil,addr)
				#print tup
				addr = int(tup[3])
				yield tup
	
	def readtuple(self,fil,addr):
		fil.seek(addr)
		line =  fil.readline()
		#print line
		tup = tuple(v for v in line.split())
		return tup

