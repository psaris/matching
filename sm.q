\l util.q
\l matching.q

-1 "stable marriage (SM) problem";

/ https://matching.readthedocs.io/en/latest/discussion/stable_marriage
-1 "the algorithm requires two dictionaries:"
-1 "suitor preferences"
show S:`A`B`C!(`D`E`F;`D`F`E;`F`D`E)
-1 "reviewer preferences";
show R:`D`E`F!(`B`C`A;`A`C`B;`C`B`A)
-1 "engagements";
show E:`A`B`C!`E`D`F
.util.assert[E] first .matching.sm[S;R]

-1 "example from Joe Hidakatsu's 2016 paper";
/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf
-1 "Structure of the Stable Marriage and Stable Roommate Problems and Applications";
-1 "suitor preferences";
show S:(1+til count S)!S:get each read0 `male.txt
-1 "reviewer preferences";
show R:(1+til count R)!R:get each read0 `female.txt
-1 "stable matches";
first eSR:.matching.sm[S;R]
-1 "remaining suitor preferences";
show eSR 1
-1 "remaining reviewer preferences";
show eSR 2
e:key[S]!3 1 7 5 4 6 8 2
.util.assert[e] eSR 0
-1 "suitors get optimal matches";
.util.assert[e] first each eSR 1
-1 "reviewers get pessimal matches";
.util.assert[e] (!/) (value;key)@\: asc last each eSR 2

-1 "reviewer can improve matching w/ truncation";
-1 "some new rankings are better than the original rankings";
eSRs:.matching.sm[S] each 1 @[;7;6#]\ R
show r:(,'/) (R?'(!/)(value;key)@\: first ::) each eSRs
.util.assert[1b] any (>/) flip value r

/ rosetta code inputs: https://rosettacode.org/wiki/Stable_marriage_problem
-1 "rosetta code has sample male/female data we can use";
lf:`$"," vs' (!/) @[;0;`$] flip ":" vs' read0 ::
-1 "female preferences";
show F:lf `rfemale.txt
-1 "male preferences";
show M:lf `rmale.txt
e:key[M]!`ivy`cath`dee`fay`jan`bea`gay`eve`hope`abi / engagements
-1 "male-optimal matches";
show first eSR:.matching.sm[M;F]
.util.assert[e] eSR 0
-1 "female-optimal results are equivalent";
.util.assert[key eSR 0] value e:asc first .matching.sm[F;M]
show e;
-1 "which means there is only one stable match";
