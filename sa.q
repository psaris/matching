\l matching.q

-1 "student-allocation (SA) problem";

-1 "simple example from python 'matching' library";
/ https://matching.readthedocs.io/en/latest/discussion/student_allocation
-1 "the algorithm requires 5 dictionaries:";
-1 "project capacities";
show PC:([X1:2;X2:2;Y1:2;Y2:2])
-1 "supervisor capacities";
show UC:([X:3;Y:3])
-1 "project -> supervisor map";
show PU:([X1:`X;X2:`X;Y1:`Y;Y2:`Y])
-1 "supervisor student preferences";
show U:([X:`B`C`A`E`D;Y:`B`C`E`D])
-1 "student project preferences";
show S:([A:`X1`X2;B:`Y2`X2`Y1;C:`X1`Y1`X2;D:`Y2`X1`Y1;E:`X1`Y2`X2`Y1])

-1 "allocations";
show A:([X1:`C`A;X2:0#`;Y1:1#`D;Y2:`B`E])

-1 "student-optimal allocations";
pusUS:.matching.sas[PC;UC;PU;U;S]
-1 "python student-optimal implementation inserts matches in preferred order";
-1 "this doesn't change the matches but forces us to sort before comparing";
pusUS:@[pusUS;0;U[PU key pusUS 0] inter']
(1b):A ~ pusUS 0

-1 "python supervisor-optimal matches (as in q) are sorted in matched order";
pusUS:.matching.sau[PC;UC;PU;U;S]
(1b):A ~ pusUS 0

-1 "worked example from the python 'matching' library";
/ https://matching.readthedocs.io/en/latest/tutorials/project_allocation
-1 "students";
show s:2!("JJ",(-2+count first x)#"S";1#",") 0: x:read0 `:students.csv
-1 "projects";
show p:("SJS";1#",") 0: `:projects.csv
-1 "supervisors";
show u:("SJ";1#",") 0: `:supervisors.csv

preprocess:{[u;p;s]
 s:where[all each null s] _ s; / drop students without any choices
 / ensure all projects have capacity>0 and non-null code and supervisor
 p:select from p where capacity>0, not null code, not null supervisor;
 / ensure all supervisor have capacity>0 and non-null name
 u:select from u where capacity>0, not null name;
 p:select from p where supervisor in u.name;
 PC:exec code!capacity from p;                        / project capacity
 PU:exec code!supervisor from p;                      / project supervisor
 UC:exec name!capacity from u where name in value PU; / supervisor capacity
 / student preferences (transform table into a list)
 S:key[s][`name]!value (inter[;p[`code]] distinct value::) each s;
 st:{x[`name] iasc x`rank} key s; / sorted students
 / supervisor preferences (sorted students that rank supervisor's projects)
 U:(st#S) {where (any y in::) each x}/: exec code by supervisor from p; /
 U:where[0=count each U] _ U;   / throw away any empty supervisors
 S:where[0=count each S] _ S;   / throw away empty students
 uru:u[`name] except key U;     / unranked supervisors
 UC:uru _ UC;                   / remove unranked supervisors
 urp:p[`code] except raze S;    / unranked projects
 PC:urp _ PC;                   / remove unranked projects
 PU:urp _ PU;                   / remove unranked projects
 PC&:UC PU;                     / cap project to supervisor's capacity
 UC&:sum each PC key[PU] group value[PU]; / cap supervisor to sum of projects
 d:`PC`UC`PU`U`S!(PC;UC;PU;U;S);
 d}

-1 "the data must be preprocessed to obey problem constraints";
d:preprocess[u;p;s]
-1 "student-optimal matches";
pusUS:.matching.sas . d`PC`UC`PU`U`S
-1 "the resulting project -> student map provides complete information";
show first pusUS
-1 "python student-optimal implementation inserts matches in preferred order";
-1 "this doesn't change the matches but forces us to sort before comparing";
pusUS:@[pusUS;0;d[`U][d[`PU] key pusUS 0] inter'] / sort by supervisor prefs
(1b):pusUS[0] ~ "j"$.j.k raze read0 `:student_solution.json

-1 "python supervisor-optimal matches (as in q) are sorted in matched order";
pusUS:.matching.sau . d`PC`UC`PU`U`S
(1b):pusUS[0] ~ "j"$.j.k raze read0 `:supervisor_solution.json
