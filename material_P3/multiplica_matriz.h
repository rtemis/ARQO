//P3 arq 2019-2020
#ifndef _MULTIPLICA_MATRIZ_H_
#define _MULTIPLICA_MATRIZ_H_

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "arqo3.h"


void multiplica(tipo **matrix_a, tipo **matrix_b, tipo **matrix_c, int n);
void multiplica_tras(tipo **matrix_a, tipo **matrix_b, tipo **matrix_c, int n);
void genera_transpuesta(tipo **matrix, tipo **traspuesta, int n);
void imprime_matrix(tipo **matriz, int n);

#endif /*  2019-2020 */
