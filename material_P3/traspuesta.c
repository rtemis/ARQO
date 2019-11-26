#include "multiplica_matriz.h"

int main(int argc, char** argv){
  tipo **matrix_a = NULL;
  tipo **matrix_b = NULL;
  tipo **matrix_c = NULL;
  tipo **matrix_tras = NULL;
  int n;

  struct timeval fin, ini;

  if(argc < 2){
    printf("ERROR de argumentos:  ./multiplica_matriz N\n");
    return -1;
    }

  n = atoi(argv[1]);
  matrix_a = generateMatrix(n);
  matrix_b = generateMatrix(n);
  matrix_c = generateEmptyMatrix(n);
  matrix_tras = generateEmptyMatrix(n);

  //printf("----------MULTIPLICACION TRAS----------\n");

  gettimeofday(&ini, NULL);

  genera_transpuesta(matrix_b, matrix_tras, n);

  multiplica_tras(matrix_a, matrix_tras, matrix_c, n);

  gettimeofday(&fin, NULL);

  printf("time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

  // printf("A:\n");
  // imprime_matrix(matrix_a, n);
  // printf("\nB:\n");
  // imprime_matrix(matrix_b, n);
  // printf("\nTras:\n");
  // imprime_matrix(matrix_tras, n);
  // printf("\nC:\n");
  //imprime_matrix(matrix_c, n);


  freeMatrix(matrix_a);
  freeMatrix(matrix_b);
  freeMatrix(matrix_c);
  freeMatrix(matrix_tras);

  return 0;
}
