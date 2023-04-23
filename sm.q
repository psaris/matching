\l util.q
\l matching.q

/ stable marriage (SM) problem

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf

S:(1+til count S)!S:get each read0 `male.txt
R:(1+til count R)!R:get each read0 `female.txt
e:3 1 7 5 4 6 8 2
.util.assert[e] value first eSR:.matching.sm[S;R]
.util.assert[e] first each value eSR 1

/ demonstrate that reviewer can improve matching w/ truncation
eSRs:.matching.sm[S] each 1 @[;7;6#]\ R
.util.assert[1b] any (>/) (R?'{value[x]!key x} first ::) each eSRs

/ rosetta code inputs: https://rosettacode.org/wiki/Stable_marriage_problem

lf:`$"," vs' (!/) @[;0;`$] flip ":" vs' read0 ::
F:lf `rfemale.txt
M:lf `rmale.txt
e:`ivy`cath`dee`fay`jan`bea`gay`eve`hope`abi / engagements
.util.assert[key[M]!e] first eSR:.matching.sm[M;F]

/ there is only one stable match and it is optimal for M and F
.util.assert[key eSR 0] value asc first .matching.sm[F;M]
