\l matching.q

-1 "stable roommates (SR) problem";
-1 "simple example from pythong 'matching' library";
/ https://matching.readthedocs.io/en/latest/discussion/stable_roommates
-1 "the algorithm requires a single dictionary:"
-1 "roommate preferences for every *other* participant";
R:([A:`D`B`C`E`F;B:`A`D`C`F`E;C:`B`E`F`A`D])
R,:([D:`E`B`C`F`A;E:`F`C`D`B`A;F:`C`D`E`B`A])
show R
-1 "assignments";
show A:([A:`B;B:`A;C:`E;D:`F;E:`C;F:`D])
(1b):A ~ first .matching.sr R

-1 "wikipedia has sample roommate data";
/ https://en.wikipedia.org/wiki/Stable_roommates_problem
-1 "roommate preferences";
show R:(1+til count R)!R:get each read0 `wmate.txt
-1 "stable matches are symmetric";
show a:first .matching.sr R
-1 "assignments";
show A:key[R]!6 4 5 2 3 1
(1b):A ~ a

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf

-1 "example from Joe Hidakatsu's 2016 paper";
-1 "Structure of the Stable Marriage and Stable Roommate Problems and Applications";
show R:(1+til count R)!R:get each read0 `mate.txt
-1 "Irving's algorithm has two phases";
-1 "phase 1 returns the results from the stable marriage solution using Gale-Shapley";
show first 1_aR:.matching.sr R
-1 "phase 2 removes unstable cycles until only a single stable match exists";
(-1 .Q.s::) each 2_aR;
-1 "assignments";
A:key[R]!4 3 2 1 7 8 5 6
(1b):A ~ first aR
