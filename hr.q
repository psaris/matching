\l matching.q

-1 "hospital resident (HR) problem";

-1 "simple example from python 'matching' library";
/ https://matching.readthedocs.io/en/latest/discussion/hospital_resident
-1 "the algorithm requires 3 dictionaries:";
-1 "resident preferences";
show R:([A:1#`C;S:`C`M;D:`C`M`G;L:`M`C`G;J:`C`G`M])
-1 "hospital preferences";
show H:([M:`D`L`S`J;C:`D`A`S`L`J;G:`D`J`L])
-1 "hospital capacities";
show C:key[H]!2 2 2

-1 "allocations";
show A:([M:`L`S;C:`D`A;G:1#`J])

-1 "resident-optimal matches";
show first hrHR:.matching.hrr[C;H;R]
-1 "python resident-optimal implementation inserts matches in preferred order";
-1 "this doesn't change the matches but forces us to sort before comparing";
hrHR:@[hrHR;0;H[key hrHR 0] inter'] / sort by hospital prefs
(1b):A ~ first hrHR

-1 "python hospital-optimal matches (as in q) are sorted in matched order";
show first hrHR:.matching.hrh[C;H;R]
(1b):A ~ first hrHR
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
(1b):hrHR[0] ~ `$.j.k raze read0 `:resident_solution.json

-1 "python hospital-optimal matches (as in q) are sorted in matched order";
hrHR:.matching.hrh[C;H;R]
(1b):hrHR[0] ~ `$.j.k raze read0 `:hospital_solution.json
