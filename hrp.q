\l match.q

/ hospital resident problem

/ Ada, Sam, Dani, Luc, Jo
r:`A`S`D`L`J
/ Mercy, City, General
h:`M`C`G
/ capacity
c:2 2 2

R:(1#`C;`C`M;`C`M`G;`M`C`G;`C`G`M)
H:(`D`L`S`J;`D`A`S`L`J;`D`J`L)

rhRH:.match.hrp[c] over (count[R]#0N;(count[H];0)#0N;h?R;r?H)
(`C`C`M`M`G;(`D`L;`A`S;1#`J))~(h;r)@'2#rhRH
(r;H;r;h)!'(h;r;h;r)@' rhRH
r!R
h!H

rhRH:.match.hrp2[c] over (count[R]#0N;(count[H];0)#0N;h?R;r?H)
(`C`M`C`M`G;(`L`S;`D`A;1#`J))~(h;r)@'2#rhRH
(r;H;r;h)!'(h;r;h;r)@' rhRH
r!R
h!H
