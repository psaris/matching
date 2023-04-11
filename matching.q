\d .matching

/ drop first occurrence of x from y
drop:{x _ x?y}

/ given (r)eviewer (p)refs, (S)uiter preferences and (s)uitor (i)ndice(s) and
/ (r)eviewer (i)ndice(s), return the pruned reviewer and Suitor prefs
prune:{[rp;S;ris;sis]
 if[count[rp]=i:1+max rp?sis;:(rp;S)]; / return early if nothing to do
 rp:first c:(0;i) cut rp;              / drop worse suitors from preferences
 S:@[;last c;drop;]/[S;ris];           / drop reviewers from worse suitors
 (rp;S)}

/ given (R)oommate preferences and (r)eviewer and (s)uitor indices, return
/ the pruned Roommate preferences
pruner:{[R;ri;si]@[last rpR;ri;:;first rpR:prune[R ri;R;ri;si]]}


/ stable marriage problem (SMP) aka Gale-Shapley algorithm

/ given (e)ngagement vector and (S)uitor and (R)eviewer preferences, find
/ next engagement, remove undesirable suitors and unavailable reviewers.
/ roommate preferences are assumed if (R)eviewer preferences are not
/ provided.
smpa:{[eSR]
 n:count e:eSR 0;S:eSR Si:1;R:eSR Ri:-1+count eSR;
 if[n=si:e?0N;:eSR];            / everyone is engaged
 if[any 0=count each S;'`unstable];
 rp:R ri:first s:S si;          / find preferred reviewer's preferences
 / if already engaged, and this suitor is better, renege
 if[not n=ei:e?ri;if[(</)rp?(si;ei);eSR:.[eSR;(Si;ei);1_];e[ei]:0N]];
 e[si]:ri; eSR[0]:e;                      / get engaged
 eSR[Si]:last rpS:prune[rp;eSR Si;ri;si]; / first replace suitor prefers
 eSR[Ri;ri]:first rpS;                    / order matters when used for SRP
 eSR}

/ given (S)uitor and (R)eviewer preferences, return the (e)ngagement
/ dictionary and remaining (S)uitor and (R)eviewer preferences for inspection
smp:{[S;R]
 us:key S; ur:key R;                      / unique suitors and reviewers
 eSR:(count[S]#0N;ur?value S;us?value R); / initial state/enumerated values
 eSR:smpa over eSR;               / iteratively apply Gale-Shapley algorithm
 eSR:(us;us;ur)!'(ur;ur;us)@'eSR; / map enumerations back to original values
 eSR}


/ stable roommates problem (SRP) aka Robert Irving 1985 algorithm

/ given (R)oommate preferences and cycle (c)hain, add next link
link:{[R;c] c,enlist (last R i;i:R[last[c] 0;1])}

/ given (R)oommate preferences and initial cycle (c)hain, add links until a
/ duplicate is found
cycle:{[R;c]
 c:{$[1=count x;1b;not last[x] in -1_x]} link[R]/ c;
 c:(1+c ? last c)_c;            / remove 'tail' from the chain
 c}

/ phase 2 of the stable roommates problem removes all cycles within the
/ remaining candidates leaving the one true stable solution
decycle:{[R]
 if[any 0=c:count each R;'`unstable]; / unable to match a roommate
 if[count[c]=i:(c>1)?1b;:R];          / first roommate with multiple prefs
 c:cycle[R] enlist (i;R[i;0]);        / build the cycle starting here
 R:@[R;c[;0];1_];                     / drop the cycle matches
 R:pruner/[R;c[;1];-1 rotate c[;0]];  / prune prefs based on dropped cycle
 R}

/ given (a)ssignment vector and (R)oomate preferences, return the completed
/ (a)ssignment vector (R)oommate preferences from each decycle stage
srpa:{[aR]
 R:last smpa over aR;           / apply phase 1 and throw away assignments
 R:decycle scan R;              / apply phase 2
 aR:enlist[last[R][;0]],R;      / prepend assignment vector
 aR}

/ given (R)oomate preference dictionary, return the (a)ssignment dictionary
/ and (R)oommate preference dictionaries from each decycle stage
srp:{[R]
 ur:key R;                      / unique roommates
 aR:(count[R]#0N;ur?value R);   / initial assignment/enumerated values
 aR:srpa aR;                    / apply stable roommate problem algorithm
 aR:ur!/:ur aR;                 / map enumerations back to original values
 aR}


/ hospital-resident problem (HRP)

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preferences, find next resident-optimal match
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
 if[ch=c hi; H[hi]:first hpR:prune[hp;R;hi;ris]; R:last hpR]; / prune
 (h;r;H;R)}

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preferences, find next hospital-optimal match
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
 h[hi],:ri; r[ri]:hi;                           / match
 R[ri]:first rpH:prune[rp;H;ri;hi]; H:last rpH; / prune
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
 if[cp=pc pi;S:last prune[up;S;pi;psis]]; / prune
 if[cu=uc ui;U[ui]:first upS:prune[up;S;where pu=ui;usis]; S:last upS];
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
 S[si]:first prune[sp;U;();pi];                                    / prune
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
