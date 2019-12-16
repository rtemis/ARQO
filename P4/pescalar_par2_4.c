// ----------- Arqo P4-----------------------
// pescalar_par2
//
#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"
#include <omp.h>


int main(int argc, char** argv)
{
	if(argc < 1){
		printf("Error de agumentos: ./pescalar N\n");
		exit(0);
	}

	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
	long tam;

	tam = atoi(argv[1]);
	A = generateVector(tam);
	B = generateVector(tam);

	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}
	omp_set_num_threads(4);


	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	#pragma omp parallel for reduction(+:sum)
	for(k=0;k<tam;k++)
	{
		//printf("sum: %f\n", sum);
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("Resultado: %f\n",sum);
	printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
