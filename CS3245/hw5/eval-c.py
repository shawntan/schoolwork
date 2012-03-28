import sys,getopt

gold_standard = {}

def index_gs(cat,url):
	gold_standard.setdefault(cat,set()).add(url)


def read_gold_standard(filename):
	for line in open(filename,'r'):
		tup = line.split()
		index_gs(tup[0],tup[1])

if __name__=='__main__':
	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"g:p:c:o:")
	params = dict(opts)
	read_gold_standard(params['-g'])
	print gold_standard
