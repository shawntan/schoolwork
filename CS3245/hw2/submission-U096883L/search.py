import re
from skiplist import ReadPostings,AllPostings
from index import preprocess
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
	return parse_tokens(query.split())[0]
def stream(term):
	return ReadPostings(preprocess(term),"posting.txt")
def parse_tokens(tokens):
	op_stack = []
	output = []
	buf = []
	def pop_and_combine():
		print op_stack
		if op_stack[-1] == 'NOT':
			subt = output.pop()
			sub = (op_stack.pop(),subt if subt[0] else subt[1][0] )
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
			ssub1.append(sub2)
			return (op,ssub1) 
	else:
		if op == op1 == op2:
			return (op,ssub1+ssub2)
		elif op == op1:
			ssub1.append(sub2)
			return (op,ssub1)
		elif op == op2:
			ssub2.append(sub1)
			return (op,ssub2)
		else:
			return (op,[sub1,sub2])
	
if __name__=="__main__":
	test = "pay AND april AND senate"
	print test
	print parse(test)
