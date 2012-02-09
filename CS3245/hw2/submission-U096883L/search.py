op = {
	'AND':	2,
	'OR':	2,
	'NOT':	1,
	'(' : 	1000,
	')' : 	-1,
	}
def parse_tokens(tokens):
	op_stack = []
	output = []
	buf = []
	def pop_and_combine():
		print op_stack
		if op_stack[-1] == 'NOT':
			sub = (op_stack.pop(),output.pop()[1])
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
			output.append((None,[tok]))
	while op_stack: 
		pop_and_combine()	
	return output

def combine_sub(op,sub1,sub2):
	op1,ssub1 = sub1
	op2,ssub2 = sub2
	#print op,sub1,sub2
	if not op1:
		if not op2:
			return (op,ssub1+ssub2)
		elif op == op2:
			return (op,ssub1+ssub2)
		else:
			return (op,ssub1+[sub2]) 
	else:
		if op == op1 == op2:
			return (op,ssub1+ssub2)
		elif op == op1:
			return (op,ssub1+[sub2])
		elif op == op2:
			return (op,ssub2+[sub1])
		else:
			return (op,[sub1,sub2])
	

test = "hello OR hi AND test AND shit AND NOT really"
print test
print parse_tokens(test.split())


