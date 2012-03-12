from index import preprocess,stop_words
from postings import *
import re,sys,getopt
def parse(query):
	query = query.strip()
	query = re.sub("\("," ( " ,query)
	query = re.sub("\)"," ) " ,query)
	query = re.sub("\""," \" ",query)
	return parse_tokens(query.split())
prec = {
	'AND'	: 20,
	'OR'	: 20,
	'NOT'	: 30,
	'('		: 100,
	'\"'	: 100,
	'^'		: 200,
}
right = set(['NOT'])

def apply_op(op_stack,output):
	op = op_stack.pop()
	if op=='NOT':
		out = output.pop()
		out.complement = not out.complement
	else:
		second,first = output.pop(),output.pop()
		out = MergePostings(op,first,second)
	output.append(out)

all_postings = None
def process_token(tok):
	if tok.lower() in stop_words: return all_postings
	tok = preprocess(tok)
	try:
		return Postings(tok)
	except KeyError:
		return EmpPostings()
def parse_tokens(tokens):
	"""
	Implementation of the shunting-yard algorithm, with
	modifications to handle unary right associative 
	operators
	"""
	output = []
	op_stack = []
	phrasal = []
	for tok in tokens:
		print output,op_stack,tok
		if tok == "\"":
			if op_stack and op_stack[-1] == "\"":
				output.append(PhrasePostings(phrasal))
				phrasal = []
				op_stack.pop()
			else: op_stack.append(tok)
		elif tok == ')':
			while op_stack[-1] != '(':apply_op(op_stack,output)
			op_stack.pop()
		elif tok in prec:
			if tok in right:
				while op_stack and op_stack[-1] != '(' and prec[op_stack[-1]] > prec[tok]:
					apply_op(op_stack,output)
			else:
				while op_stack and op_stack[-1] != '(' and prec[op_stack[-1]] >= prec[tok]:
					apply_op(op_stack,output)
			op_stack.append(tok)
		else:
			if op_stack[-1] == '\"':
				phrasal.append(preprocess(tok))
			else:
				output.append(process_token(tok))
	while op_stack: apply_op(op_stack,output)
	return output[0]
if __name__=='__main__':

	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"d:p:q:o:")
	params = dict(opts)
	try:
		initialise(params['-p'],params['-d'])
		all_postings = AllPostings()
		output_file = open(params['-o'],'w')
		for query in open(params['-q'],'r'):
			try:
				res = [int(q[1]) for q in parse(query)]
				res.sort()
				output_file.write(' '.join(str(i) for i in res) + '\n')
			except Exception:
				output_file.write('\n')
	except KeyError:
		print 'Key in parameters -d -p -q -o'
	"""
	for i in parse("billion AND dollar OR bill"):
		print i
	"""
