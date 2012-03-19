from index import preprocess,stop_words
from postings import *
import re,sys,getopt,math
import heapq
def parse(tokens):
	merged = Postings(tokens[0])
	for term in tokens[1:]:
		merged = merge(merged,Postings(term))
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
	try:
		initialise(params['-p'],params['-d'])
		#initialise('postings.txt','dictionary.txt')
		output_file = open(params['-o'],'w')
		for query in open(params['-q'],'r'):
			top = []
			query = split_query(query)
			for i in parse(query.keys()):
				item = (cosine_sim(query,i[3]),i)
				if len(top) > 10 :
					heapq.heappushpop(top,item)
				else:heapq.heappush(top,item)
			result = []
			while top:result.append(heapq.heappop(top))
			result.reverse()
			output_file.write(' '.join(tup[1] for score,tup in result) + '\n')
		#regards singapore

		
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
	except KeyError:
		print "Key in parameters -d -p -q -o"
	"""
	for i in parse("billion AND dollar OR bill"):
		print i
	"""

