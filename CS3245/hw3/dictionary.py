class Dictionary():
	def __init__(self):
		self.root = {}
	def __setitem__(self,term,val):
		level = self.root
		for i in term[:-2]:
			level = level.setdefault(i,{})
		level[term[-1]] = val
		print self.root
