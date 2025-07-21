#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = false;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
bool EJERCICIO_1B_HECHO = false;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador) {
	// Paso 0: Si el tamaño es 0 o 1, ya está ordenado
    if (tamanio <= 1) return true;

    // Paso 1: Iteramos desde i = 0 hasta i = tamanio - 2
    for (uint16_t i = 0; i < tamanio - 1; i++) {
        // Paso 2: Obtener los valores de índice para esta posición y la siguiente
        uint16_t idx1 = indice[i];
        uint16_t idx2 = indice[i + 1];

        // Paso 3: Obtener los ítems del inventario a esas posiciones
        item_t* item1 = inventario[idx1];
        item_t* item2 = inventario[idx2];

        // Paso 4: Llamar a la función de comparación
        bool esta_ordenado = comparador(item1, item2);

        // Paso 5: Si el comparador devuelve false, no está ordenado
        if (!esta_ordenado) return false;
    }

    // Paso 6: Si terminamos el bucle, entonces sí está ordenado
    return true;
}
