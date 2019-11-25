# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# Loop variables
Ninicio=16144
Npaso=64
Nfinal=17168

# Number of iterations
reps=20

# Files to be created
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png

# Erase the files if they already exist
rm -f $fDAT fPNG

# Create blank .dat file
touch $fDAT

echo "Running slow and fast..."
# Set up arrays
for ((N = Ninicio, j = 1 ; N <=Nfinal ; N += Npaso, j++)); do
	oldF[$j]="0"
	oldS[$j]="0"
done

# Iteration loop
for ((i = 1 ; i <= reps ; i++)); do
	# Slow loop
	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		echo "Slow N: $N / $Nfinal..."
		# Calculate slow time
		slowTime=$(./slow $N | grep 'time' | awk '{print $3}')
		x=${oldS[$j]}
		# Update slow value for average calculation
		oldS[$j]=$(python -c "print( $slowTime + $x )")
	done
	# Fast loop
	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		echo "Fast N: $N / $Nfinal..."
		# Calculate fast time
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')
		x=${oldF[$j]}
		# Update fast value for average calculation
		oldF[$j]=$(python -c "print( $fastTime + $x )")
	done
done

# Loop for writing to file
for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
	x=$(python -c "print(${oldF[$j]} / $reps)")
	y=$(python -c "print(${oldS[$j]} / $reps)")
	echo "$N     $y     $x"
	echo "$N     $y     $x" >> $fDAT
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
