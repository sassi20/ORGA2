all: hola
   hola: hola.o
           gcc -Wall -Wextra -pedantic hola.o -o hola
   hola.o: hola.c
           gcc -Wall -Wextra -pedantic -c hola.c -o hola.o
clean:
           rm *.o hola
   .PHONY: all clean
