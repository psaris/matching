\d .match

/ drop first occurrence of x from y
drop:{y _ y?x}


/ stable marriage problem (SMP) aka Gale-Shapley Algorithm

/ given (e)ngagement vector and (S)uitor and (R)eviewer matrices, find next
/ engagement, remove undesirable suitors and unavailable reviewers.  a single
/ roommate matrix is assumed if a (R)eviewer matrix is not provided.
phase1:{[eSR]
 n:count e:eSR 0;S:eSR Si:1;R:eSR Ri:-1+count eSR;
 si:e?0N;                       / find single suitor
 if[n=si;:eSR];                 / everyone is engaged
 if[any 0=count each S;'`unstable];
 r:R ri:first s:S si;    / find preferred reviewer
 / if already engaged, and this suitor is better, renege
 if[not n=ei:e?ri;if[(</)r?(si;ei);eSR:.[eSR;(Si;ei);1_];e[ei]:0N]];
 e[si]:ri; eSR[0]:e;                  / get engaged
 eSR[Ri;ri]:first c:(0;1+r?si) cut r; / remove undesirable suitors
 eSR:.[eSR;(Si;c 1);drop ri];         / remove unavailable reviewers
 eSR}

smp:{[S;R]
 us:key S; ur:key R;
 eSR:phase1 over (count[S]#0N;ur?value S;us?value R);
 eSR:(us;us;ur)!'(ur;ur;us)@'eSR;
 eSR}


/ stable roommates problem (SRP) aka Robert Irving Algorithm

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
 ur:key R;
 R:last eR:phase1 over (count[R]#0N;ur?value R);
 R:ur phase2 scan R;
 R:enlist[ur!first each last R],R;
 R}


/ hospital-resident problem (HRP)

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preference matrices, find next resident-optimal
/ match
hrpra:{[c;hrHR]
 h:hrHR 0;r:hrHR 1;H:hrHR 2;R:hrHR 3;
 if[null ri:first where null[r]&0<count each R;:hrHR]; / nothing to match
 hp:H hi:first R ri;                                   / preferred hospital
 if[not ri in hp;:.[hrHR;(3;ri);1_]];                  / hospital rejects
 ch:count ris:h[hi],:ri; r[ri]:hi;                     / match
 if[ch>c hi;wri:hp max hp?ris;ris:h[hi]:drop[wri;ris];r[wri]:0N;hp:H[hi]:drop[wri;hp];R:@[R;wri;1_];ch-:1];
 if[ch=c hi;H[hi]:first c:(0;1+max hp?ris) cut hp;R:@[R;c 1;drop hi]];
 (h;r;H;R)}

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preference matrices, find next hospital-optimal
/ match
hrpha:{[c;hrHR]
 h:hrHR 0;r:hrHR 1;H:hrHR 2;R:hrHR 3;
 if[null hi:first where (c>count each h)&0<count each H;:hrHR]; / nothing to match
 rp:R ri:first H[hi] except h[hi]; / preferred resident
 if[$[count[rp]=hir:rp?hi;1b;hir>rp?ehi:r ri];:.[hrHR;(2;hi);1_]]; / reject
 if[not null ehi;h:@[h;ehi;drop ri];H:@[H;ehi;1_];rp:R[ri]:drop[ehi;rp]]; / drop existing match if worse
 h[hi],:ri; r[ri]:hi;       / match
 R[ri]:first c:(0;1+hir) cut rp;H:@[H;c 1;drop ri];
 (h;r;H;R)}

hrpr:{[C;H;R]
 uh:key H; ur:key R;
 hrHR:hrpra[C uh] over ((count[H];0)#0N;count[R]#0N;ur?value H;uh?value R);
 hrHR:(uh;ur;uh;ur)!'(ur;uh;ur;uh)@'hrHR;
 hrHR}

hrph:{[C;H;R]
 uh:key H; ur:key R;
 hrHR:hrpha[C uh] over ((count[H];0)#0N;count[R]#0N;ur?value H;uh?value R);
 hrHR:(uh;ur;uh;ur)!'(ur;uh;ur;uh)@'hrHR;
 hrHR}
