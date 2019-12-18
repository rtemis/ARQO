#!/bin/bash

N=1000
Nmax=2000
Npaso=200
iteration=4

# Set series to 0
for ((i = 1, N = 1000 ; N < Nmax ; N += Npaso, i++)); do
	pfin[$i]=0
done

# Loop for iterations
for ((i = 1 ; i <= iteration ; i++)); do
    echo "Iteration: $i"
	# Loop for sum
	for ((j = 1, N = 1000 ; N < Nmax ; N += Npaso, j++)); do
		echo "Scale $N"
		ps=$(./multiply_ser $N | grep 'time' | awk {'print $2'})
		echo "Time: $ps"
		pfin[$j]=$(python -c "print( ${pfin[$j]} + $ps)")
	done
done

# loop for avg
for ((i = 1, N = 1000 ; N < Nmax ; N += Npaso, i++)); do
    pfin[$i]=$(python -c "print(${pfin[$i]} / $iteration)")
    echo "AVG: ${pfin[$i]}"
done

echo ""

# Loop for threads
for ((j = 1 ; j <= 4 ; j++)); do
	fDAT=mult_$j.dat
	rm -f $fDAT
	touch $fDAT
	
	# Reset arrays
	for ((i = 1, N = 1000 ; N < Nmax ; N += Npaso, i++)); do
	       pp1[$i]=0
       	   pp2[$i]=0
	       pp3[$i]=0
	done

	echo "$OMP_NUM_THREADS" 
	echo ""
	echo "Running loop: threads $j"	
    export OMP_NUM_THREADS=$j

	# Set repetitions
	for ((i = 1 ; i <= iteration ; i++));do
		echo "Running loop $i/$iteration"
		
		for ((k = 1, N = 1000 ; N < Nmax ; k++, N += Npaso)); do 
			echo "N Size: $N"
			p1=$(./multiply_par1 $N | grep 'time' | awk {'print $2'})
			echo "Time 1: $p1"
			pp1[$k]=$(python -c "print(${pp1[$k]} + $p1)")
			p2=$(./multiply_par2 $N | grep 'time' | awk {'print $2'})
			echo "Time 2: $p2"
			pp2[$k]=$(python -c "print(${pp2[$k]} + $p2)")	
			p3=$(./multiply_par3 $N | grep 'time' | awk {'print $2'})
			echo "Time 3: $p3"
			pp3[$k]=$(python -c "print(${pp3[$k]} + $p3)")
		done
	done
	
	for((i = 1, N = 1000 ; N < Nmax ; N += Npaso, i++)); do
		pfin1=$(python -c "print(${pp1[$i]} / $iteration)")
		pfin2=$(python -c "print(${pp2[$i]} / $iteration)")
		pfin3=$(python -c "print(${pp3[$i]} / $iteration)")

		echo "Writing to file"
		echo "$N  $pfin1  $pfin2  $pfin3  ${pfin[$i]}" >> $fDAT
	done
done	
