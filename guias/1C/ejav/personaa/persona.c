#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* 
gcc -c memoria.c -o memoria.o
gcc memoria.o -o memoria
./memoria 
make
*/


typedef struct {
    char* nombre;
    int edad;
} persona_t;

persona_t* crearPersona(const char* nombre, int edad) {
    persona_t* nueva = malloc(sizeof(persona_t));
    nueva->nombre = malloc(strlen(nombre) + 1);
    // strlen mide el largo de nom
    strcpy(nueva->nombre, nombre);
    // copia lo primero en segundo
    // strcpy((*nueva).nombre, nombre);
    nueva->edad = edad;
    //(*p).edad = 30;  // lo mismo que p->edad
    return nueva;
}

void eliminarPersona(persona_t* persona) {
    if (persona != NULL) {
        free(persona->nombre); 
        free(persona);
    }
}

int main() {
    persona_t* z = crearPersona("Zuni", 24);
    persona_t* m = crearPersona("Maria", 23);

    printf("Nombre: %s\n", z->nombre);
    printf("Edad: %d\n", z->edad);
    printf("Nombre: %s\n", m->nombre);
    printf("Edad: %d\n", m->edad);

    eliminarPersona(z);
    eliminarPersona(m);

    return 0;
}
