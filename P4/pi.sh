#!/bin/bash

N=1000
fDAT=mult.dat

rm -f $fDAT

for ((i = 1 ; i < 5 ; i++, N += 500));do
	echo "Running $i/5"
	p1=$(./multiply_par1 $N | grep 'time' | awk {'print $2'})
	p2=$(./multiply_par2 $N | grep 'time' | awk {'print $2'})
	p3=$(./multiply_par3 $N | grep 'time' | awk {'print $2'})
	p4=$(./multiply_ser $N | grep 'time' | awk {'print $2'})
	echo "$N  $p1  $p2  $p3  $p4" >> $fDAT
done	
