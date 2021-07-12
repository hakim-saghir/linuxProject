#!/bin/bash

for i in $(ls /home/)
do
	user="/var/backups/$i.$(date +%m-%d-%y).$(date +%H-%M).tgz"
	tar zcvf $user "/home/$i"
done
