class Dictionary():
	def __init__(self):
		self.root = {}
	def __setitem__(self,term,val,setfreq=None):
		level = self.root
		for i in term[:-1]:
			level,_,_ = level.setdefault(i,({},0,None))
		tree,freq,value = level.setdefault(term[-1],(None,0,None))
		level[term[-1]] = (tree,setfreq if setfreq else freq+1,val)
	def __getitem__(self,term):
		level = self.root
		try:
			for i in term[:-1]:
				level,_,_ = level[i]
			_,freq,val = level[term[-1]]
			return freq,val
		except KeyError:
			return 0,None
	def write(self,filename):
		FILE = open(filename,'w')
		term_ptrs = []
		self._writeterms(FILE,'',self.root,term_ptrs)
		FILE.write('\n')
		for freq,ptr,offset in term_ptrs:
			FILE.write(
				str(freq)+' '+
				str(ptr)+' '+
				str(offset)+' '+
				'\n'
			)
		FILE.close()

	def _writeterms(self,f,prefix,node,term_list):
		for i in node:
			subtree, freq, ptr = node[i]
			if freq >= 1:
				term_list.append((freq,ptr,f.tell()))
				f.write(prefix+i)
			if subtree:self._writeterms(f,prefix+i,subtree,term_list)

	def read(self,filename):
		FILE = open(filename,'r')
		dic = FILE.readline()
		prev = None
		for line in FILE:
			freq,ptr,offset = tuple(line.split())
			curr = freq,ptr,offset = int(freq),int(ptr),int(offset)
			if prev:
				freq1,ptr1,offset1 = prev
				self.__setitem__(dic[offset1:offset],ptr1,freq1)
			prev = curr
if __name__=="__main__":
	d = Dictionary()
	d['hello'] = 1436
	d['nonsense'] = 121
	d['rubbish'] = 1345
	d.write('dictionary')
	
	d = Dictionary()
	d.read('dictionary')

