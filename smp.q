\l match.q

/ stable marriage problem

M:(1+til count M)!M:get each read0 `male.txt
W:(1+til count W)!W:get each read0 `female.txt
3 1 7 5 4 6 8 2~value first sms:.match.smp[M;W]
3 1 7 5 4 6 8 2~first each value sms 1
