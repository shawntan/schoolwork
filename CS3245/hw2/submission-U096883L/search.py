from index import preprocess
from postings import *
initialise('/home/shawn/nltk_data/corpora/reuters/training','postings.txt','dictionary.txt')
def parse(query):
	query = query.strip()
	query = re.sub("\("," ( ",query)
	query = re.sub("\)"," ) ",query)
	print query
	return combine_postings(*parse_tokens(query.split())[0])

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
		print op_stack,output
		second,first = output.pop(),output.pop()
		out = MergePostings(op,first,second)
	output.append(out)

def process_token(tok):
	tok = preprocess(tok)
	return Postings(tok)
def parse_tokens(tokens):
	output = []
	op_stack = []
	for tok in tokens:
		if tok == ')':
			while op_stack[-1] != '(':apply_op(op_stack,output)
			op_stack.pop()
		elif tok in prec:
			if op_stack and op_stack[-1] != '(' and prec[op_stack[-1]] >= prec[tok]:	
				apply_op(op_stack,output)
			op_stack.append(tok)
		else:
			output.append(process_token(tok))
	while op_stack: apply_op(op_stack,output)

	return output

