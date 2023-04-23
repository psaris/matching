all: test

FILES = sm.q sr.q hr.q sa.q

test:
	set -ex;\
	for f in $(FILES);\
		do q $$f > /dev/null </dev/null;\
  done
