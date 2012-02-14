
def prob(n):
	if n == 1: return 1
	else:
		p = prob(n-1)
		return (1.0/float(n))*p

print prob(52)
