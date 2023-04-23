\l util.q
\l matching.q

/ hospital resident (HR) problem

/ https://matching.readthedocs.io/en/latest/discussion/hospital_resident

/ Ada, Sam, Dani, Luc, Jo
r:`A`S`D`L`J
/ Mercy, City, General
h:`M`C`G
/ capacity
c:2 2 2

R:r!(1#`C;`C`M;`C`M`G;`M`C`G;`C`G`M)
H:h!(`D`L`S`J;`D`A`S`L`J;`D`J`L)
C:h!c

hrHR:.matching.hrr[C;H;R]
.util.assert[(`M`C`G!(`S`L;`A`D;1#`J);`A`S`D`L`J!`C`M`C`M`G)] 2#hrHR

hrHR:.matching.hrh[C;H;R]
.util.assert[(`M`C`G!(`L`S;`D`A;1#`J);`A`S`D`L`J!`C`M`C`M`G)] 2#hrHR

R:`$.j.k raze read0 `:residents.json
H:`$.j.k raze read0 `:hospitals.json
C:.j.k raze read0 `:capacities.json
hrHR:.matching.hrr[C;H;R]
hrHR[0]:H[key hrHR 0]{y iasc x?y}' hrHR 0 / resort by hospital prefs
.util.assert[1b] all raze hrHR[0]=`$.j.k raze read0 `:resident_solution.json

hrHR:.matching.hrh[C;H;R]
.util.assert[1b] all raze hrHR[0]=`$.j.k raze read0 `:hospital_solution.json
