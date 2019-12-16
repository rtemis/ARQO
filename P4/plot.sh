
fDAT=pescalar.dat

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Serie Par2 Time"
set ylabel "Execution time (s)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "Serie_ParThreads_Time"
plot "$fDAT" using 1:2 with lines lw 2 title "Serie", \
     "$fDAT" using 1:3 with lines lw 2 title "Paralel 1 thread", \
		 "$fDAT" using 1:4 with lines lw 2 title "Paralel 2 thread", \
		 "$fDAT" using 1:5 with lines lw 2 title "Paralel 3 thread", \
		 "$fDAT" using 1:5 with lines lw 2 title "Paralel 4 thread"
replot
quit
END_GNUPLOT
