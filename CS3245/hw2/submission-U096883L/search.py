from index import preprocess,stop_words
from postings import *
import re
initialise('/home/shawn/nltk_data/corpora/reuters/training','postings.txt','dictionary.txt')
def parse(query):
	query = query.strip()
	query = re.sub("\("," ( ",query)
	query = re.sub("\)"," ) ",query)
	return parse_tokens(query.split())
prec = {
		'AND': 20,
		'OR':20,
		'NOT':30,
		'(':100,
		'^':200,
		}

def apply_op(op_stack,output):
	op = op_stack.pop()
	if op=='NOT':
		out = output.pop()
		out.complement = True
	else:
		second,first = output.pop(),output.pop()
		out = MergePostings(op,first,second)
	output.append(out)

all_postings = AllPostings()
def process_token(tok):
	if tok.lower() in stop_words: return all_postings
	tok = preprocess(tok)
	try:
		return Postings(tok)
	except KeyError:
		return EmpPostings()
def parse_tokens(tokens):
	output = []
	op_stack = []
	for tok in tokens:
		if tok == ')':
			while op_stack[-1] != '(':apply_op(op_stack,output)
			op_stack.pop()
		elif tok in prec:
			while op_stack and op_stack[-1] != '(' and prec[op_stack[-1]] >= prec[tok]:	
				apply_op(op_stack,output)
			op_stack.append(tok)
		else:
			output.append(process_token(tok))
	while op_stack: apply_op(op_stack,output)
	return output[0]
if __name__=='__main__':
	"""
	for i in parse("billion AND dollar OR bill"):
		print i
	"""
	for query in open('query.txt','r'):
		res = [int(q[1]) for q in parse(query)]
		res.sort()
		print ' '.join(str(i) for i in res)
