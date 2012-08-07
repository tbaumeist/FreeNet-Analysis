#! /bin/bash

for f in $1/*top.dot
do
	neato -Tdot "$f" | sed -e 's/\t[0-9]*//g' > "$f.fixed.dot"
done
