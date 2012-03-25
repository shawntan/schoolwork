from index import preprocess,stop_words
from postings import *
import re,sys,getopt,math
import heapq
def parse(tokens):
	first = 0
	while True:
		try:
			merged = Postings(tokens[first])
			break
		except KeyError:
			first += 1
	for term in tokens[first+1:]:
		try:
			merged = merge(merged,Postings(term))
		except KeyError:
			pass
	return merged

def split_query(query):
	result = {}
	tokens = query.split()
	for i in tokens:
		term = preprocess(i)
		result[term] = result.get(term,0) + 1
	return result

if __name__=='__main__':

	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"d:p:q:o:")
	params = dict(opts)
	initialise(params['-p'],params['-d'])
	#initialise('postings.txt','dictionary.txt')
	output_file = open(params['-o'],'w')
	for query in open(params['-q'],'r'):
		try:
			top = []
			query = split_query(query)
			for i in parse(query.keys()):
				item = (cosine_sim(query,i[3]),-1*int(i[1]),i)
				if len(top) >= 10 :
					heapq.heappushpop(top,item)
				else:heapq.heappush(top,item)
				
			result = []
			while top:result.append(heapq.heappop(top))
			result.reverse()
			for i in result: print i
			output_file.write(' '.join(tup[1] for score,_,tup in result) + '\n')
		except Exception as ex:
			print ex
			output_file.write('\n')

		
		"""
		all_postings = AllPostings()
		output_file = open(params['-o'],'w')
		for query in open(params['-q'],'r'):
			try:
				res = [int(q[1]) for q in parse(query)]
				res.sort()
				output_file.write(' '.join(str(i) for i in res) + '\n')
			except Exception:
				output_file.write('\n')
		"""
	"""
	for i in parse("billion AND dollar OR bill"):
		print i
	"""

