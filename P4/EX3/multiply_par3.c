
#include "arqo4.h"
#include <omp.h>

void multiplica(float **matrix_a, float **matrix_b, float **matrix_c, int n){
  int i, j, k;
  float aux = 0;
  //i es fila de a, fila de c
  //j es columna de b, columna de c
  //k es para moverte por la fila de a, moverte por la columna de b
  for(i = 0; i < n; i++){
    for(j = 0; j < n; j++){
      #pragma omp parallel for reduction(+:aux)
      for(k = 0; k < n; k++){
        aux += matrix_a[i][k] * matrix_b[k][j];
      }
      matrix_c[i][j] = aux;
      aux = 0.0;
    }
  }
}


void imprime_matrix(float **matriz, int n){
  int i, j;

  printf("-----MATRIZ RESULTANTE-----\n");
  for(i = 0; i < n; i++){
    for(j = 0; j < n; j++){
      printf("%lf\t", matriz[i][j]);
    }
    printf("\n");
  }
}

int main(int argc, char** argv){
  float **matrix_a = NULL;
  float **matrix_b = NULL;
  float **matrix_c = NULL;
  int n, threads;

  struct timeval fin, ini;

  if(argc < 2){
    printf("ERROR de argumentos:  ./multiplica_matriz N\n");
    return -1;
    }

  n = atoi(argv[1]);
  threads = atoi(argv[2]);
  matrix_a = generateMatrix(n);
  matrix_b = generateMatrix(n);
  matrix_c = generateEmptyMatrix(n);

  //printf("----------MULTIPLICACION NORMAL----------\n");

  omp_set_num_threads(threads);
  gettimeofday(&ini, NULL);

  multiplica(matrix_a, matrix_b, matrix_c, n);

  gettimeofday(&fin, NULL);

  printf("time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
   //printf("A:\n");
   //imprime_matrix(matrix_a, n);
   //printf("\nB:\n");
   //imprime_matrix(matrix_b, n);
   //printf("\nC:\n");
   //imprime_matrix(matrix_c, n);


  freeMatrix(matrix_a);
  freeMatrix(matrix_b);
  freeMatrix(matrix_c);

  return 0;
}
