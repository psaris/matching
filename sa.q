\l util.q
\l matching.q

-1 "student-allocation (SA) problem";

/ https://matching.readthedocs.io/en/latest/discussion/student_allocation/index.html
-1 "worked example from the matching python library";
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

-1 "to simplify the algorithm, the data must be preprocessed";
d:preprocess[u;p;s]
-1 "the algorithm requires 5 dictionaries:";
-1 " - project capacities";
-1 " - supervisor capacities";
-1 " - project to supervisor map";
-1 " - supervisor student preferences";
-1 " - student project preferences";
-1 "student-optimal matches";
upsUS:.matching.sas . d`PC`UC`PU`U`S
-1 "the resulting project -> student map provides complete information";
show upsUS 1
-1 "python student-optimal implementation inserts matches in preferred order";
-1 "this doesn't change the matches but forces us to sort before comparing";
upsUS[1]:d[`U][d[`PU] key upsUS 1] inter' upsUS 1 / sort by supervisor prefs
.util.assert[1b] all raze upsUS[1]= .j.k raze read0 `:student_solution.json

-1 "python supervisor-optimal matches (as in q) are sorted in matched order";
upsUS:.matching.sau . d`PC`UC`PU`U`S
.util.assert[1b] all raze upsUS[1]=.j.k raze read0 `:supervisor_solution.json
