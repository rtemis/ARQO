LIBS =
LIB_DIR =
FLAGS = -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: fast slow normal traspuesta

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

normal: normal.c multiplica_matriz.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

traspuesta: traspuesta.c multiplica_matriz.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ fast slow normal traspuesta
