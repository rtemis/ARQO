#!/bin/bash

N=1000
fDAT=multpar.dat

rm -f $fDAT
for ((j = 1 ; j < 5 ; N += 150, j++)); do
	echo "Running loop: $j scale $N"
	pp1=0
	pp2=0
	pp3=0
	pp4=0
	for ((i = 1 ; i < 5 ; i++));do
		echo "Running $i/4 of loop $j"
		p1=$(./multiply_par1 $N | grep 'time' | awk {'print $2'})
		pp1=$(python -c "print($pp1 + $p1)")
		p2=$(./multiply_par2 $N | grep 'time' | awk {'print $2'})
		pp2=$(python -c "print($pp2 + $p2)")	
		p3=$(./multiply_par3 $N | grep 'time' | awk {'print $2'})
		pp3=$(python -c "print($pp3 + $p3)")
		p4=$(./multiply_ser $N | grep 'time' | awk {'print $2'})
		pp4=$(python -c "print($pp4 + $p4)")
	done
	pp1=$(python -c "print($pp1 / 4)")
	pp2=$(python -c "print($pp2 / 4)")
	pp3=$(python -c "print($pp3 / 4)")
	pp4=$(python -c "print($pp4 / 4)")
	echo "Writing to file"
	echo "$N  $pp1  $pp2  $pp3  $pp4" >> $fDAT
done	
