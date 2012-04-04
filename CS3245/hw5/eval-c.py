import sys,getopt

gold_standard = {}
reverse_index = {}
tp = {}
fp = {}
fn = {}
def index_gs(cat,url):
	gold_standard.setdefault(cat,set()).add(url)
	reverse_index[url] = cat


def read_gold_standard(filename):
	for line in open(filename,'r'):
		tup = line.split()
		index_gs(tup[0],tup[1])

def read_predictions(filename):
	for line in open(filename,'r'):
		tup = line.split()
		if tup[1] in gold_standard[tup[0]]:
			tp[tup[0]] += 1
		else:
			fp[tup[0]] += 1
			fn[reverse_index[tup[1]]] += 1

def read_classes(filename):
	for line in open(filename,'r'):
		tp[line.strip()] = 0
		fp[line.strip()] = 0
		fn[line.strip()] = 0

if __name__=='__main__':
	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"g:p:c:o:")
	params = dict(opts)
	read_gold_standard(params['-g'])
	read_classes(params['-c'])
	read_predictions(params['-p'])


	FILE = open(params['-o'],'w')
	for i in tp:
		precision = 100*float(tp[i])/float(tp[i] + fp[i])
		recall = 100*float(tp[i])/float(tp[i] + fn[i])
		FILE.write("Precision of %s: %02.2f\n" % (i,precision))
		FILE.write("Recall of %s: %02.2f\n" % (i,precision))
		FILE.write("F1 of %s: %2.2f\n" % (i, 2*(precision*recall/(precision+recall))))
