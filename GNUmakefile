all: test

HRJSNS = capacities.json hospitals.json residents.json
HRYMLS = $(HRJSNS:.json=.yml)

$(HRYMLS) :
	wget https://zenodo.org/record/3688091/files/$@

$(HRJSNS) : %.json :  %.yml
	yq '(.. | select(tag == "!!float")) tag= "!!str"' -o=json $^ > $@

SACSVS = students.csv projects.csv supervisors.csv

$(SACSVS) :
	wget https://zenodo.org/record/3514287/files/$@

inputs: $(HRJSNS) $(SACSVS)

SASOL = student_solution.json supervisor_solution.json

$(SASOL) : %_solution.json : $(SACSVS)
	python sa.py $^ $*

HRSOL = resident_solution.json hospital_solution.json

$(HRSOL) : %_solution.json : $(HRJSNS)
	python hr.py $^ $*

solutions: $(HRSOL) $(SASOL)

TESTS = sm.q sr.q hr.q sa.q

test: solutions
	set -ex;\
	for f in $(TESTS);\
		do q $$f > /dev/null </dev/null;\
  done

clean-solutions:
	$(RM) $(HRSOL) $(SASOL)

clean-inputs:
	$(RM) $(HRJSNS)  $(HRYMLS) $(SACSVS)

clean: clean-inputs clean-solutions

