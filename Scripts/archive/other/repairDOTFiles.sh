#! /bin/bash

for f in $1/*top.dot
do
	cat "$f" | sed -e 's/\t/ /g' -e 's/overlap=\"scale\"//g' > "$f.fixed.dot"
done
