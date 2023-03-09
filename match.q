\d .match

/ stable marriage problem (SMP) aka Gale-Shapley Algorithm

/ given (e)ngagement vector (can be atomic 0N) and (M)en and (W)omen
/ matrices, find next engagement, remove undesirable men and unavailable
/ women.  a single roommate matrix is assumed if a (W)omen matrix is not
/ provide.
phase1:{[eMW]
 e:eMW 0;n:count M:eMW Mi:1;W:eMW Wi:-1+count eMW;
 mi:(e:n#e)?0N;          / find single man
 if[n=mi;:eMW];          / everyone is engaged
 if[any 0=count each M;'`unstable];
 w:W wi:first m:M mi;    / find preferred woman
 / if already engaged, and this man is better, renege
 if[not n=ei:e?wi;if[(</)w?(mi;ei);eMW:.[eMW;(Mi;ei);1_];e[ei]:0N]];
 e[mi]:wi; eMW[0]:e;                / get engaged
 eMW[Wi;wi]:first c:(0;1+w?mi) cut w; / remove undesirable men
 eMW:.[eMW;(Mi;c 1);except[;wi]];   / remove unavailable women
 eMW}

smp:{[M;W]
 u:asc (union/) over (M;W);
 MW:u 1_phase1 over (count[M]#0N;u?M;u?W);
 MW}

link:{[R;l] l,enlist (last R i;i:R[last[l] 0;1])}
cycle:{[R;l]
 c:{count[x]=count distinct x} link[R]/ l;
 c:(1+c ? last c)_c;
 c}

phase2:{[R]
 if[any 0=c:count each R;'`unstable];
 if[all 1=c;:R];
 i:(c>=2)?1b;
 c:cycle[R] enlist (i;R[i;0]);
 R:@[R;c[;0];1_];
 R:{[R;i;j](i;j);R[i]:first c:(0;1+r?j) cut r:R i;R:@[R;c 1;except[;i]];R }/[R;c[;1];-1 rotate c[;0]];
 R}

srp:{[R]
 u:asc (union/) R;
 R:last eR:phase1 over (count[R]#0N;u?R);
 R:u phase2 scan R;
 R}
