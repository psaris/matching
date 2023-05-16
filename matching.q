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


/ stable marriage (SM) problem aka Gale-Shapley algorithm

/ given (e)ngagement vector and (S)uitor and (R)eviewer preferences, find
/ next engagement, remove undesirable suitors and unavailable reviewers.
/ roommate preferences are assumed if (R)eviewer preferences are not
/ provided.
sma:{[eSR]
 n:count e:eSR 0;S:eSR Si:1;R:eSR Ri:-1+count eSR;
 mi:?[;1b] 0<count each S w:where null e;    / first unmatched with prefs
 if[mi=count w;:eSR];                        / no unmatched suitor
 rp:R ri:first s:S si:w mi;                  / preferred reviewer's prefs
 if[count[rp]=sir:rp?si;:.[eSR;(Si;si);1_]]; / not on reviewer's list
 / renege if already engaged and this suitor is better
 if[not n=ei:e?ri;if[sir<rp?ei;eSR:.[eSR;(Si;ei);1_];e[ei]:0N]];
 e[si]:ri; eSR[0]:e;                      / get engaged
 eSR[Si]:last rpS:prune[rp;eSR Si;ri;si]; / first replace suitor prefers
 eSR[Ri;ri]:first rpS;                    / order matters when used for SR
 eSR}

/ given (S)uitor and (R)eviewer preferences, return the (e)ngagement
/ dictionary and remaining (S)uitor and (R)eviewer preferences for inspection
sm:{[S;R]
 us:key S; ur:key R;                      / unique suitors and reviewers
 eSR:(count[S]#0N;ur?value S;us?value R); / initial state/enumerated values
 eSR:sma over eSR;                / iteratively apply Gale-Shapley algorithm
 eSR:(us;us;ur)!'(ur;ur;us)@'eSR; / map enumerations back to original values
 eSR}


/ stable roommates (SR) problem aka Robert Irving 1985 algorithm

/ given (R)oommate preferences and cycle (c)hain, add next link
link:{[R;c] c,enlist (last R i;i:R[last[c] 0;1])}

/ given (R)oommate preferences and initial cycle (c)hain, add links until a
/ duplicate is found
cycle:{[R;c]
 c:{$[1=count x;1b;not last[x] in -1_x]} link[R]/ c;
 c:(1+c ? last c)_c;            / remove 'tail' from the chain
 c}

/ phase 2 of the stable roommates (SR) problem removes all cycles within the
/ remaining candidates leaving the one true stable solution
decycle:{[R]
 if[any 0=c:count each R;'`unstable]; / unable to match a roommate
 if[count[c]=i:?[;1b] c>1;:R];        / first roommate with multiple prefs
 c:cycle[R] enlist (i;R[i;0]);        / build the cycle starting here
 R:pruner/[R;c[;1];-1 rotate c[;0]];  / prune prefs based on dropped cycle
 R}

/ given (a)ssignment vector and (R)oomate preferences, return the completed
/ (a)ssignment vector (R)oommate preferences from each decycle stage
sra:{[aR]
 R:last sma over aR;            / apply phase 1 and throw away assignments
 R:decycle scan R;              / apply phase 2
 aR:enlist[last[R][;0]],R;      / prepend assignment vector
 aR}

/ given (R)oomate preference dictionary, return the (a)ssignment dictionary
/ and (R)oommate preference dictionaries from each decycle stage
sr:{[R]
 ur:key R;                      / unique roommates
 aR:(count[R]#0N;ur?value R);   / initial assignment/enumerated values
 aR:sra aR;                     / apply stable roommate (SR) algorithm
 aR:ur!/:ur aR;                 / map enumerations back to original values
 aR}


/ hospital-resident (HR) problem

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preferences, find next resident-optimal match
hrra:{[c;hrHR]
 h:hrHR 0;r:hrHR 1;H:hrHR 2;R:hrHR 3;
 mi:?[;1b] 0<count each R w:where null r; / first unmatched with prefs
 if[mi=count w;:hrHR];                    / nothing to match
 hp:H hi:first R ri:w mi;                 / preferred hospital
 if[not ri in hp;:.[hrHR;(3;ri);1_]];     / hospital rejects
 ch:count ris:h[hi],:ri; r[ri]:hi;        / match
 if[ch>c hi;                              / over capacity
  wri:hp max hp?ris;                      / worst resident
  ch:count ris:h[hi]:drop[ris;wri]; / drop resident from hospital match
  r[wri]:0N;                        / drop resident match
  ];
 if[ch=c hi; H[hi]:first hpR:prune[hp;R;hi;ris]; R:last hpR]; / prune
 (h;r;H;R)}

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preferences, find next hospital-optimal match
hrha:{[c;hrHR]
 h:hrHR 0;r:hrHR 1;H:hrHR 2;R:hrHR 3;
 w:where c>count each h;        / limit to hospitals with capacity
 mi:?[;1b] 0<count each m:H[w] except' h w; / first with unmatched prefs
 if[mi=count w;:hrHR];                      / nothing to match
 rp:R ri:first m mi; hi:w mi;               / preferred resident
 if[not hi in rp;:.[hrHR;(2;hi);1_]];       / resident preferences
 if[not null ehi:r ri; h:@[h;ehi;drop;ri]]; / drop existing match
 h[hi],:ri; r[ri]:hi;                           / match
 R[ri]:first rpH:prune[rp;H;ri;hi]; H:last rpH; / prune
 (h;r;H;R)}

/ hospital resident (HR) problem wrapper function that enumerates the inputs,
/ calls the hr function and unenumerates the results
hrw:{[hrf;C;H;R]
 uh:key H; ur:key R;
 hrHR:((count[H];0)#0N;count[R]#0N;ur?value H;uh?value R);
 hrHR:hrf[C uh] over hrHR;
 hrHR:(uh;ur;uh;ur)!'(ur;uh;ur;uh)@'hrHR;
 hrHR}

hrr:hrw[hrra]                  / hospital resident (resident-optimal)
hrh:hrw[hrha]                  / hospital resident (hospital-optimal)


/ student-allocation (SA) problem

/ given (p)roject (c)apacity, s(u)pervisor (c)apacity, (p)roject to
/ s(u)pervisor map and (p)roject matches, s(u)pervisor matches, (s)tudent
/ matches, s(U)pervisor preferences and (S)tudent preferences, find next
/ student-optimal match
sasa:{[pc;uc;pu;pusUS]
 p:pusUS 0;u:pusUS 1;s:pusUS 2;U:pusUS 3;S:pusUS 4;
 mi:?[;1b] 0<count each S w:where null s; / first unmatched student
 if[mi=count w;:pusUS];                   / nothing to match
 up:U ui:pu pi:first S si:w mi; / preferred project's supervisors preferences
 cu:count usis:u[ui],:si;cp:count psis:p[pi],:si;s[si]:pi; / match
 if[cp>pc pi;                         / project over capacity
  wsi:up max up?psis; s[wsi]:0N;      / worst student
  cp:count psis:p[pi]:drop[psis;wsi]; / drop from project
  cu:count usis:u[ui]:drop[usis;wsi]; / drop from supervisor
  ];
 if[cu>uc ui;                         / supervisor over capacity
  wsi:up max up?usis;                 / worst student
  p:@[p;s wsi;drop;wsi]; s[wsi]:0N;   / drop from other project
  cu:count usis:u[ui]:drop[usis;wsi]; / drop from supervisor
  ];
 if[cp=pc pi;S:last prune[up;S;pi;psis]]; / prune
 if[cu=uc ui;U[ui]:first upS:prune[up;S;where pu=ui;usis]; S:last upS];
 (p;u;s;U;S)}

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
/ s(u)pervisor map and (p)roject matches, s(u)pervisor matches, (s)tudent
/ matches, s(U)pervisor preferences and (S)tudent preferences, find next
/ supervisor-optimal match
saua:{[pc;uc;pu;pusUS]
 p:pusUS 0;u:pusUS 1;s:pusUS 2;U:pusUS 3;S:pusUS 4;
 ubc:uc>count each u;                          / supervisors below capacity
 pbc:pc>count each p;                          / projects below capacity
 usp:(1=count::) nextusp[pbc;ubc;pu;p;S;U]/ 0; / iterate across supervisors
 if[not count usp;:pusUS];                     / no further matches found
 ui:usp 0; sp:S si:usp 1; pi: usp 2;           / unpack
 if[not null epi:s si; u:@[u;pu epi;drop;si]; p:@[p;epi;drop;si]]; / drop
 u[ui],:si; p[pi],:si; s[si]:pi;                                   / match
 S[si]:first prune[sp;U;();pi];                                    / prune
 (p;u;s;U;S)}

/ student-allocation (SA) problem wrapper function that enumerates the
/ inputs, calls the sa function and unenumerates the results
saw:{[saf;PC;UC;PU;U;S]
 up:key PU; uu:key U; us:key S; / unique project, supervisors and students
 pusUS:((count[PU];0)#0N;(count[U];0)#0N;count[S]#0N;us?value U;up?value S);
 pusUS:saf[PC up;UC uu;uu?PU up] over pusUS;
 pusUS:(up;uu;us;uu;us)!'(us;us;up;us;up)@'pusUS;
 pusUS}

sas:saw[sasa]                   / student-allocation (student-optimal)
sau:saw[saua]                   / student-allocation (supervisor-optimal)
