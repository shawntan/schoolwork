import sys,getopt
import linecache
import sys
import getopt
def get_lines(l,gs_file,pred_file):
	gs = linecache.getline(gs_file,  int(l)).split()
	pd = linecache.getline(pred_file, int(l)).split()
	return gs,pd

def evaluate(gs,pd):
	total = len(gs)
	retrieved = 0
	relevant  = 0

	result = []
	for p in pd:
		retrieved += 1
		if p in gs: relevant += 1
		result.append((
			100*float(relevant)/total,
			100*float(relevant)/retrieved
		))
	mp = 0
	for i in reversed(range(len(result))):
		r,p = result[i]
		if p >= mp: mp = p
		else: result[i] = (r,mp)
	return result

if __name__=='__main__':
	options = sys.argv[1:]
	opts,_ = getopt.getopt(options,"g:p:l:o:")
	params = dict(opts)

	gs,pd = get_lines(params['-l'],params['-g'],params['-p'])
	result = evaluate(gs,pd)
	i = 1
	FILE = open(params['-o'],'w')
	for r,p in result:
		FILE.write("Precision at Rank %d: %2.2f\n" % (i,p))
		FILE.write("Recall at Rank %d: %2.2f\n" % (i,r))
#		FILE.write("F1 at Rank %d: %2.2f\n" % (i, 2*(p*r/(p+r))))
		i+=1
	FILE.close()
