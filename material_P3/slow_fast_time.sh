# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables

# Variables de bucle interno
Ninicio=16144
Npaso=64
Nfinal=17168

# Variables de bucle externo
reps=10
nums=(((17168-16144)/Npaso))

fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png


# borrar el fichero DAT y el fichero PNG
rm -f $fDAT fPNG
rm -f $fMediaF fMediaS

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
for ((i = 1 ; i <= reps ; i++)); do
	# bucle para N desde P hasta Q
	#for N in $(seq $Ninicio $Npaso $Nfinal);
	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		echo "N: $N / $Nfinal..."

		# ejecutar los programas slow y fast consecutivamente con tamaño de matriz N
		# para cada uno, filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		slowTime[$i,$j]=$(./slow $N | grep 'time' | awk '{print $3}')
	done

	for ((N = Ninicio, j = 1 ; N <= Nfinal ; N += Npaso, j++)); do
		fastTime[$i,$j]=$(./fast $N | grep 'time' | awk '{print $3}')

	done 
done

for ((j = 1 ;  j <= nums; j++)); do
	for ((i = 1, mediaS = 0, mediaF = 0, N = Ninicio ; N <= Nfinal; i++, N += Npaso )); do
		mediaS=$(python media.py --add mediaS slowTime[$i,$j])
		mediaF=$(python media.py --add mediaF fastTime[$i,$j])
	done
	finalS=$(python media.py --avg $mediaS $nums)
	finalF=$(ptyhon media.py --avg $mediaF $nums)
	
	echo "$N	$finalS	$finalF" >> $fDAT
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
