\l util.q
\l matching.q

-1 "hospital resident (HR) problem";

-1 "simple example from python 'matching' library";
/ https://matching.readthedocs.io/en/latest/discussion/hospital_resident
-1 "the algorithm requires 3 dictionaries:";
-1 "resident preferences";
show R:`A`S`D`L`J!(1#`C;`C`M;`C`M`G;`M`C`G;`C`G`M)
-1 "hospital preferences";
show H:`M`C`G!(`D`L`S`J;`D`A`S`L`J;`D`J`L)
-1 "hospital capacities";
show C:key[H]!2 2 2

-1 "allocations";
show A:`M`C`G!(`L`S;`D`A;1#`J)

-1 "resident-optimal matches";
show first hrHR:.matching.hrr[C;H;R]
-1 "python resident-optimal implementation inserts matches in preferred order";
-1 "this doesn't change the matches but forces us to sort before comparing";
hrHR:@[hrHR;0;H[key hrHR 0] inter'] / sort by hospital prefs
.util.assert[A] first hrHR

-1 "python hospital-optimal matches (as in q) are sorted in matched order";
show first hrHR:.matching.hrh[C;H;R]
.util.assert[A] first hrHR
-1 "which result in the same matches for this problem";

-1 "worked example from the matching python library";
/ https://matching.readthedocs.io/en/latest/tutorials/hospital_resident
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
hrHR:@[hrHR;0;H[key hrHR 0] inter'] / sort by hospital prefs
.util.assert[hrHR 0] `$.j.k raze read0 `:resident_solution.json

-1 "python hospital-optimal matches (as in q) are sorted in matched order";
hrHR:.matching.hrh[C;H;R]
.util.assert[hrHR 0] `$.j.k raze read0 `:hospital_solution.json
