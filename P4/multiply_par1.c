#include <stdio.h>
#include <omp.h>

#include "multiplica_matriz.h"


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
