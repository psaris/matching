\l match.q

/ stable roommates problem

/ https://en.wikipedia.org/wiki/Stable_roommates_problem
/ https://www.cs.cmu.edu/afs/cs.cmu.edu/academic/class/15251-f10/Site/Materials/Lectures/Lecture21/lecture21.pdf
R:get each read0 `wmates.txt
4 6 2 5 3 1~first each first srs:.match.srp R
6 4 5 2 3 1~first each last srs

/ Structure of the Stable Marriage and Stable Roommate Problems and Applications
/ Joe Hidakatsu
/ University of South Carolina

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf
R:get each read0 `mates.txt
4 3 2 1 7 8 5 6~first each last srs:.match.srp R

