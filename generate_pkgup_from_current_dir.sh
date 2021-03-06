#!/bin/sh

rm -f index.pkgup

for pkg in $(ls *.tgz)
do
	tar xzqf "$pkg" +CONTENTS
	echo "$pkg" $(cat +CONTENTS |egrep '^@name|^@depend|^@version|^@wantlib' |sha256 -b) >> index.pkgup
done

rm -f index.pkgup.gz +CONTENTS
gzip -f index.pkgup
