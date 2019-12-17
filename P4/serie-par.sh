#!/bin/bash

N=10000000

fDAT=pescalar.dat
fDAT2=aceleracion.dat
iter=5

rm -f $fDAT
for ((j = 1 ; j <= 10 ; N += 10000000, j++)); do
	echo "Running loop: $j scale $N"
	ps=0
	pp1=0
	pp2=0
	pp3=0
	pp4=0

	acc1[$j]=0
	acc2[$j]=0
	acc3[$j]=0
	acc4[$j]=0
	acc5[$j]=0
	for ((i = 1 ; i <= $iter ; i++));do
		echo "Running $i/$iter of loop $j"
		p0=$(./pescalar_serie $N | grep 'Tiempo' | awk {'print $2'})
		ps=$(python -c "print($ps + $p0)")
		p1=$(./pescalar_par2 $N | grep 'Tiempo' | awk {'print $2'})
		pp1=$(python -c "print($pp1 + $p1)")
		p2=$(./pescalar_par2_2 $N | grep 'Tiempo' | awk {'print $2'})
		pp2=$(python -c "print($pp2 + $p2)")
		p3=$(./pescalar_par2_3 $N | grep 'Tiempo' | awk {'print $2'})
		pp3=$(python -c "print($pp3 + $p3)")
		p4=$(./pescalar_par2_4 $N | grep 'Tiempo' | awk {'print $2'})
		pp4=$(python -c "print($pp4 + $p4)")

	done
	acc1[$j]=$(python -c "print($ps / $iter)")
	acc2[$j]=$(python -c "print($pp1 / $iter)")
	acc3[$j]=$(python -c "print($pp2 / $iter)")
	acc4[$j]=$(python -c "print($pp3 / $iter)")
	acc5[$j]=$(python -c "print($pp4 / $iter)")

	echo "Writing to file"
	echo "$N ${acc1[$j]}  ${acc2[$j]}  ${acc3[$j]}  ${acc4[$j]}  ${acc5[$j]}  " >> $fDAT
done

for ((j = 2 ; j <= 10 ; j++)); do

	mej1=$(python -c "print(${acc1[$j]} / ${acc1[$j-1]})")
	mej2=$(python -c "print(${acc2[$j]} / ${acc2[$j-1]})")
	mej3=$(python -c "print(${acc3[$j]} / ${acc3[$j-1]})")
	mej4=$(python -c "print(${acc4[$j]} / ${acc4[$j-1]})")
	mej5=$(python -c "print(${acc5[$j]} / ${acc5[$j-1]})")

	echo "$mej1 $mej2 $mej3 $mej4 $mej5 " >> $fDAT2

done




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
		 "$fDAT" using 1:6 with lines lw 2 title "Paralel 4 thread"
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
plot "$fDAT2" using 1:2 with lines lw 2 title "Serie", \
     "$fDAT2" using 1:3 with lines lw 2 title "Paralel 1 thread", \
		 "$fDAT2" using 1:4 with lines lw 2 title "Paralel 2 thread", \
		 "$fDAT2" using 1:5 with lines lw 2 title "Paralel 3 thread", \
		 "$fDAT2" using 1:6 with lines lw 2 title "Paralel 4 thread"
replot
quit
END_GNUPLOT
