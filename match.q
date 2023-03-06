\d .match

/ stable marriage problem (SMP) aka Gale-Shapley Algorithm

/ given (e)ngagement vector (can be atomic 0N) and (M)en and (W)omen
/ matrices, find next engagement, remove undesirable men and unavailable
/ women.  a single roommate matrix is assumed if a (W)omen matrix is not
/ provide.
engage:{[eMW]
 e:eMW 0;n:count M:eMW Mi:1;W:eMW Wi:-1+count eMW;
 mi:(e:n#e)?0N;          / find single man
 if[n=mi;:eMW];          / everyone is engaged
 if[any 0=count each M;'`unstable];
 w:W wi:first m:M mi;    / find preferred woman
 / if already engaged, and this man is better, renege
 if[not n=ei:e?wi;if[(</)w?(mi;ei);eMW:.[eMW;(Mi;ei);1_];e[ei]:0N]];
 e[mi]:wi; eMW[0]:e;                / get engaged
 eMW[Wi;wi]:first c:(1+w?mi) cut w; / remove undesirable men
 eMW:.[eMW;(Mi;c 1);except[;wi]];   / remove unavailable women
 eMW}

smp:{[M;W]
 u:asc (union/) over (M;W);
 eMW:u engage over (count[M]#0N;u?M;u?W);
 eMW}

srp:{[R]
 u:asc (union/) R;
 eR:u engage over (count[R]#0N;u?R);
 eR}


