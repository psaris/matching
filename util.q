\d .util

/ throw verbose exception if x <> y
assert:{if[not x~y;'`$"expecting '",(-3!x),"' but found '",(-3!y),"'"]}
