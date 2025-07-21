#include <stdio.h>
#include <string.h>

/* 
gcc -c mounstr.c -o mounstr.o
gcc mounstr.o -o mounstr
./mounstr 
make
*/


typedef struct {
    char nombre[50];
    int vida;
    double ataque;
    double defensa;
} monstruo_t;


monstruo_t evolution(monstruo_t m) {
    m.ataque += 10;
    m.defensa += 10;
    return m;
}


int main() {
    monstruo_t mounstruos [5] = {
        {"dragon",1000,500,50},
        {"gryphon",100,300,30},
        {"venin",100,450,50},
        {"darkwilder",100,10,50},
    
    };

    printf("Lista:\n");
    for (int i = 0; i < 3; i++) {
        printf("Nombre: %s, Vida: %d\n", mounstruos[i].nombre, mounstruos[i].vida);
    
    }
    printf("\nEvolución de un monstruo:\n");
    monstruo_t original = mounstruos[0];  // Elegimos el primero (Dragón)
    printf("Antes de la evolución - Nombre: %s, Vida: %d, Ataque: %.2f, Defensa: %.2f\n",
           original.nombre, original.vida, original.ataque, original.defensa);

    monstruo_t evolucionado = evolution(original);
    printf("Después de la evolución - Nombre: %s, Vida: %d, Ataque: %.2f, Defensa: %.2f\n",
           evolucionado.nombre, evolucionado.vida, evolucionado.ataque, evolucionado.defensa);

    return 0;
}
