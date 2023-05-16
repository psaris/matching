# A Q Implementation of Four Famous Matching Algorithms

Clone this project, download[^1] test datasets[^2] and generate
solutions[^3]

```sh
$ git clone git@github.com:psaris/matching.git
$ make -j8
```

Start q with the following commands to see examples of the Stable
Marriage (SM), Stable Roommates (SR), Hospital-Resident (HR) and
Student-Allocation (SA) problems.

```sh
$ q sm.q
$ q sr.q
$ q hr.q
$ q sa.q
```

These scripts also behave as unit tests, ensuring any modifications to
the algorithms don't invalidate the results.

Use the "test" [GNUmakefile](GNUmakefile) target to run all commands
with output redirected to `/dev/null`.

```sh
$ make test
```

Use the "timing" [GNUmakefile](GNUmakefile) target to compare the
performance of the `python` object-oriented implementation and the `q`
vector implementation&mdash;guess which one is faster!  By using the
[PyKX](https://code.kx.com/pykx) package, the `q` implementation can
be called with `python` data structures without requiring custom `q`
<-> `python` conversion code.  In fact, if NumPy ndarrays are used,
the data is shared with the `q` process without copying.

```sh
$ make timing
```

## Stable Marriage (SM)

The stable marriage problem aims to find stable matches between two
disjoint lists of participants (men and women, mentors and mentees, or
even qgods and qbies) who have a ranked preference list for each of
the opposite members.  Stability is defined by the fact that no two
individuals would prefer each other over their current partners.

The stable marriage problem is often presented as an interaction
between men and women or males and females.  This hides an asymmetry
of the algorithm where the proposer obtains an optimal solution and
the proposee obtains a pessimal solution.  This `q` implementation,
therefore, does not refer to males and females, but suitors and
reviewers.  Both men and women can obtain optimal results by taking
the role of suitor.

The
[Gale-Shapley](https://en.wikipedia.org/wiki/Gale%E2%80%93Shapley_algorithm)
algorithm, created by David Gale and Lloyd Shapley in 1962, solves the
seemingly complex problem by introducing the concept of "deferred
acceptance".  This innovation has resulted in the algorithm to known
as the Deferred Acceptance algorithm as well.

The algorithm iterates across each suitor allowing them to propose to
their most-preferred reviewer.  If that reviewer has yet to accept a
proposal, the pair become semi-engaged (semi-engaged because, as we
will see, the reviewer has the right to break the engagement). If the
reviewer is already semi-engaged and the new proposer is higher on
their ranked preference list, they can renege the previous engagement
and accept the latest proposal. The reneged suitor then has the
opportunity to propose again (but obviously not to any reviewer who
reneged them).

Sample numeric [male](male.txt) and [female](female.txt) data are
provided in the repository.  The core implementation solves the
problem with integer lists, but accepts dictionaries of any type.  To
demonstrate the application on non-numeric preference list, we load
the [female](rfemale.txt) and [male](rmale.txt) data from the [Rosetta
Code](https://rosettacode.org/wiki/Stable_marriage_problem) site.

We first start `q` and load the [matching.q](matching.q) library.

```sh
$ q
q)\l matching.q
```

Then we define an `lf` load function that can be used with both sets
of preferences,

```q
lf:`$"," vs' (!/) @[;0;`$] flip ":" vs' read0 ::
```

and finally load the preferences.

```q
q)show F:lf `rfemale.txt
abi | bob  fred jon  gav  ian  abe dan  ed  col  hal 
bea | bob  abe  col  fred gav  dan ian  ed  jon  hal 
cath| fred bob  ed   gav  hal  col ian  abe dan  jon 
dee | fred jon  col  abe  ian  hal gav  dan bob  ed  
eve | jon  hal  fred dan  abe  gav col  ed  ian  bob 
fay | bob  abe  ed   ian  jon  dan fred gav col  hal 
gay | jon  gav  hal  fred bob  abe col  ed  dan  ian 
hope| gav  jon  bob  abe  ian  dan hal  ed  col  fred
ivy | ian  col  hal  gav  fred bob abe  ed  jon  dan 
jan | ed   hal  gav  abe  bob  jon col  ian fred dan 
q)show M:lf `rmale.txt
abe | abi  eve  cath ivy  jan  dee  fay  bea  hope gay 
bob | cath hope abi  dee  eve  fay  bea  jan  ivy  gay 
col | hope eve  abi  dee  bea  fay  ivy  gay  cath jan 
dan | ivy  fay  dee  gay  hope eve  jan  bea  cath abi 
ed  | jan  dee  bea  cath fay  eve  abi  ivy  hope gay 
fred| bea  abi  dee  gay  eve  ivy  cath jan  hope fay 
gav | gay  eve  ivy  bea  cath abi  dee  hope jan  fay 
hal | abi  eve  hope fay  ivy  cath jan  bea  gay  dee 
ian | hope cath dee  gay  bea  abi  fay  ivy  jan  eve 
jon | abi  fay  jan  gay  eve  bea  dee  cath ivy  hope

```

To obtain a female-optimal solution, we pass the `F` dictionary as the
suitor (first argument) and the `M` dictionary as the reviewer (second
argument) to the `.matching.sm` Stable Marriage (SM) function.

```q
q)first .matching.sm[F;M]
abi | jon
bea | fred
cath| bob
dee | col
eve | hal
fay | dan
gay | gav
hope| ian
ivy | abe
jan | ed
```

Surprisingly, the male-optimal results are the same, which means there
is only one stable solution to this problem.

```q
q)asc first .matching.sm[M;F]
jon | abi
fred| bea
bob | cath
col | dee
hal | eve
dan | fay
gav | gay
ian | hope
abe | ivy
ed  | jan
```

## Stable Roommates (SR)

The Stable Roommates (SR) problem extends the Stable Marriage (SM)
problem by removing the requirement that there be two disjoint
participant pools.  This problem has a single population of
participants who must rank all other participants.  The result, again,
is a list of stable matches.  Robert W. Irving's solution to this
problem, published in 1985, proceeds in two phases.

Phase 1 applies the Gale-Shapley algorithm, treating the single
dictionary of preferences as both suitor and reviewer.  The resulting
roommate assignments and truncated preferences has paired-down the
list of possible roommates, but suffers from the possibility of
participants finding alternate roommates by a series of cyclical
swaps.

Phase 2 removes these cycles.  The final result is a unique and stable
matching of participants.

[Wikipedia](https://en.wikipedia.org/wiki/Stable_roommates_problem)
has a nicely worked example of the Stable Roommates problem, so we
demonstrate that here.

First we load the preference dictionary `R`&mdash;generating
dictionary keys to match the one-based indexing of the data.

```q
q)show R:(1+til count R)!R:get each read0 `wmate.txt
1| 3 4 2 6 5
2| 6 5 4 1 3
3| 2 4 5 1 6
4| 5 2 3 6 1
5| 3 1 2 4 6
6| 5 1 3 4 2
```

Then we obtain the solution.

```q
q)first aR:.matching.sr R
1| 6
2| 4
3| 5
4| 2
5| 3
6| 1
```

Notice how each participant does, in fact, appear with their roommate
on both the suitor and reviewer list.

We can see how the problem evolved from Phase 1, through each stage of
Phase 2 and finally the final answer by examining the remaining
elements of the returned list.

```q
q)(-1 .Q.s ::) each 1_aR;
1| 4 2 6
2| 6 5 4 1 3
3| 2 4 5
4| 5 2 3 6 1
5| 3 2 4
6| 1 4 2

1| 2 6
2| 6 5 4 1
3| 4 5
4| 5 2 3
5| 3 2 4
6| 1 2

1| ,6
2| 5 4
3| 4 5
4| 2 3
5| 3 2
6| ,1

1| 6
2| 4
3| 5
4| 2
5| 3
6| 1
```

## Hospital-Resident (HR)

The Hospital-Resident (HR) problem extends the Stable Marriage (SM)
problem in a different direction.  Instead of limiting each
participant to a single match, the Hospital-Resident problem allows
one party&mdash;the hospital in this case&mdash;to a capacity greater
than one.

The solution follows the same general form as the Gale-Shapley
(Deferred Acceptance) algorithm but stores the hospital matches in a
list.  Because of this asymmetry of data structures, there are two
solutions to this problem: the hospital-optimal and the
resident-optimal.  The resident-optimal solution is complicated by the
fact that the hospital must compare each new resident proposal with
all existing matches to determine if it should be accepted.  And if
accepted, which existing match should be reneged.

A worked example of the Hospital-Resident problem is displayed on the
`python`
[matching](https://matching.readthedocs.io/en/latest/discussion/hospital_resident/)
library site.  The data is small, so we generate the data structures
explicitly.

First we create the resident and hospital preference dictionaries and
hospital capacity dictionary.

Resident preferences:
```q
q)show R:`A`S`D`L`J!(1#`C;`C`M;`C`M`G;`M`C`G;`C`G`M)
A| ,`C
S| `C`M
D| `C`M`G
L| `M`C`G
J| `C`G`M
```

Hospital preferences:
```q
q)show H:`M`C`G!(`D`L`S`J;`D`A`S`L`J;`D`J`L)
M| `D`L`S`J
C| `D`A`S`L`J
G| `D`J`L
```

Hospital capacities:
```q
q)show C:key[H]!2 2 2
M| 2
C| 2
G| 2
q)
```

Now we obtain the resident-optimal solution,

```q
q)first .matching.hrr[C;H;R]
M| `S`L
C| `A`D
G| ,`J
```

and the hospital-optimal solution.

```q
q)first .matching.hrh[C;H;R]
M| `L`S
C| `D`A
G| ,`J
```

Other than the ordering of the elements, these solutions are the same.
This, again, indicates that it is the only stable match.

## Student-Allocation (SA)

The Student-Allocation (SA) problem extends the Hospital-Allocation
(HR) problem by adding an intermediary between the participants.  In
this problem there exist supervisors and students&mdash;which
correspond to the hospitals and residents.  The supervisors may have
capacity greater then one but the students can only be assigned to a
single supervisor.

The intermediary in this problem are projects, which also have
capacities.  Students rank their preference for projects, not
supervisors.  The rankings, however, imply a preference for a
supervisor because each project is managed by a supervisor.  The
supervisors, in turn, rank students.  This also implies that the
projects have preferences for students.  This is not strictly required
and is not used in this implementation (but is used in the [python
implementation](https://matching.readthedocs.io/en/latest/)).

Again, the asymmetry between suitor and reviewer forces us to create
different supervisor-optimal and student-optimal implementations.  The
implementations are also complicated by the different, but related,
project and supervisor capacities.  Each proposed match must ensure
these capacities are not exceeded. And if they are, a student is
dropped from the over-subscribed project or supervisor&mdash;as the
case may be.

We will use the toy data set form the python matching library
[discussion](https://matching.readthedocs.io/en/latest/discussion/student_allocation).
There are two supervisors X and Y who each have a capacity of 3
students.  They have projects X1, X2 and Y1, Y2 respectively which
each have a capacity 2 students. And finally, there are five students
A, B, C, D, E and F.

We now declare these dictionaries along with the given student and
supervisor preferences.

Project capacities:
```q
q)show PC:`X1`X2`Y1`Y2!2 2 2 2
X1| 2
X2| 2
Y1| 2
Y2| 2
```

Supervisor capacities:
```q
q)show UC:`X`Y!3 3
X| 3
Y| 3
```
Project to supervisor map:

```q
q)show PU:`X1`X2`Y1`Y2!`X`X`Y`Y
X1| X
X2| X
Y1| Y
Y2| Y
```

Supervisor preferences:
```q
q)show U:`X`Y!(`B`C`A`E`D;`B`C`E`D)
X| `B`C`A`E`D
Y| `B`C`E`D
```

Student preferences:
```q
q)show S:`A`B`C`D`E!(`X1`X2;`Y2`X2`Y1;`X1`Y1`X2;`Y2`X1`Y1;`X1`Y2`X2`Y1)
A| `X1`X2
B| `Y2`X2`Y1
C| `X1`Y1`X2
D| `Y2`X1`Y1
E| `X1`Y2`X2`Y1
```

We now obtain the student-optimal allocations,

```q
q)first .matching.sas[PC;UC;PU;U;S]
X1| `A`C
X2| `symbol$()
Y1| ,`D
Y2| `B`E
```

and the supervisor-optimal allocations.

```q
q)first .matching.sau[PC;UC;PU;U;S]
X1| `C`A
X2| `symbol$()
Y1| ,`D
Y2| `B`E
```

Once again, other than the ordering of the elements, these solutions
are the same and there is therefore only one stable match for this
simple example.

[^1]: `wget` is used to download test datasets from https://zenodo.org

[^2]: `yq` is used to convert the hospital-resident (HR) dataset from
    YAML to JSON format so `q` can load it.  As of this writing, the
    elements of the hospital preference lists are stored
    inconsistently: some are stored as strings, others as numbers.
    The call to `yq` ensures they are all stored as numbers when
    converting to JSON format.
    
[^3]: `python` is used with the
[matching](https://matching.readthedocs.io/en/latest/index.html)
library to generate baseline solutions
