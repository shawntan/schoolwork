import re
from skiplist import Postings,ReadPostings,AllPostings
from index import preprocess
corpus_dir = None
op = {
	'AND':	2,
	'OR':	2,
	'NOT':	1,
	'(' : 	1000,
	')' : 	-1,
	}
def parse(query):
	query = query.strip()
	query = re.sub("\("," ( ",query)
	query = re.sub("\)"," ) ",query)
	print query
	return combine_postings(*parse_tokens(query.split())[0])
def stream(term):
	return ReadPostings(preprocess(term),"posting.txt")
def parse_tokens(tokens):
	op_stack = []
	output = []
	buf = []
	def pop_and_combine():
		if op_stack[-1] == 'NOT':
			op_stack.pop()
			subt = output.pop()
			if subt[1]:
				subt = combine_postings(*subt)
				subt.negate = True
				sub = (None,[subt])
			else:
				subt[1][0].negate=True
				sub = subt
			#sub = (op_stack.pop(),subt if subt[0] else subt[1][0])
		else:
			sub = combine_sub(op_stack.pop(),output.pop(),output.pop())
		output.append(sub)

	for tok in tokens:
		if tok in op:
			if tok == '(':
				op_stack.append(tok)
			elif tok == ')':
				while op_stack[-1] != '(': pop_and_combine()
				op_stack.pop()
			else:
				if op_stack and op[op_stack[-1]] <= op[tok]: pop_and_combine()	
				op_stack.append(tok)
		else:
			output.append((None,[stream(tok)]))
	while op_stack: 
		pop_and_combine()	
	return output

def combine_sub(op,sub1,sub2):
	if not sub2[0]: sub1,sub2 = sub2,sub1
	op1,ssub1 = sub1
	op2,ssub2 = sub2
	#print op,sub1,sub2
	if not op1:
		if not op2:
			return (op,ssub1+ssub2)
		elif op == op2:
			return (op,ssub1+ssub2)
		else:
			ssub1.append(combine_postings(*sub2))
			return (op,ssub1) 
	else:
		if op == op1 == op2:
			return (op,ssub1+ssub2)
		elif op == op1:
			ssub1.append(combine_postings(*sub2))
			return (op,ssub1)
		elif op == op2:
			ssub2.append(combine_postings(*sub1))
			return (op,ssub2)
		else:
			return (op,[combine_postings(*sub1),combine_postings(*sub2)])
def combine_postings(op,values):
	values = sorted(values,key=len,reverse=True)
	if op == 'AND':
		y1,y2,y3 = True,False,False
	elif op == 'OR':
		y1,y2,y3 = True,True,True
	
	result = values.pop()
	while values:
		result = Postings(result,values.pop(),y1,y2,y3)
	return result
	
if __name__=="__main__":
	test = "pay AND NOT(april AND NOT senate)"
	print parse(test)
