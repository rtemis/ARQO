rm -f cache_mat.png

echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Normal Traspuesta Cache Read-Write Misses"
set ylabel "Number of Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set yrange [1000000:]
set output "cache_mat.png"
plot "normcache.dat" using 1:2 with lines lw 2 title "Normal Lectura", \
     "normcache.dat" using 1:3 with lines lw 4 title "Normal Escritura",  \
	"trascache.dat" using 1:2 with lines lw 2 title "Traspuesta Lectura", \
     "trascache.dat" using 1:3 with lines lw 2 title "Traspuesta Escritura"
replot
quit
END_GNUPLOT

