# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# Loop variables
Ninicio=5072
Npaso=64
Nfinal=5584

# Number of iterations
reps=2

fPNG1=cache_lectura.png
fPNG2=cache_escritura.png

rm -f $fPNG1 $fPNG2

echo "Running slow and fast..."
for ((cache = 1024 ; cache <= 8192 ; cache *= 2 )); do
	# Files to be created
	fDAT=cache_$cache.dat

	# Erase the files if they already exist
	rm -f $fDAT 

	# Create blank .dat file
	touch $fDAT

	# Set up arrays
	for ((N = Ninicio, j = 1 ; N <=Nfinal ; N += Npaso, j++)); do
		D1mrF[$j]="0"
		D1mwF[$j]="0"
		D1mrS[$j]="0"
		D1mwS[$j]="0"
	done
	# Iteration loop
	for ((i = 1 ; i <= reps ; i++)); do
		# Slow loop
		for ((N = Ninicio, j = 1; N <= Nfinal ; N += Npaso, j++)); do
			echo "Slow N: $N / $Nfinal..."
			# Calculate slow cache misses
			echo "valgrind --tool=cachegrind --I1=$cache,1,64 --cachegrind-out-file=temp.dat ./slow $N"
			missesR=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $5}')
			missesW=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $8}')
			x=${D1mrS[$j]}
			y=${D1mwS[$j]}
			# Update slow value for average calculation
			D1mrS[$j]=$(python -c "print( $missesR + $x )")
			D1mwS[$j]=$(python -c "print( $missesW + $y )")
		done
		# Fast loop
		for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
			echo "Slow N: $N / $Nfinal..."
			# Calculate fast cache misses
			echo "valgrind --tool=cachegrind --I1=$cache,1,64 --cachegrind-out-file=temp.dat ./fast $N"
			missesR=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $5}')
			missesW=$(cg_annotate temp.dat | head -n 30 | grep 'PROGRAM' | awk '{print $8}')
			x=${D1mrF[$j]}
			y=${D1mwF[$j]}
			# Update fast value for average calculation
			D1mrS[$j]=$(python -c "print( $missesR + $x )")
			D1mwS[$j]=$(python -c "print( $missesW + $y )")
		done
	done

	# Loop for writing to file
	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		slowR=$(python -c "print(${D1mrS[$j]} / $reps)")
		slowW=$(python -c "print(${D1mwS[$j]} / $reps)")
		fastR=$(python -c "print(${D1mrF[$j]} / $reps)")
		fastW=$(python -c "print(${D1mwF[$j]} / $reps)")
		echo "$N $slowR $slowW $fastR $fastW" >> $fDAT
	done
done

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Slow-Fast Cache Read Misses"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG1"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:4 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Slow-Fast Cache Write Misses"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG2"
plot "$fDAT" using 1:3 with lines lw 2 title "slow", \
     "$fDAT" using 1:5 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT