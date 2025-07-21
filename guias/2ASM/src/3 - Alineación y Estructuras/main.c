#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Estructuras.h"

int main() {
	// ---------- Prueba 1: lista vacía ----------
    lista_t lista_vacia = { .head = NULL };
    assert(cantidad_total_de_elementos(&lista_vacia) == 0);

    packed_lista_t packed_lista_vacia = { .head = NULL };
    assert(cantidad_total_de_elementos_packed(&packed_lista_vacia) == 0);

    // ---------- Prueba 2: lista con un solo nodo ----------
    nodo_t nodo1 = { .next = NULL, .categoria = 0xAB, .arreglo = NULL, .longitud = 7 };
    lista_t lista_1 = { .head = &nodo1 };
    assert(cantidad_total_de_elementos(&lista_1) == 7);

    packed_nodo_t packed_nodo1 = { .next = NULL, .categoria = 0xCD, .arreglo = NULL, .longitud = 4 };
    packed_lista_t packed_lista_1 = { .head = &packed_nodo1 };
    assert(cantidad_total_de_elementos_packed(&packed_lista_1) == 4);

    // ---------- Prueba 3: lista con varios nodos ----------
    nodo_t nodo2 = { .next = &nodo1, .categoria = 0x01, .arreglo = NULL, .longitud = 3 };
    lista_t lista_2 = { .head = &nodo2 };
    assert(cantidad_total_de_elementos(&lista_2) == 3 + 7);

    packed_nodo_t packed_nodo2 = { .next = &packed_nodo1, .categoria = 0x02, .arreglo = NULL, .longitud = 6 };
    packed_lista_t packed_lista_2 = { .head = &packed_nodo2 };
    assert(cantidad_total_de_elementos_packed(&packed_lista_2) == 6 + 4);

    printf("✅ Todas las pruebas pasaron correctamente.\n");
	return 0;
}
