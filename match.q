\d .match

/ drop first occurrence of x from y
drop:{x _ x?y}


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
 eSR:.[eSR;(Si;c 1);drop;ri];         / remove unavailable reviewers
 eSR}

smp:{[S;R]
 us:key S; ur:key R;
 eSR:(count[S]#0N;ur?value S;us?value R);
 eSR:phase1 over eSR;
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
 R:@[R;c 1;drop;i];
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
 eR:(count[R]#0N;ur?value R);
 R:last phase1 over eR;
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
 if[ch>c hi;                                           / over capacity
  wri:hp max hp?ris;                                   / worst resident
  ch:count ris:h[hi]:drop[ris;wri]; / drop resident from hospital match
  hp:H[hi]:drop[hp;wri];            / drop resident from hospital prefs
  R:@[R;wri;1_];                    / drop hospital from resident prefs
  r[wri]:0N;                        / drop resident match
  ];
 if[ch=c hi;                    / prune worst residents from consideration
  if[count[hp]>i:1+max hp?ris;
   H[hi]:first c:(0;i) cut hp;  / drop residents from hospital prefs
   R:@[R;c 1;drop;hi]           / drop hospital from resident prefs
   ];
  ];
 (h;r;H;R)}

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preference matrices, find next hospital-optimal
/ match
hrpha:{[c;hrHR]
 h:hrHR 0;r:hrHR 1;H:hrHR 2;R:hrHR 3;
 m:H[w] except' h w:where c>count each h; / matchable
 hi:w mi:first where 0<count each m;
 if[null mi;:hrHR];                   / nothing to match
 rp:R ri:first m mi;                  / preferred resident
 if[not hi in rp;:.[hrHR;(2;hi);1_]]; / resident preferences
 if[not null ehi:r ri;                / drop existing match if worse
  h:@[h;ehi;drop;ri];                 / drop resident from hospital match
  H:@[H;ehi;1_];                      / drop resident from hospital prefs
  rp:R[ri]:drop[rp;ehi]               / drop hospital from resident prefs
  ];
 h[hi],:ri; r[ri]:hi;                                  / match
 R[ri]:first c:(0;1+rp?hi) cut rp; H:@[H;c 1;drop;ri]; / prune
 (h;r;H;R)}

/ hospital resident problem wrapper function that enumerates the inputs,
/ calls the hrp function and unenumerates the results
hrpw:{[hrpf;C;H;R]
 uh:key H; ur:key R;
 hrHR:((count[H];0)#0N;count[R]#0N;ur?value H;uh?value R);
 hrHR:hrpf[C uh] over hrHR;
 hrHR:(uh;ur;uh;ur)!'(ur;uh;ur;uh)@'hrHR;
 hrHR}

hrpr:hrpw[hrpra]               / hospital resident problem (resident-optimal)
hrph:hrpw[hrpha]               / hospital resident problem (hospital-optimal)


/ student-allocation problem (SAP)

/ given (p)roject (c)apacity, s(u)pervisor (c)apacity, (p)roject to
/ s(u)pervisor map and s(u)pervisor matches, (p)roject matches, (s)tudent
/ matches, s(U)pervisor preferences and (S)tudent preferences, find next
/ student-optimal match
sapsa:{[pc;uc;pu;upsUS]
 u:upsUS 0;p:upsUS 1;s:upsUS 2;U:upsUS 3;S:upsUS 4;
 if[null si:first where null[s]&0<count each S;:upsUS]; / nothing to match
 up:U ui:pu pi:first S si;      / preferred project's supervisors preferences
 cu:count usis:u[ui],:si;cp:count psis:p[pi],:si;s[si]:pi; / match
 if[cp>pc pi;                         / project over capacity
  wsi:up max up?psis;                 / worst student
  cp:count psis:p[pi]:drop[psis;wsi]; / drop from project
  cu:count usis:u[ui]:drop[usis;wsi]; / drop from supervisor
  s[wsi]:0N;                          / remove match
  ];
 if[cu>uc ui;                / supervisor over capacity
  wsi:up max up?usis;                 / worst student
  p:@[p;s wsi;drop;wsi];              / drop from project
  cu:count usis:u[ui]:drop[usis;wsi]; / drop from supervisor
  s[wsi]:0N;                          / remove match
  ];
 if[cp=pc pi;if[count[up]>i:1+max up?psis; S:@[S;i _ up;drop;pi]]]; / prune
 if[cu=uc ui;
  if[count[up]>i:1+max up?usis;
   U[ui]:first c:(0;i) cut up;
   S:@[;c 1;drop;]/[S;where pu = ui];
   ];
  ];
 (u;p;s;U;S)}

/ given (p)rojects (b)elow (c)apacity boolean vector, s(u)pervisors (b)elow
/ (c)apacity vector, (p)roject to s(u)pervisor map, (p)roject matches,
/ (S)tudent preferences, s(U)pervisor preferences and a single s(u)pervisor
/ (i)ndex, return the s(u)pervisor's preferred (s)tudent and their preferred
/ (p)roject (that is mapped to the supervisor) as a triplet (u;s;p). if no
/ match is found, return the next supervisor index ui.  return an empty list
/ if all supervisors have been exhausted.
nextusp:{[pbc;ubc;pu;p;S;U;ui]
 if[ui=count U;:()];                  / no more supervisors
 if[not ubc ui;:ui+1];                / supervisor at capacity
 pis:S sis:U ui;                      / unpack students and their projects
 pis:pis@'where each (pbc&ui=pu) pis; / supervisor's projects with capacity
 pis:pis@'where each not sis (in/:)' p pis;  / not already matched
 if[not count sp:raze sis (,/:)' pis;:ui+1]; / (student;project)
 usp:ui,first sp;                            / (supervisor;student;project)
 usp}

/ given (p)roject (c)apacity, s(u)pervisor (c)apacity, (p)roject to
/ s(u)pervisor map and s(u)pervisor matches, (p)roject matches, (s)tudent
/ matches, s(U)pervisor preferences and (S)tudent preferences, find next
/ supervisor-optimal match
sapua:{[pc;uc;pu;upsUS]
 u:upsUS 0;p:upsUS 1;s:upsUS 2;U:upsUS 3;S:upsUS 4;
 ubc:uc>count each u;                          / supervisors below capacity
 pbc:pc>count each p;                          / projects below capacity
 usp:(1=count::) nextusp[pbc;ubc;pu;p;S;U]/ 0; / iterate across supervisors
 if[not count usp;:upsUS];                     / no further matches found
 ui:usp 0; sp:S si:usp 1; pi: usp 2;           / unpack
 if[not null epi:s si; u:@[u;pu epi;drop;si]; p:@[p;epi;drop;si]]; / drop
 u[ui],:si; p[pi],:si; s[si]:pi;                                   / match
 if[count[sp]>i:1+sp?pi; S[si]:i#sp];                              / prune
 (u;p;s;U;S)}

/ student allocation problem wrapper function that enumerates the inputs,
/ calls the sap function and unenumerates the results
sapw:{[sapf;PC;UC;PU;U;S]
 up:key PU; uu:key U; us:key S; / unique project, supervisors and students
 upsUS:((count[U];0)#0N;(count[PU];0)#0N;count[S]#0N;us?value U;up?value S);
 upsUS:sapf[PC up;UC uu;uu?PU up] over upsUS;
 upsUS:(uu;up;us;uu;us)!'(us;us;up;us;up)@'upsUS;
 upsUS}

saps:sapw[sapsa]
sapu:sapw[sapua]
