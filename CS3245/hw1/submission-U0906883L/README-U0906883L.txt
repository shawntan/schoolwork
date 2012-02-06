This is the README file for U096883L's submission
Email: u0906883@nus.edu.sg

== General Notes about this assignment ==

ngram_model() creates a dictionary that stores the ngram frequency
for different categories, as well as a total word count for each
category.

During testing test_url tests a single url to check its classification.
This is done using +1 smoothing without padding. 

Running an experiment yielded the following results:

							Accuracy
Original Specification		85%
Stripping punctuation (SP)	90%
Stripping numbers (SN)		85%
Lowercase (L)				85%
SN + SP						90%
SN + SP + L					90%
SN + SP + L + Padding		85%


It should be noted that these statistics were taken on a test set of 20 URLs. As
such, these results may not be conclusive. However, we can see that stripping
out punctuation does help the accuracy of the classifier in this particular
case. Curiously, padding the urls gives a poorer result.

Running some experiments by varying N yielded the following results, again
using the same 20 test cases:

N value			Accuracy
1				35%
2				80%
3				85%
4				85%
5				85%
6				90%

We can see that in this sample, 6-grams work better than 5-grams to classify
URLs.

My implementation eventually involved replacing all punctuation with a '-'.
This gave an accuracy of 95% on the 20 instance test set.

== Files included with this submission ==

build_test_LM.py
essay-U096883L.txt
README-U096883L.txt

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
