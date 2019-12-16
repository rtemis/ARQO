#!/bin/bash

N=100000

fDAT=pescalar.dat
iter=5

rm -f $fDAT
for ((j = 1 ; j <= 10 ; N += 999990000, j++)); do
	echo "Running loop: $j scale $N"
	ps=0
	pp1=0
	pp2=0
	pp3=0
	pp4=0
	for ((i = 1 ; i <= $iter ; i++));do
		echo "Running $i/$iter of loop $j"
		p0=$(./pescalar_serie $N | grep 'Tiempo' | awk {'print $2'})
		ps=$(python -c "print($ps + $p0)")
		p1=$(./pescalar_par2 $N | grep 'Tiempo' | awk {'print $2'})
		pp1=$(python -c "print($pp1 + $p1)")
		p2=$(./pescalar_par2_2 $N | grep 'Tiempo' | awk {'print $2'})
		pp2=$(python -c "print($pp2 + $p2)")
		p3=$(./pescalar_par2_3 $N | grep 'Tiempo' | awk {'print $2'})
		pp3=$(python -c "print($pp3 + $p3)")
		p4=$(./pescalar_par2_4 $N | grep 'Tiempo' | awk {'print $2'})
		pp4=$(python -c "print($pp4 + $p4)")
	done
	ps=$(python -c "print($ps / $iter)")
	pp1=$(python -c "print($pp1 / $iter)")
	pp2=$(python -c "print($pp2 / $iter)")
	pp3=$(python -c "print($pp3 / $iter)")
	pp4=$(python -c "print($pp4 / $iter)")
	echo "Writing to file"
	echo "$N $ps  $pp1  $pp2  $pp3  $pp4" >> $fDAT
done
