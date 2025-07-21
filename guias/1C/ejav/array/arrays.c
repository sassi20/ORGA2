#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 
gcc -c arrays.c -o arrays.o
gcc arrays.o -o arrays
./arrays 
make

valgrind --leak-check=full ./arrays

*/

int main() {
        int matrix[3][4] = {
             {1, 2, 3, 4},
             {5, 6, 7, 8},
             {9, 10, 11, 12}
        };
        int *p = &matrix[0][0]; // ¿qu ́e es reshape?
        int (*reshape)[2] = (int (*)[2]) p;
        printf("%d\n", p[3]); 
        printf("%d\n", reshape[1][1]);
        return 0;
}

