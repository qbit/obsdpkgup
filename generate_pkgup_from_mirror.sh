#!/bin/sh

IFS="
"

mirror=$(cat /etc/installurl)

if [ -z "$arch" ]
then
	arch=$(arch -s)
fi

if [ -z "$version" ]
then
	if (sysctl -n kern.version |egrep -- '-current|-beta' > /dev/null)
	then
		version="snapshots"
	else
		version=$(sysctl -n kern.version |head -n 1 |cut -b 9-11)
	fi
fi

if [ a$version = asnapshots ]
then
	url="$mirror/$version/packages/$arch"
else
	url="$mirror/$version/packages-stable/$arch"
fi


#old=`pkg_info -f quirks | sed -En '/@digital-sig/ s/(.*signify2:|:external)//gp'`
#new=`PKG_DBDIR=/var/empty pkg_info -f quirks | sed -En '/@digital-sig/ s/(.*signify2:|:external)//gp'`
#if [[ $old == $new ]]; then
#	echo "Already up-to-date: $old"
#	exit
#fi

index=$(curl $url/index.txt 2>/dev/null)

rm -f index.pkgup

for line in $index
do
	pkg=$(echo "$line" |awk '{print $10}')
	if echo $pkg |grep '\.tgz$'
	then
		curl $url/$pkg |tar xzqf - +CONTENTS
		hash=$(cat +CONTENTS |egrep '^@name|^@depend|^@version|^@wantlib' |sha256 -b)
		echo "$pkg" "$hash" >> index.pkgup
	fi
done

rm -f index.pkgup.gz +CONTENTS
gzip index.pkgup
