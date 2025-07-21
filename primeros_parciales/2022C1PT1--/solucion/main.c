#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include "str.h"
#include "ejs.h"

int main(void) {
    // Test 1: Crear un array de strings con capacidad 5
    str_array_t* myArray = strArrayNew(5);

    assert(myArray != NULL);
    assert(myArray->capacity == 5);
    assert(myArray->size == 0);
    assert(myArray->data != NULL);

    for (size_t i = 0; i < myArray->capacity; ++i) {
        assert(myArray->data[i] == 0); // Confirmar que calloc puso 0 (NULL)
    }

    printf("Todos los tests pasaron strArrayNew ✅\n");

    // Test 2: strArrayGetSize antes de insertar nada
    assert(strArrayGetSize(myArray) == 0);
    printf("Todos los tests pasaron strArrayGetSize ✅\n");

    // Insertamos 4 strings reales
    strArrayAddLast(myArray, "Uno");
    strArrayAddLast(myArray, "Dos");
    strArrayAddLast(myArray, "Tres");
    strArrayAddLast(myArray, "Test String");

    assert(strArrayGetSize(myArray) == 4);

    // Verificamos que el string se haya agregado correctamente
    if (myArray->data[3] != 0) {
        assert(strcmp(myArray->data[3], "Test String") == 0);
    } else {
        assert(0);
    }

    printf("Todos los tests pasaron strArrayAddLast ✅\n");

    // ---------------------------------------
    // Test de strArraySwap
    // ---------------------------------------

    // Swap entre "Uno" (0) y "Tres" (2)
    strArraySwap(myArray, 0, 2);
    assert(strcmp(myArray->data[0], "Tres") == 0);
    assert(strcmp(myArray->data[2], "Uno") == 0);

    // Swap con índice fuera de rango (no debe hacer nada)
    strArraySwap(myArray, 0, 10);
    assert(strcmp(myArray->data[0], "Tres") == 0);  // Debe seguir igual
    assert(strcmp(myArray->data[2], "Uno") == 0);   // Debe seguir igual

    // Swap con ambos fuera de rango (tampoco debe hacer nada)
    strArraySwap(myArray, 10, 20);
    assert(strcmp(myArray->data[0], "Tres") == 0);
    assert(strcmp(myArray->data[2], "Uno") == 0);

    // Swap del mismo índice (no debería alterar nada)
    strArraySwap(myArray, 1, 1);
    assert(strcmp(myArray->data[1], "Dos") == 0);

    // Swap entre índices válidos
    strArraySwap(myArray, 1, 3); // "Dos" y "Test String"
    assert(strcmp(myArray->data[1], "Test String") == 0);
    assert(strcmp(myArray->data[3], "Dos") == 0);

    printf("Todos los tests pasaron strArraySwap ✅\n");

    // ---------------------------------------
    // Test de strArrayDelete
    // ---------------------------------------

    strArrayDelete(myArray);

    // No deberíamos acceder más a myArray o sus campos
    // porque fue liberado

    printf("Todos los tests pasaron strArrayDelete ✅\n");

    return 0;
}
