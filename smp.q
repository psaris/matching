\l match.q

/ stable marriage problem

/ https://people.math.sc.edu/czabarka/Theses/HidakatsuThesis.pdf

S:(1+til count S)!S:get each read0 `male.txt
R:(1+til count R)!R:get each read0 `female.txt
3 1 7 5 4 6 8 2~value first sms:.match.smp[S;R]
3 1 7 5 4 6 8 2~first each value sms 1
