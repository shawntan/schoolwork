#!/usr/bin/python2


phil = [ "I Don't Want To Go",
		"A Groovy Kind Of Love",
		"You Can't Hurry Love",
		"This Must Be Love",
		"Take Me With You"]
supply = [
		"All Out Of Love",
		"Here I Am",
		"I Remember Love",
		"Love Is All",
		"Don't Tell Me"
		]

words = set()

phil = [s.lower() for s in phil]
supply = [s.lower() for s in supply]

phil_freq = {}
for s in phil:
	for w in s.split():
		phil_freq[w] = phil_freq[w] + 1 if w in phil_freq else 1 
		words.add(w)

supply_freq = {}
for s in supply:
	for w in s.split():
		supply_freq[w] = supply_freq[w] + 1 if w in supply_freq else 1
		words.add(w)


print "Words: "+ str(len(words))
print "Phil Collins words: " + str(sum(phil_freq[k] for k in phil_freq))
print "Air Supply words: " + str(sum(supply_freq[k] for k in supply_freq))


words2 = set()
phil = ["START "+ s + " END" for s in phil]
supply = ["START "+ s + " END" for s in supply]

phil_2freq = {}
for s in phil:
	sent = s.split()
	for i in range(len(sent)-1):
		w = sent[i] + " " + sent[i+1]
		phil_2freq[w] = phil_2freq[w] + 1 if w in phil_2freq else 1 
		words2.add(w)

supply_2freq = {}
for s in supply:
	sent = s.split()
	for i in range(len(sent)-1):
		w = sent[i] + " " + sent[i+1]
		supply_2freq[w] = supply_2freq[w] + 1 if w in supply_2freq else 1 
		words2.add(w)

print "N-grams: "+ str(len(words2))
print "Phil Collins bigrams: " + str(sum(phil_2freq[k] for k in phil_2freq))
print "Air Supply bigrams: " + str(sum(supply_2freq[k] for k in supply_2freq))

def test2(s,db):
	sent = s.split()
	combined_prob = 1
	for i in range(len(sent)-1):
		w = sent[i] + " " + sent[i+1]
		try:
			p = (supply_2freq[w] + 1.0)/float(db[w] + len(words2))
		except KeyError:
			p = 1/2.0
		combined_prob *= p
	return combined_prob
