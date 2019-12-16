#!/bin/bash

N=100
Nmax=200

# Set series to 0
for ((i = 1 ; i < 5 ; i++)); do
	pfin[$i]=0
done

# Loop for iterations
for ((i = 1 ; i < 5 ; i++)); do
    echo "Iteration: $i"
	# Loop for sum
	for ((j = 1, N = 100 ; N < Nmax ; N += 25, j++)); do
		echo "Scale $N"
		ps=$(./multiply_ser $N | grep 'time' | awk {'print $2'})
		echo "Time: $ps"
		pfin[$j]=$(python -c "print( ${pfin[$j]} + $ps)")
	done
done

# loop for avg
for ((i = 1 ; i < 5 ; i++)); do
    pfin[$i]=$(python -c "print(${pfin[$i]} / 4)")
    echo "AVG: ${pfin[$i]}"
done

echo ""

# Loop for threads
for ((j = 1 ; j <= 4 ; j++)); do
	fDAT=mult_$j.dat
	rm -f $fDAT
	touch $fDAT
	
	# Reset arrays
	for((i = 1 ; i < 5 ; i++)); do
	       pp1[$i]=0
       	       pp2[$i]=0
	       pp3[$i]=0
	done

	echo "$OMP_NUM_THREADS" 
	echo ""
	echo "Running loop: threads $j"	
        export OMP_NUM_THREADS=$j
	# Set repetitions
	for ((i = 1 ; i < 5 ; i++));do
		echo "Running loop $i/4"
		
		for ((k = 1, N = 100 ; N < Nmax ; k++, N += 25)); do 
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
	
	for((i = 1, N = 100 ; i < 5 ; N +=25, i++)); do
		pfin1=$(python -c "print(${pp1[$i]} / 4)")
		pfin2=$(python -c "print(${pp2[$i]} / 4)")
		pfin3=$(python -c "print(${pp3[$i]} / 4)")

		echo "Writing to file"
		echo "$N  $pfin1  $pfin2  $pfin3  ${pfin[$i]}" >> $fDAT
	done
done	
