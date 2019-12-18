fPNG=hilo1.png


echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Single Thread Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "mult_1.dat" using 1:2 with lines lw 2 title "Parallel 1", \
     "mult_1.dat" using 1:3 with lines lw 2 title "Parallel 2", \
     "mult_1.dat" using 1:4 with lines lw 2 title "Parallel 3", \
     "mult_1.dat" using 1:5 with lines lw 2 title "Serie"
replot
quit
END_GNUPLOT


fPNG=hilo2.png

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Double Thread Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "mult_2.dat" using 1:2 with lines lw 2 title "Parallel 1", \
     "mult_2.dat" using 1:3 with lines lw 2 title "Parallel 2", \
     "mult_2.dat" using 1:4 with lines lw 2 title "Parallel 3", \
     "mult_2.dat" using 1:5 with lines lw 2 title "Serie"
replot
quit
END_GNUPLOT

fPNG=hilo3.png

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Triple Thread Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "mult_3.dat" using 1:2 with lines lw 2 title "Parallel 1", \
     "mult_3.dat" using 1:3 with lines lw 2 title "Parallel 2", \
     "mult_3.dat" using 1:4 with lines lw 2 title "Parallel 3", \
     "mult_3.dat" using 1:5 with lines lw 2 title "Serie"
replot
quit
END_GNUPLOT

fPNG=hilo4.png

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Quadruple Thread Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "mult_4.dat" using 1:2 with lines lw 2 title "Parallel 1", \
     "mult_4.dat" using 1:3 with lines lw 2 title "Parallel 2", \
     "mult_4.dat" using 1:4 with lines lw 2 title "Parallel 3", \
     "mult_4.dat" using 1:5 with lines lw 2 title "Serie"
replot
quit
END_GNUPLOT

fPNG=Acelearion_1.png

echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Aceleracion segun tam. vector 1 hilo"
set ylabel "Aceleracion"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "aceleracion_1.dat" using 1:2 with lines lw 2 title "a", \
     "aceleracion_1.dat" using 1:3 with lines lw 2 title "b", \
		 "aceleracion_1.dat" using 1:4 with lines lw 2 title "c", \
		 "aceleracion_1.dat" using 1:5 with lines lw 2 title "c"
replot
quit
END_GNUPLOT

fPNG=Acelearion_2.png
echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Aceleracion segun tam. vector 2 hilos"
set ylabel "Aceleracion"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "aceleracion_2.dat" using 1:2 with lines lw 2 title "q", \
     "aceleracion_2.dat" using 1:3 with lines lw 2 title "w", \
		 "aceleracion_2.dat" using 1:4 with lines lw 2 title "re", \
		 "aceleracion_2.dat" using 1:5 with lines lw 2 title "f"
replot
quit
END_GNUPLOT

fPNG=Acelearion_3.png

echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Aceleracion segun tam. vector 3 hilos"
set ylabel "Aceleracion"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "aceleracion_3.dat" using 1:2 with lines lw 2 title "r", \
     "aceleracion_3.dat" using 1:3 with lines lw 2 title "r", \
		 "aceleracion_3.dat" using 1:4 with lines lw 2 title "rf", \
		 "aceleracion_3.dat" using 1:5 with lines lw 2 title "g"
replot
quit
END_GNUPLOT

fPNG=Acelearion_4.png

echo "Generating plot..."
gnuplot << END_GNUPLOT
set title "Aceleracion segun tam. vector 4 hilos"
set ylabel "Aceleracion"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "aceleracion_4.dat" using 1:2 with lines lw 2 title "f", \
     "aceleracion_4.dat" using 1:3 with lines lw 2 title "f", \
		 "aceleracion_4.dat" using 1:4 with lines lw 2 title "f", \
		 "aceleracion_4.dat" using 1:5 with lines lw 2 title "f"
replot
quit
END_GNUPLOT
