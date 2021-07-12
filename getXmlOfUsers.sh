#!/bin/bash

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
echo "<users>"

for i in $(cut -d: -f1,3,4,6,7 /etc/passwd)
do
	echo $i > /tmp/ligne.txt
	
	shell=$(cut -d: -f5 /tmp/ligne.txt)
	
	if [ $shell == "/bin/bash" ]
	then	
		name=$(cut -d: -f1 /tmp/ligne.txt)
		uid=$(cut -d: -f2 /tmp/ligne.txt)
		gid=$(cut -d: -f3 /tmp/ligne.txt)
		home=$(cut -d: -f4 /tmp/ligne.txt)
		
		
		taille=$(du -s $home | cut -f1)
#		fingerprint= "A trouver"
	
		echo "	<user>"
		echo "		<name>$name</name>"
		echo "		<uid>$uid</uid>"
		echo "		<gid>$gid</gid>"
		echo "		<home>$home</home>"
		echo "		<shell>$shell</shell>"
		echo "		<taille>$taille</taille>"
#		echo "		<fingerprint>$fingerprint</fingerprint>"
		echo "		<fingerprint>A trouver</fingerprint>"
		echo "	</user>"
	fi
done
echo "</users>"

rm /tmp/ligne.txt
