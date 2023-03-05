\d .match

/ stable marriage problem (SMP) aka Gale-Shapley Algorithm
/ matrix of (W)omen and (M)en's preferences. vector of resulting
/ (p)airs can be passed in as atom, and will be resized appropriately
smp:{[W;pM]
 if[n=mi:(p:(n:count W)#pM 0)?0N;:pM]; / find unmarried man or return
 w:W wi:first m:(M:pM 1) mi;           / find preferred woman
 / if woman is unmarried, marry. else allow woman to upgrade
 p:$[n=hi:p?wi;@[p;mi;:;wi];(</)w?i:(mi;hi);@[p;i;:;(wi;0N)];p];
 M:@[M;mi;1_];                  / this woman has already been proposed to
 (p;M)}

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


