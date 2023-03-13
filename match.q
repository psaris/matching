\d .match

/ drop first occurrence of x from y
drop:{y _ y?x}

/ stable marriage problem (SMP) aka Gale-Shapley Algorithm

/ given (e)ngagement vector and (M)en and (W)omen matrices, find next
/ engagement, remove undesirable men and unavailable women.  a single
/ roommate matrix is assumed if a (W)omen matrix is not provide.
phase1:{[eMW]
 n:count e:eMW 0;M:eMW Mi:1;W:eMW Wi:-1+count eMW;
 mi:e?0N;                       / find single man
 if[n=mi;:eMW];                 / everyone is engaged
 if[any 0=count each M;'`unstable];
 w:W wi:first m:M mi;    / find preferred woman
 / if already engaged, and this man is better, renege
 if[not n=ei:e?wi;if[(</)w?(mi;ei);eMW:.[eMW;(Mi;ei);1_];e[ei]:0N]];
 e[mi]:wi; eMW[0]:e;                  / get engaged
 eMW[Wi;wi]:first c:(0;1+w?mi) cut w; / remove undesirable men
 eMW:.[eMW;(Mi;c 1);drop wi];         / remove unavailable women
 eMW}

smp:{[M;W]
 uw:asc (union/) M;
 um:asc (union/) W;
 MW:(uw;um)@'1_phase1 over (count[M]#0N;uw?M;um?W);
 MW}

link:{[R;l] l,enlist (last R i;i:R[last[l] 0;1])}
cycle:{[R;l]
 c:{count[x]=count distinct x} link[R]/ l;
 c:(1+c ? last c)_c;
 c}

/ mutually reject i and j
reject:{[R;i;j]
 R[i]:first c:(0;1+r?j) cut r:R i;
 R:@[R;c 1;drop i];
 R}

phase2:{[R]
 if[any 0=c:count each R;'`unstable];
 if[all 1=c;:R];
 i:(c>=2)?1b;
 c:cycle[R] enlist (i;R[i;0]);
 R:@[R;c[;0];1_];
 R:reject/[R;c[;1];-1 rotate c[;0]];
 R}

srp:{[R]
 ur:asc (union/) R;
 R:last eR:phase1 over (count[R]#0N;ur?R);
 R:ur phase2 scan R;
 R}

/ https://matching.readthedocs.io/en/latest/discussion/hospital_resident

/ given hospital (c)apacity and (r)esident matches, (h)ospital matches,
/ (R)esident and (H)ospital preference matrices, return the resident-optimal
/ matches
hrp:{[c;rhRH]
 r:rhRH 0;h:rhRH 1;R:rhRH 2;H:rhRH 3;
 if[null ri:first where null[r]&0<count each R;:rhRH]; / nothing to match
 hp:H hi:first R ri;                                   / preferred hospital
 if[not ri in hp;:.[rhRH;(2;ri);1_]];                  / hospital rejects
 ch:count ris:h[hi],:ri; r[ri]:hi;                     / match
 if[c[hi]<ch;wri:hp max hp?ris;ris:h[hi]:drop[wri;ris];hp:H[hi]:drop[wri;hp];r[wri]:0N;R:@[R;wri;1_];ch-:1];
 if[c[hi]=ch;H[hi]:first c:(0;1+max hp?ris) cut hp;R@[R;c 1;drop hi]];
 (r;h;R;H)}

/ given hospital (c)apacity and (r)esident matches, (h)ospital matches,
/ (R)esident and (H)ospital preference matrices, return the hospital-optimal
/ matches
hrp2:{[c;rhRH]
 r:rhRH 0;h:rhRH 1;R:rhRH 2;H:rhRH 3;
 if[null hi:first where (c>count each h)&0<count each H;:rhRH]; / nothing to match
 rp:R ri:first H[hi] except h[hi]; / preferred resident
 if[$[count[rp]=hir:rp?hi;1b;hir>rp?ehi:r ri];:.[rhRH;(3;hi);1_]]; / reject
 if[not null ehi;h:@[h;ehi;drop ri];H:@[H;ehi;1_];rp:R[ri]:drop[ehi;rp]]; / drop existing match if worse
 h[hi],:ri; r[ri]:hi;       / match
 R[ri]:first c:(0;1+hir) cut rp;H:@[H;c 1;drop ri];
 (r;h;R;H)}
