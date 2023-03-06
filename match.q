\d .match

/ stable marriage problem (SMP) aka Gale-Shapley Algorithm
/ matrix of (W)omen and (M)en's preferences. vector of resulting
/ (p)airs can be passed in as atom, and will be resized appropriately
smp:{[pMW]
 p:pMW 0;n:count M:pMW 1;W:pMW 2;
 mi:(p:n#p)?0N; / find unengaged man
 if[n=mi;:pMW]; / everyone married
 w:W wi:first m:M mi;           / find preferred woman
 / if already engaged, and this man is better, renege
 if[not n=ei:p?wi;if[(</)w?(mi;ei);M:@[M;ei;1_];p[ei]:0N]];
 p[mi]:wi;                      / get engaged
 W[wi]:first c:(1+w?mi) cut w;  / remove worse men
 M:@[M;last c;except[;wi]];     / remove unavailable women
 (p;M;W)}

prune:{[p;R]
 R:@[R;p;{(1+x?y) cut x};i:til count R];
 R:p,'@[R[;0];R[;1];{x except y};i];
 (p;R)}

/ stable roommates problem (SRP)
srp1:{[pRi]
 pRi:smp[pRi 1;pRi];
 pRi}

srp:{[R]
 rP:srp1 over (count[R]#0N;R);
 if[1=all count each last pR:prune . srs;:pR];
 pR}


