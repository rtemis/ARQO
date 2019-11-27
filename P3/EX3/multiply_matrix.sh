# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# Loop variables
Ninicio=1792
Npaso=16
Nfinal=2048

# Number of iterations
reps=5

# Files to be created
fDAT=mult.dat
fPNG1=mult_cache.png
fPNG2=mult_time.png

# Erase the files if they already exist
rm -f $fDAT fPNG1 fPNG2

# Create blank .dat file
touch $fDAT

echo "Running normal y tras..."
# Set up arrays
for ((N = Ninicio, j = 1 ; N <=Nfinal ; N += Npaso, j++)); do
	oldN[$j]="0"
	oldT[$j]="0"
	D1mrN[$j]="0"
	D1mwN[$j]="0"
	D1mrT[$j]="0"
	D1mwT[$j]="0"
done

# Iteration loop
for ((i = 1 ; i <= reps ; i++)); do
    echo "ITERATION: $i"
	# Slow loop
	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		echo "Mult Normal N: $N / $Nfinal..."
		normal=$(./normal $N | grep 'time' | awk '{print $2}')
		x=${oldN[$j]}
		oldN[$j]=$(python -c "print( $normal + $x )")
	done

	# Slow loop
	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		echo "Mult Tras N: $N / $Nfinal..."
		traspuesta=$(./traspuesta $N | grep 'time' | awk '{print $2}')
		x=${oldT[$j]}
		oldT[$j]=$(python -c "print( $traspuesta + $x )")
	done
done

for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
	d=$(valgrind --tool=cachegrind --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 --cachegrind-out-file=temp.dat ./normal $N | grep 'time' | awk '{print $2}')
	missesR=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $5}')
	missesW=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $8}')
	x=${D1mrN[$j]}
	y=${D1mwN[$j]}
	# Update slow value for average calculation
	D1mrN[$j]=$(python -c "print( int('$missesR'.replace(',', '')) + $x )")
	D1mwN[$j]=$(python -c "print( int('$missesW'.replace(',', '')) + $y )")
done

for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
	d=$(valgrind --tool=cachegrind --I1=8192,1,64 --D1=8192,1,64 --LL=8388608,1,64 --cachegrind-out-file=temp.dat ./traspuesta $N)
	missesR=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $5}')
	missesW=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $8}')
	x=${D1mrT[$j]}
	y=${D1mwT[$j]}
	# Update slow value for average calculation
	D1mrT[$j]=$(python -c "print( int('$missesR'.replace(',', '')) + $x )")
	D1mwT[$j]=$(python -c "print( int('$missesW'.replace(',', '')) + $y )")
done

# Loop for writing to file
for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
	timeN=$(python -c "print(${oldN[$j]} / $reps)")
	timeT=$(python -c "print(${oldT[$j]} / $reps)")
	normalR=$(python -c "print(${D1mrN[$j]})")
	normalW=$(python -c "print(${D1mwN[$j]})")
	trasR=$(python -c "print(${D1mrT[$j]})")
	trasW=$(python -c "print(${D1mwT[$j]})")
	echo "$N	$timeN	$normalR	$normalW	$timeT	$trasR	$trasW" >> $fDAT
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Normal-Traspuesta Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG2"
plot "$fDAT" using 1:2 with lines lw 2 title "normal", \
     "$fDAT" using 1:5 with lines lw 2 title "traspuesta"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Normal-Traspuesta Cache Misses"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG1"
plot "$fDAT" using 1:3 with lines lw 2 title "normal read", \
     "$fDAT" using 1:4 with lines lw 2 title "normal write", \
		 "$fDAT" using 1:6 with lines lw 2 title "traspuesta read", \
		 "$fDAT" using 1:7 with lines lw 2 title "traspuesta write",
replot
quit
END_GNUPLOT
