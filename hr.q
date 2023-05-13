\l util.q
\l matching.q

-1 "hospital resident (HR) problem";

/ https://matching.readthedocs.io/en/latest/discussion/hospital_resident
-1 "worked example from the matching python library";
-1 "5 residents: Ada, Sam, Dani, Luc, Jo";
r:`A`S`D`L`J
-1 "3 hospitals Mercy, City, General";
h:`M`C`G
-1 "each with capacity 2";
c:2 2 2

-1 "resident preferences";
show R:r!(1#`C;`C`M;`C`M`G;`M`C`G;`C`G`M)
-1 "hospital preferences";
show H:h!(`D`L`S`J;`D`A`S`L`J;`D`J`L)
-1 "capacities";
show C:h!c

-1 "matching can be resident-optimal";
show first hrHR:.matching.hrr[C;H;R]
.util.assert[(`M`C`G!(`S`L;`A`D;1#`J);`A`S`D`L`J!`C`M`C`M`G)] 2#hrHR

-1 "or hospital-optimal";
show first hrHR:.matching.hrh[C;H;R]
.util.assert[(`M`C`G!(`L`S;`D`A;1#`J);`A`S`D`L`J!`C`M`C`M`G)] 2#hrHR

-1 "which result in the same matches for this problem";

-1 "implementation accuracy is confirmed by testing against a larger dataset";
-1 "resdient preferences";
show R:`$.j.k raze read0 `:residents.json
-1 "hospital preferences";
show H:`$.j.k raze read0 `:hospitals.json
-1 "hospital capacities";
show C:.j.k raze read0 `:capacities.json

-1 "resident-optimal matches";
hrHR:.matching.hrr[C;H;R]
-1 "python resident-optimal implementation inserts matches in preferred order";
-1 "this doesn't change the matches but forces us to sort before comparing";
show hrHR[0]:H[key hrHR 0]{y iasc x?y}' hrHR 0 / resort by hospital prefs
.util.assert[1b] all raze hrHR[0]=`$.j.k raze read0 `:resident_solution.json

-1 "python hospital-optimal matches (as in q) are sorted in matched order";
hrHR:.matching.hrh[C;H;R]
.util.assert[1b] all raze hrHR[0]=`$.j.k raze read0 `:hospital_solution.json
