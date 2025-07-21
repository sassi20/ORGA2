#include <stdio.h>
#include <stdint.h>

/* 
gcc -c punteros.c -o punteros.o
gcc punteros.o -o punteros
./punteros
make
*/

/* 
int main() {
    int x = 42;
    int *p = &x;
    printf("Direccion de x: %p Valor: %d\n", (void*) &x, x);
    printf("Direccion de p: %p Valor: %p\n", (void*) &p, (void*) p);
    printf("Valor de lo que apunta p: %d\n", *p);
    return 0;
}

el codigo incializa la variable x en 42 y luego declara un puntero p y le asigna la de memoria
x usando el &; la diferencia entre ambos es que uno es una variable otro un puntero

devuelve 
Direccion de x: 0x16f452e58 Valor: 42
Direccion de p: 0x16f452e50 Valor: 0x16f452e58
Valor de lo que apunta p: 42
 */




/* 
 int main(){
    uint8_t *x = (uint8_t*) 0xF0;
    int8_t *y = (int8_t*) 0xF6;
    printf("Dir de x: %p Valor: %d\n" , (void*) x, *x);
    printf("Dir de y: %p Valor: %d\n" , (void*) y, *y);
 }

 //segmentation fault 
 */




/* 
int main(){
    int8_t memoria[3] = {10, 20, 30};       // Array con 3 valores
    uint8_t *x = (uint8_t*) &memoria[0];    // Puntero a la primera posición
    int8_t *y = &memoria[1];                // Puntero a la segunda posición

    printf("Dir de x: %p Valor: %d\n", (void*) x, *x);
    printf("Dir de y: %p Valor: %d\n", (void*) y, *y);
}

//memoria[3] = {10, 20, 30}: crea un array de 3 elementos.
//x apunta a memoria[0].
//y apunta a memoria[1].
//Luego imprime las direcciones y los valores almacenados. */




/* 
void swap(int *a, int *b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}
int main() {
    int x = 10, y = 20;
    swap(&x, &y);
    printf("x: %d, y: %d\n", x, y);
}

// Si swap fuera void swap(int a, int b) no podemos intercambiar los valores de x y y
// porque en ese caso se estarian pasando copias de los valores no las variables */





/* 
int main(){
    char *str1 = "Hola";
    char str2[] = "Hola";
    printf("%s\n", str1);
    printf("%s\n", str2);
    return 0;
}

//devuelven lo mismo (almacenan el mismo texto) pero no son lo mismo 
// char *str1 es un segmento de lectura (tipo const) que no puede dar error
Hola" es una cadena literal (constante de cadena).
El compilador la guarda en una zona de memoria de solo lectura (normalmente en el segmento .rodata).
str1 es un puntero que apunta a esa cadena literal.
No se puede modificar legalmente el contenido de "Hola" a través de str1.

// char str2[] eta en un stack como array local y se te puede ir de rango */
/* En este caso, "Hola" se copia en un array local en el stack.
str2 es un array, no un puntero.
Podés modificar el contenido del array sin problema. */


void a_mayusculas(char *str) {
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] >= 'a' && str[i] <= 'z') {
            str[i] -= 32;
        }
    }
}

int main() {
    char texto[] = "a ver nenita";
    a_mayusculas(texto);
    printf("rta: %s\n", texto);
    return 0;
}