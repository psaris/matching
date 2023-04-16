\l util.q
\l matching.q

/ student-allocation problem

/ https://matching.readthedocs.io/en/latest/discussion/student_allocation/index.html

s:2!("JJ",(-2+count first x)#"S";1#",") 0: x:read0 `:students.csv
p:("SJS";1#",") 0: `:projects.csv
u:("SJ";1#",") 0: `:supervisors.csv

/ drop students without any choices
s:where[all each null s] _ s

/ ensure all projects have capacity>0 and non-null code and supervisor
p:select from p where capacity>0, not null code, not null supervisor

/ ensure all supervisor have capacity>0 and non-null name
u:select from u where capacity>0, not null name

p:select from p where supervisor in u.name
PC:exec code!capacity from p    / project capacity
PU:exec code!supervisor from p  / project supervisor
UC:exec name!capacity from u where name in value PU / supervisor capacity
/ student preferences (transform table into a list)
S:key[s][`name]!value (inter[;p[`code]] distinct value::) each s
st:{x[`name] iasc x`rank} key s / sorted students

/ supervisor preferences (sorted students that rank supervisor's projects)
U:(st#S) {where (any y in::) each x}/: exec code by supervisor from p
U:where[0=count each U] _ U     / throw away any empty supervisors
S:where[0=count each S] _ S     / throw away empty students

uru:u[`name] except key U       / unranked supervisors
UC:uru _ UC                     / remove unranked supervisors

urp:p[`code] except raze S      / unranked projects
PC:urp _ PC                     / remove unranked projects
PU:urp _ PU                     / remove unranked projects

PC&: UC PU                      / limit to project to supervisor's capacity

UC&:sum each PC key[PU] group value[PU] / limit supervisor to sum of projects

upsUS:.matching.saps[PC;UC;PU;U;S]
/ entries are sorted by preference, so need to resort to compare
.util.assert[1b] all raze (asc each upsUS[1])=asc each .j.k raze read0 `:student_solution.json

upsUS:.matching.sapu[PC;UC;PU;U;S]
.util.assert[1b] all raze upsUS[1]=.j.k raze read0 `:supervisor_solution.json
