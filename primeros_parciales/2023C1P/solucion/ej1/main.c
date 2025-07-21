#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>
#include <assert.h>

#include "ej1.h"

// Función principal para probar la implementación
int main() {
/* templo templos[] = {
        { .colum_largo = 11, .nombre = "Partenón",   .colum_corto = 5 },  // 2*5+1 = 11 → CLÁSICO
        { .colum_largo = 9,  .nombre = "Templo A",   .colum_corto = 4 },  // 2*4+1 = 9 → CLÁSICO
        { .colum_largo = 12, .nombre = "Templo B",   .colum_corto = 5 },  // 2*5+1 = 11 ≠ 12 → NO clásico
        { .colum_largo = 7,  .nombre = "Templo C",   .colum_corto = 3 },  // 2*3+1 = 7 → CLÁSICO
        { .colum_largo = 6,  .nombre = "Templo D",   .colum_corto = 3 },  // 2*3+1 = 7 ≠ 6 → NO clásico
    };

    size_t len = sizeof(templos) / sizeof(templo);

    // Test: Imprimir templos y verificación
    for (size_t i = 0; i < len; i++) {
        printf("templo %s -> colum_largo: %u, colum_corto: %u\n", templos[i].nombre, templos[i].colum_largo, templos[i].colum_corto);
        if (templovintage(&templos[i])) {
            printf("Templo %s: CLÁSICO\n", templos[i].nombre);
        } else {
            printf("Templo %s: NO clásico\n", templos[i].nombre);
        }
    }

    // Test: Llamada a cuantosTemplosClasicos
    size_t total_clasicos = cuantosTemplosClasicos(templos, len);
    printf("Total de templos clásicos: %zu\n", total_clasicos);

    // Test: Total de templos clásicos debe ser 3
    assert(total_clasicos == 3);

    printf("Todos los tests pasaron correctamente.\n");
 */
    return 0;
}
