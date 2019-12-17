
fDAT2=aceleracion.dat


echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"

gnuplot << END_GNUPLOT
set title "Aceleracion segun tam. vector"
set ylabel "Aceleracion"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "Aceleracion"
plot "$fDAT2" using 1:2 with lines lw 2 title "Serie", \
     "$fDAT2" using 1:3 with lines lw 2 title "Paralel 1 thread", \
		 "$fDAT2" using 1:4 with lines lw 2 title "Paralel 2 thread", \
		 "$fDAT2" using 1:5 with lines lw 2 title "Paralel 3 thread", \
		 "$fDAT2" using 1:6 with lines lw 2 title "Paralel 4 thread"
replot
quit
END_GNUPLOT
