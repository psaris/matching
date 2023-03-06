\l match.q
M:get each read0 `male.txt
W:get each read0 `female.txt
m:1+til 8
w:1+til 8
3 1 7 5 4 6 8 2~m first sms:.match.smp over (0N;w?M;w?W)
pMW:(0N;m?M;w?W)
pMW:.match.smp pMW
\
m:`A`B`C
w:`X`Y`Z
M:(`A`B`C;`A`C`B;`B`C`A)
W:(`Y`X`Z;`X`Z`Y;`Z`X`Y)
m?M
smp[m?M] over pM:(0N;w?W)
`Y`X`Z~w first smp[m?M] over pM:(0N;w?W)
`B`A`C~m first smp[w?W] over pM:(0N;m?M)

([]w:`m`M)!(`$string w)!/:m smp[w?W] over (0N;m?M)
([]m:`w`W)!m!/:w smp[m?M] over (0N;w?W)

/ no stable solution
r:`A`B`C`D
R:(`B`C`D;`C`A`D;`A`B`D;`A`B`C)
([]r:`r`R)!r!/:r -1_smp[r?R] over (0N;r?R)

/ worked example
r:1 2 3 4 5 6
R:(3 4 2 6 5; 6 5 4 1 3; 2 4 5 1 6; 5 2 3 6 1; 3 1 2 4 6; 5 1 3 4 2)
/ stable roommate solution
srs:last srp scan (count[r]#0N;r?R)

srs1:(4 2 6;6 5 4 1 3;2 4 5;5 2 3 6 1;3 2 4;1 4 2)
srs1~r last srp r?R

/ for each broken engagement need to remove both sets of preferences
