This is the README file for U096883L's submission

== General Notes about this assignment ==

An additional class was added to support phrasal queries called
PhrasePostings. The class accepts a list of tokens in its
constructor, and performs the merging by passing in a lambda
function that checks if the second word comes directly after the
first. This is done pairwise for every bigram in the search phrase.

The merging is done in the same way if the queries are
not phrasal, with the default comparator function always
returning a match if the documents match.

Since the postings list contains a new entry for every possible
appearance of the term in a document, search.py now ensures that
all entries are unique before printing the results into a file.

As with the previous assignment, writepostings.py provides
index.py with the functionality to read/write to the dictionary
and postings file, abstracting away the steps of opening a file,
saving the file, and writing out the skip pointers and
dictionary once its done.

postings.py offers the same functionality for search.py with its
various sub-classes of the Postings class. They allow search.py
to construct a tree from the query, which is optimised to
provide the fastest search time possible. Since not all the data
is read into the memory, the sorting of which query is performed
first is done based on size estimates from the dictonary.


== Files included with this submission ==

dictionary.txt
	Dictionary entries that store the number of times the word has been seen
and the byte location of which the first entry is stored.
	Entries in this file are of the following format:
	count	postings_pointer	dict_pointer

postings.txt
	Postings list as described in the previous section.

index.py
writepostings.py
	These two files provide the indexing functionality. 

search.py
postings.py
	These two files provide the searching capability.


== Statement of individual work ==

Please initial one of the following statements.

[X] I, U096883L, certify that I have followed the CS 3245 Information
Retrieval class guidelines for homework assignments.  In particular, I
expressly vow that I have followed the Facebook rule in discussing
with others in doing the assignment and did not take notes (digital or
printed) from the discussions.  

[ ] I, U096883L, did not follow the class rules regarding homework
assignment, because of the following reason:

<Please fill in>

I suggest that I should be graded as follows:

<Please fill in>

== References ==

<Please list any websites and/or people you consulted with for this
assignment and state their role>
