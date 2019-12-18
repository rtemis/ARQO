fPNG=hilo1.png
fPNG=acelearion.png

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


gnuplot << END_GNUPLOT
set title "Aceleracion segun tam. vector"
set ylabel "Aceleracion"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "Aceleracion"
plot "$aceleracion_3.dat" using 1:2 with lines lw 2 title "Serie", \
     "$fDAT2" using 1:3 with lines lw 2 title "Paralel 1 thread", \
		 "$fDAT2" using 1:4 with lines lw 2 title "Paralel 2 thread", \
		 "$fDAT2" using 1:5 with lines lw 2 title "Paralel 3 thread", \
		 "$fDAT2" using 1:6 with lines lw 2 title "Paralel 4 thread"
replot
quit
END_GNUPLOT
