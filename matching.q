\d .matching

/ drop first occurrence of x from y
drop:{x _ x?y}

/ given (S)uiter preferences, (r)eviewer (p)refs, and (s)uitor (i)ndice(s)
/ and (r)eviewer (i)ndice(s), return the pruned reviewer and Suitor prefs
prune:{[S;rp;ris;sis]
 if[count[rp]<=i:1+max rp?sis;:(S;rp)]; / return early if nothing to do
 (rp;sis):(0;i) cut rp;                 / drop worse suitors from preferences
 S:S @[;sis;drop;]/ ris;                / drop reviewers from worse suitors
 (S;rp)}

/ given (R)oommate preferences and (r)eviewer and (s)uitor indices, return
/ the pruned Roommate preferences
pruner:{[R;ri;si] (R;R ri):prune[R;R ri;ri;si]; R}


/ stable marriage (SM) problem aka Gale-Shapley algorithm

/ given (e)ngagement vector and (S)uitor and (R)eviewer preferences, find
/ next engagement, remove undesirable suitors and unavailable reviewers.
/ roommate preferences are assumed if (R)eviewer preferences are not
/ provided.
sma:{[eSR]
 e:eSR 0;S:eSR Si:1;R:eSR Ri:-1+count eSR;   / manually unpack
 mi:?[;1b] 0<count each S w:where null e;    / first unmatched with prefs
 if[mi=count w;:eSR];                        / no unmatched suitor
 rp:R ri:first s:S si:w mi;                  / preferred reviewer's prefs
 if[count[rp]=sir:rp?si;:.[eSR;(Si;si);1_]]; / not on reviewer's list
 / renege if already engaged and this suitor is better
 if[not count[e]=ei:e?ri;if[sir<rp?ei;eSR:.[eSR;(Si;ei);1_];e[ei]:0N]];
 e[si]:ri; eSR[0]:e;                         / get engaged
 (eSR Si;eSR[Ri;ri]):prune[eSR Si;rp;ri;si]; / assignment order matters
 eSR}

/ given (S)uitor and (R)eviewer preferences, return the (e)ngagement
/ dictionary and remaining (S)uitor and (R)eviewer preferences for inspection
sm:{[sn!sp;rn!rp]
 eSR:(count[sn]#0N;rn?sp;sn?rp);  / initial state/enumerated values
 eSR:sma over eSR;                / iteratively apply Gale-Shapley algorithm
 eSR:(sn;sn;rn)!'(rn;rn;sn)@'eSR; / map enumerations back to original values
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
 (;R):sma over aR;              / apply phase 1 and throw away assignments
 R:decycle scan R;              / apply phase 2
 aR:enlist[last[R][;0]],R;      / prepend assignment vector
 aR}

/ given (R)oomate preference dictionary, return the (a)ssignment dictionary
/ and (R)oommate preference dictionaries from each decycle stage
sr:{[rn!rp]
 aR:(count[rn]#0N;rn?rp);       / initial assignment/enumerated values
 aR:sra aR;                     / apply stable roommate (SR) algorithm
 aR:rn!/:rn aR;                 / map enumerations back to original values
 aR}


/ hospital-resident (HR) problem

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preferences, find next resident-optimal match
hrra:{[c;(h;r;H;R)]
 mi:?[;1b] 0<count each R w:where null r; / first unmatched with prefs
 if[mi=count w;:(h;r;H;R)];               / nothing to match
 hp:H hi:first R ri:w mi;                 / preferred hospital
 if[not ri in hp;:(h;r;H;@[R;ri;1_])];    / hospital rejects
 ch:count ris:h[hi],:ri; r[ri]:hi;        / match
 if[ch>c hi;                              / over capacity
  wri:hp max hp?ris;                      / worst resident
  ch:count ris:h[hi]:drop[ris;wri]; / drop resident from hospital match
  r[wri]:0N;                        / drop resident match
  ];
 if[ch=c hi;(R;H hi):prune[R;hp;hi;ris]]; / prune
 (h;r;H;R)}

/ given hospital (c)apacity and (h)ospital matches, (r)esident matches,
/ (H)ospital and (R)esident preferences, find next hospital-optimal match
hrha:{[c;(h;r;H;R)]
 w:where c>count each h;        / limit to hospitals with capacity
 mi:?[;1b] 0<count each m:H[w] except' h w; / first with unmatched prefs
 if[mi=count w;:(h;r;H;R)];                 / nothing to match
 rp:R ri:first m mi; hi:w mi;               / preferred resident
 if[not hi in rp;:(h;r;@[H;hi;1_];R)];      / resident preferences
 if[not null ehi:r ri; h:@[h;ehi;drop;ri]]; / drop existing match
 h[hi],:ri; r[ri]:hi;                       / match
 (H;R ri):prune[H;rp;ri;hi];                / prune
 (h;r;H;R)}

/ hospital resident (HR) problem wrapper function that enumerates the inputs,
/ calls the hr function and unenumerates the results
hrw:{[hrf;C;hn!hp;rn!rp]
 hrHR:((count hn;0)#0N;count[rn]#0N;rn?hp;hn?rp);
 hrHR:hrf[C hn] over hrHR;
 hrHR:(hn;rn;hn;rn)!'(rn;hn;rn;hn)@'hrHR;
 hrHR}

hrr:hrw[hrra]                  / hospital resident (resident-optimal)
hrh:hrw[hrha]                  / hospital resident (hospital-optimal)


/ student-allocation (SA) problem

/ given (p)roject (c)apacity, s(u)pervisor (c)apacity, (p)roject to
/ s(u)pervisor map and (p)roject matches, s(u)pervisor matches, (s)tudent
/ matches, s(U)pervisor preferences and (S)tudent preferences, find next
/ student-optimal match
sasa:{[pc;uc;pu;(p;u;s;U;S)]
 mi:?[;1b] 0<count each S w:where null s; / first unmatched student
 if[mi=count w;:(p;u;s;U;S)];             / nothing to match
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
 if[cp=pc pi;(S;):prune[S;up;pi;psis]]; / prune
 if[cu=uc ui;(S;U ui):prune[S;up;where pu=ui;usis]];
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
saua:{[pc;uc;pu;(p;u;s;U;S)]
 ubc:uc>count each u;                          / supervisors below capacity
 pbc:pc>count each p;                          / projects below capacity
 usp:(1=count::) nextusp[pbc;ubc;pu;p;S;U]/ 0; / iterate across supervisors
 if[not count usp;:(p;u;s;U;S)];               / no further matches found
 (ui;si;pi):usp;                               / unpack
 if[not null epi:s si; u:@[u;pu epi;drop;si]; p:@[p;epi;drop;si]]; / drop
 u[ui],:si; p[pi],:si; s[si]:pi;                                   / match
 (;S si):prune[U;S si;();pi];                                      / prune
 (p;u;s;U;S)}

/ student-allocation (SA) problem wrapper function that enumerates the
/ inputs, calls the sa function and unenumerates the results
saw:{[saf;PC;UC;pn!pu;un!up;sn!sp]
 pusUS:((count pn;0)#0N;(count un;0)#0N;count[sn]#0N;sn?up;pn?sp);
 pusUS:saf[PC pn;UC un;un?pu] over pusUS;
 pusUS:(pn;un;sn;un;sn)!'(sn;sn;pn;sn;pn)@'pusUS;
 pusUS}

sas:saw[sasa]                   / student-allocation (student-optimal)
sau:saw[saua]                   / student-allocation (supervisor-optimal)
