#####################################################################
### Programa de prueba David Gonzalez-Arjona para Práctica 1 ARQO ###
###   __   __  __     _  _  __  __ __                             ###
###  | _\ / _]/  \ __| || |/  \|  V  |                            ###
###  | v | [/\ /\ |__| \/ | /\ | \_/ |                            ###
###  |__/ \__/_||_|   \__/|_||_|_| |_|                            ###
#####################################################################
### Programa en ensamblador para probar el funcionamiento de la práctica 1.
### Incluye todas las instrucciones a verificar. Los saltos de los beq se
### realizan de forma efectiva si las operaciones anteriores han devuelto resultados
### correctos en los registros. Aún así el alumno tiene que verificar en modelsim que
### el resultado correcto se genera en el momento correcto (mips de 5 etapas) así como
### el valor del resto de las señales. Recordad verificar que se ejecuta 1 instrucción
### por ciclo de reloj, ojo al segmentar, no haya una instrucción cada 2 ciclos (o cada 3,4,5,6...).
####################################################################################################

.data
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8
num3: .word 8 # posic 12
num4: .word 16 # posic 16

.text
main:
 lw $1, 0($zero) # En r1 un 1
 add $2, $1, $1 # En r2 un 2
 nop
 nop
 beq $1, $2, check_err # no salta
 add $1, $1, $1 # En r1 un 2
 beq $1, $2, check_ok1 # salta
 lw $3, 0($zero) # En r3 un 1

 check_ok1: lw $3, 4($zero) # En r3 un 2
 beq $1, $3, check_err # no salta
 add $3, $1, $2 # en r3 un 4
 lw $4, 8($zero) # En r4 un 4
 nop
 beq $3, $4, check_ok2 # salta
 lw $1, 16($zero) # En r1 un 16

 check_err: lw $10, 8($zero) # en r10 un 4
 check_ok2: lw $10, 16($zero) # en r10 un 16
