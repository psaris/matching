all: test

FILES = smp.q srp.q hrp.q sap.q

test:
	set -ex;\
	for f in $(FILES);\
		do q $$f > /dev/null </dev/null;\
  done
