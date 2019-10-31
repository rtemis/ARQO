# Prog de prueba para Pr�ctica 2. Ej 1

.data
num0: .word 1 # posic 0
num1: .word 2 # posic 4
num2: .word 4 # posic 8
num3: .word 8 # posic 12
num4: .word 16 # posic 16
num5: .word 32 # posic 20
num6: .word 0 # posic 24
num7: .word 0 # posic 28
num8: .word 0 # posic 32
num9: .word 0 # posic 36
num10: .word 0 # posic 40
num11: .word 0 # posic 44
.text
main:
00000000  # carga num0 a num5 en los registros 9 a 14
00000004  lw $t1, 0($zero) # lw $r9, 0($r0)
00000008  lw $t2, 4($zero) # lw $r10, 4($r0)
0000000c  lw $t3, 8($zero) # lw $r11, 8($r0)
00000010  lw $t4, 12($zero) # lw $r12, 12($r0)
00000014  lw $t5, 16($zero) # lw $r13, 16($r0)
00000018  lw $t6, 20($zero) # lw $r14, 20($r0)
0000001c  nop
00000020  nop
00000024  nop
00000028  nop
  # RIESGOS REGISTRO REGISTRO
0000002c  add $t3, $t1, $t2 # en r11 un 3 = 1 + 2
00000030  add $t1, $t3, $t2 # dependencia con la anterior # en r9 un 5 = 2 + 3
00000034  nop
00000038  nop
0000003c  nop
00000040  add $t3, $t1, $t2 # en r11 un 7 = 5 + 2 !!
00000044  nop
00000048  add $t2, $t4, $t3 #dependencia con la 2� anterior # en r10 un 15 = 7 + 8 !!
0000004c  nop
00000050  nop
00000054  nop
00000058  add $t3, $t1, $t2  # en r11 un 20 = 5 + 15
0000005c  nop
00000060  nop
00000064  add $t2, $t3, $t5 #dependencia con la 3� anterior  # en r10 un 36 = 20 + 16
00000068  nop
0000006c  nop
00000070  nop
00000074  add $s0, $t1, $t2  # en r16 un 41 = 5 + 36
00000078  add $s0, $s0, $s0  # Dependencia con la anterior  # en r16 un 82 = 41 + 41.
0000007c  add $s1, $s0, $s0  # dependencia con la anterior  # en r16 un 164 = 82 + 82
00000080  nop
00000084  nop
00000088  nop
0000008c  nop
  # RIESGOS REGISTRO MEMORIA
00000090  add $t3, $t1, $t2 # en r11 un 41 = 5 + 36
00000094  sw $t3, 24($zero) # dependencia con la anterior
00000098  nop
0000009c  nop
000000a0  nop
000000a4  add $t4, $t1, $t2 # en r12 un 41 = 5 + 36
000000a8  nop
000000ac  sw $t4, 28($zero) # dependencia con la 2� anterior
000000b0  nop
000000b4  nop
000000b8  nop
000000c0  add $t5, $t1, $t2 # en r13 un 41 = 5 + 36
000000c4  nop
000000c8  nop
000000c8  sw $t5, 32($zero) # dependencia con la 3� anterior
000000cc  nop
000000d0  nop
000000d4  nop
000000d8  nop
  # RIESGOS MEMORIA REGISTRO
000000dc  lw $t3, 0($zero) # en r11 un 1
000000e0  add $t4, $t2, $t3 # dependencia con la anterior # en r12 37 = 36 + 1
000000e4  nop
000000e8  nop
000000ec  nop
000000f0  lw $t3, 4($zero) # en r11 un 2
000000f4  nop
000000f8  add $t4, $t2, $t3 # dependencia con la 2� anterior # en r12 38 = 36 + 2
000000fc  nop
00000100  nop
00000104  lw $t3, 8($zero) # en r11 un 4
00000108  nop
0000010c  nop
00000110  add $t4, $t2, $t3 # dependencia con la 3� anterior # en r12 40 = 36 + 4
00000114  nop
00000118  nop
0000011c  nop
  # RIESGOS MEMORIA MEMORIA
00000120  sw $t4, 0($zero)
00000124  lw $t2, 0($zero) # en r10 un 40
00000128  nop
0000012c  nop
00000130  nop
00000134  nop
00000138  lw $t2, 4($zero) # en r10 un 2
0000013C  sw $t2, 0($zero) # Guarda el 2 en posicion 0 de memoria
