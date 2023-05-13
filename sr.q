\l util.q
\l matching.q

-1 "stable roommates (SR) problem";
/ https://en.wikipedia.org/wiki/Stable_roommates_problem
/ https://www.cs.cmu.edu/afs/cs.cmu.edu/academic/class/15251-f10/Site/Materials/Lectures/Lecture21/lecture21.pdf

-1 "wikipedia has sample roommate data";
-1 "roommates must rank all *other* participants";
show R:(1+til count R)!R:get each read0 `wmate.txt
-1 "stable matches are symmetric";
show a:first .matching.sr R
.util.assert[key[R]!6 4 5 2 3 1] a

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf

-1 "example from Joe Hidakatsu's 2016 paper";
-1 "Structure of the Stable Marriage and Stable Roommate Problems and Applications";
show R:(1+til count R)!R:get each read0 `mate.txt
-1 "Irving's algorithm has two phases";
-1 "phase 1 returns the results from the stable marriage solution using Gale-Shapley";
show first 1_aR:.matching.sr R
-1 "phase 2 removes unstable cycles until only a single stable match exists";
(-1 .Q.s::) each 2_aR;
.util.assert[key[R]!4 3 2 1 7 8 5 6] aR 0
