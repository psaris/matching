\l util.q
\l matching.q

/ stable roommates problem

/ https://en.wikipedia.org/wiki/Stable_roommates_problem
/ https://www.cs.cmu.edu/afs/cs.cmu.edu/academic/class/15251-f10/Site/Materials/Lectures/Lecture21/lecture21.pdf
R:(1+til count R)!R:get each read0 `wmate.txt
.util.assert[6 4 5 2 3 1] value first srs:.matching.srp R

/ Structure of the Stable Marriage and Stable Roommate Problems and Applications
/ Joe Hidakatsu
/ University of South Carolina

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf
R:(1+til count R)!R:get each read0 `mate.txt
.util.assert[4 3 2 1 7 8 5 6] value first srs:.matching.srp R
