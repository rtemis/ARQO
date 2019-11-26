#include "arqo3.h"


void multiplica(tipo **matrix_a, tipo **matrix_b, tipo **matrix_c, int n){
  int i, j, k;
  tipo aux = 0;
  //i es fila de a, fila de c
  //j es columna de b, columna de c
  //k es para moverte por la fila de a, moverte por la columna de b

  for(i = 0; i < n; i++){
    for(j = 0; j < n; j++){
      for(k = 0; k < n; k++){

        aux += matrix_a[i][k] * matrix_b[k][j];
      }
      matrix_c[i][j] = aux;
      aux = 0.0;
    }
  }
}

void multiplica_tras(tipo **matrix_a, tipo **matrix_b, tipo **matrix_c, int n){
  int i, j, k;
  tipo aux = 0;

  for(i = 0; i < n; i++){
    for(j = 0; j < n; j++){
      for(k = 0; k < n; k++){

        aux += matrix_a[i][k] * matrix_b[j][k];
      }
      matrix_c[i][j] = aux;
      aux = 0.0;
    }
  }
}

void imprime_matrix(tipo **matriz, int n){
  int i, j;

  printf("-----MATRIZ RESULTANTE-----\n");
  for(i = 0; i < n; i++){
    for(j = 0; j < n; j++){
      printf("%lf\t", matriz[i][j]);
    }
    printf("\n");
  }
}

void genera_transpuesta(tipo **matrix, tipo **traspuesta, int n){
  int i, j;

  for(i = 0; i < n; i++){
    for(j = 0; j < n; j++){
      traspuesta[j][i] = matrix[i][j];
    }
  }
}

int main(int argc, char** argv){
  tipo **matrix_a = NULL;
  tipo **matrix_b = NULL;
  tipo **matrix_tras = NULL;
  tipo **matrix_c = NULL;
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

  //printf("----------MULTIPLICACION NORMAL----------\n");

  gettimeofday(&ini, NULL);

  multiplica(matrix_a, matrix_b, matrix_c, n);

  gettimeofday(&fin, NULL);

  printf("Normal: : %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
  // printf("A:\n");
  // imprime_matrix(matrix_a, n);
  // printf("\nB:\n");
  // imprime_matrix(matrix_b, n);
  // printf("\nC:\n");
  //imprime_matrix(matrix_c, n);

  //TRASPUESTA

  printf("\n\n");

  matrix_tras = generateEmptyMatrix(n);

  //printf("----------MULTIPLICACION TRAS----------\n");

  gettimeofday(&ini, NULL);

  genera_transpuesta(matrix_b, matrix_tras, n);

  multiplica_tras(matrix_a, matrix_tras, matrix_c, n);

  gettimeofday(&fin, NULL);

  printf("Traspuesta: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);

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
