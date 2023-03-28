\l match.q

/ student allocation problem

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
pc:exec code!capacity from p    / project capacity
pu:exec code!supervisor from p  / project supervisor
uc:exec name!capacity from u where name in value pu / supervisor capacity
/ student preferences (transform table into a list)
sp:key[s][`name]!value (inter[;p[`code]] distinct value::) each s
st:{x[`name] iasc x`rank} key s / sorted students

/ supervisor preferences (sorted students that rank supervisor's projects)
up:(st#sp) {where (any y in::) each x}/: exec code by supervisor from p
up:where[0=count each up] _ up / throw away any empty supervisors

uru:u[`name] except key up      / unranked supervisors
sc:uru _ sc                     / remove unranked supervisors

urp:p[`code] except raze sp     / unranked projects
pc:urp _ pc                     / remove unranked projects
pu:urp _ pu                     / remove unranked projects

pc&: uc pu                      / limit to project to supervisor's capacity

uc&:sum each pc key[pu] group value[pu] / limit supervisor to sum of projects

