rm -f time_mat.png

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Normal Traspuesta Execution Time"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set yrange [*:]
set output "time_mat.png"
plot "mult.dat" using 1:2 with lines lw 2 title "Normal", \
	"mult.dat" using 1:5 with lines lw 2 title "Traspuesta "
replot
quit
END_GNUPLOT

