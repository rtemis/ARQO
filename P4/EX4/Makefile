LIBS =
LIB_DIR =
FLAGS = -g -lgomp -Wall -D_GNU_SOURCE -fopenmp

.PHONY: clean all

all:  pi_par3 clear

pi_par3: pi_par3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)


clean:
	rm -f *.o *~ pi_par3 

clear:
	rm -f *.o *~
