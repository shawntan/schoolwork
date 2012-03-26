This is the README file for U096883L's submission

== General Notes about this assignment ==

In order to evaluate the query, an OR operation was performed on
all of the terms in the query. postings.py was modified to
include the number of times the term occured within each
document. The postings lists of these terms were merged, and
common terms have their term counts merged as well. For example,
a document from the "money" postings list may have:

	(1234, {'money':6})

and another entry from the postings list of "donald" may be:

	(1234, {'donald':3})

these would result in (1234,{'donald':3 , 'money':6}).

These dictionaries will be used in the final similarity
calculation with the query, which is also represented by a
dictionary with term counts.

If a term has no documents containing it, then the OR operation
would deal with it by simply not retrieving any documents for
that term.

If the document doesn't have a term that is contained in the
query, then a score of 0 for that document will be given for
that term.


== Files included with this submission ==

dictionary.txt
	Dictionary entries that store the number of times the word has been seen
and the byte location of which the first entry is stored.
	Entries in this file are of the following format:
	count	postings_pointer	dict_pointer	tf_d

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
