\l util.q
\l matching.q

/ stable marriage problem

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf

S:(1+til count S)!S:get each read0 `male.txt
R:(1+til count R)!R:get each read0 `female.txt
.util.assert[3 1 7 5 4 6 8 2] value first sms:.matching.smp[S;R]
.util.assert[3 1 7 5 4 6 8 2] first each value sms 1

/ rosetta code inputs: https://rosettacode.org/wiki/Stable_marriage_problem

lf:`$"," vs' (!/) @[;0;`$] flip ":" vs' read0 ::
F:lf `rfemale.txt
M:lf `rmale.txt
e:`ivy`cath`dee`fay`jan`bea`gay`eve`hope`abi / engagements
.util.assert[key[M]!e] first .matching.smp[M;F]
