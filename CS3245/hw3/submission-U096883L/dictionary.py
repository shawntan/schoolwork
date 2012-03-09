DEFAULT_VALUE = -1
class Dictionary():
	def __init__(self):
		self.root = {}
		"""
	def __setitem__(self,term,val,setfreq=None):
		level = self.root
		for i in term[:-1]:
			level,_,_ = level.setdefault(i,({},0,None))
		tree,freq,value = level.setdefault(term[-1],(None,0,None))
		level[term[-1]] = (tree,setfreq if setfreq else freq+1,val)
		"""
	def __getitem__(self,term):
		level = self.root
		for i in term[:-1]:
			level,_,_ = level.setdefault(i,({},0,DEFAULT_VALUE))
		tup = level.setdefault(term[-1],(None,0,DEFAULT_VALUE))
		return tup,level,term[-1]
	def __setitem__(self,term,val,inc_freq = True):
		(sub,freq,ptr),parent,x = self.__getitem__(term)
		parent[x] = sub,freq + 1 if inc_freq else freq,val
	def set_ptr(self,term,val,inc_freq = True):
		(sub,freq,ptr),parent,x = self.__getitem__(term)
		parent[x] = sub,freq + 1 if inc_freq else freq,val
		return ptr

	def _set_freq_ptr(self,term,freq,ptr):
		(sub,_,_),parent,x = self.__getitem__(term)
		parent[x] = sub,freq,ptr

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

	def term_freq_ptr(self):
		pass
	def interator(self,prefix,node):
		for i in node:
			subtree,freq,ptr = node[i]
			if freq >= 1:
				yield (prefix + i,freq,ptr)
			if subtree:
				for tup in self.interator(prefix+i,subtree):
					yield tup

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
				self._set_freq_ptr(dic[offset1:offset],freq1,ptr1)
			prev = curr
		freq1,ptr1,offset1 = prev
		self._set_freq_ptr(dic[offset1:-1],freq1,ptr1)
if __name__=="__main__":
	d = Dictionary()
	d['hello'] = 1436
	d['nonsense'] = 121
	d['rubbish'] = 1345
	d.write('dictionary')
	
	d = Dictionary()
	d.read('dictionary')
