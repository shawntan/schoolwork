This is the README file for U096883L's submission

(If this is a 2 person team submission, please replace the above
U096883L with the appropriate matric numbers concatenated together).

== General Notes about this assignment ==

Indexing (index.py & writepostings.py)
--------
Indexing is done by getting all unique words in a document, and then writing
each term out to the postings file in the following format:

word	doc_id	next_pointer	[skip_doc_id]	[skip_pointer]

Here, pointers are the byte position in the file which the entry is located.
A dictionary of terms to last seen position is maintained -- every time a 
new term is written to the postings file, this is updated. A dictionary
containing each term's count is also maintained. Once the entire directory
of documents are indexed,
the dictionary is written out to file, and the entries in the posting retraced
to fill in the skipped doc_id and skip pointer at the sqrt(n) positions of
each document listing.

Access (postings.py)
------
Since the postings list is written from top to bottom, and only the previous
occurrence is tracked, the list is effectively stored backwards, with the
dictionary pointing to the last document with the given word. Because of this,
the corpus is indexed in reverse, with the largest doc_id first.

The class Postings and it's subclasses provide a python iterator that
enumerates through the individual items in each posting list. This makes use of
seek() and the stored pointer to obtain each successive item in the list. As a
result, the process of accessing the list for a given term requires many disk
reads, which slows down the query process.

Query (search.py)
----- 
The parse() method inside search.py first preprocesses the query, then splits
it up into individual tokens. This is then parsed into a query tree, optimised
so that queries with estimated smaller sizes are processed first before larger
ones. This results in faster query evaluation times. The MergePostings class provide
a way to combine two sub-queries together without pre-evaluating the
sub-queries. Essentially, each doc_id is processed as they are read from the
file. The merge() method in postings.py implements the merge algorithm in a
more general form, allowing for queries like:

1.	A AND B
2.	A AND NOT B
3.	NOT A AND B
4.	A OR B

Experiments
-----------
The sample query file included with the submission runs in 0.492s on my
laptop.



== Files included with this submission ==

dictionary.txt
	Dictionary entries that store the number of times the word has been seen
and the byte location of which the first entry is stored.
	Entries in this file are of the following format:
	term	count	pointer	

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
