#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Memoria.h"

int main() {
	// Pruebas con strings iguales
    assert(strCmp("hola", "hola") == 0); // Strings iguales
    assert(strCmp("a", "a") == 0);       // Strings iguales (un solo carácter)
    assert(strCmp("", "") == 0);         // Cadenas vacías

    // Pruebas con strings donde uno es mayor que el otro
    assert(strCmp("hola", "holb") == 1); // "a" < "b"
    assert(strCmp("hola", "holz") == 1); // "a" < "z"
    assert(strCmp("holb", "hola") == -1);// "b" < "a"
    assert(strCmp("holaa", "holab") == 1); // "a" < "b" al final

    printf("✅ Todas las pruebas strCmp pasaron correctamente.\n");

    char str1[] = "Hola mundo";
    char str2[] = "";
    char str3[] = "A";
    char str4[] = "1234567890";
    char str5[] = "Con\0tenidos";

    // Tests
    assert(strLen(str1) == 10); // "Hola mundo" → 10 caracteres
    assert(strLen(str2) == 0);  // "" → 0 caracteres
    assert(strLen(str3) == 1);  // "A" → 1 carácter
    assert(strLen(str4) == 10); // "1234567890" → 10 caracteres
    assert(strLen(str5) == 3);  // "Con" (corta en primer '\0')

    printf("✅ Todos los tests strlen pasaron correctamente.\n");


    FILE *tmp = tmpfile();
    if (!tmp) {
        perror("tmpfile");
        return 1;
    }

    // Caso 1: String normal
    char texto1[] = "Hola mundo!";
    strPrint(texto1, tmp);

    // Caso 2: String vacío
    char texto2[] = "";
    strPrint(texto2, tmp);

    // Caso 3: Otro string
    char texto3[] = "1234";
    strPrint(texto3, tmp);

    // Ahora leemos lo que se escribió en tmp
    fflush(tmp);
    fseek(tmp, 0, SEEK_SET);

    char buffer[256] = {0};
    fread(buffer, sizeof(char), sizeof(buffer) - 1, tmp);
    fclose(tmp);

    // Armamos el string esperado
    const char *esperado = "Hola mundo!NULL1234";

    // Comparamos
    assert(strcmp(buffer, esperado) == 0);

    printf("✅ Todos los tests de strprint pasaron.\n");

    // CASO 1: Liberar un string normal
    char *texto12 = malloc(20);
    assert(texto12 != NULL);
    texto12[0] = 'H';
    texto12[1] = 'i';
    texto12[2] = '\0';
    strDelete(texto12); // debería liberar correctamente

    // CASO 2: Liberar string vacío
    char *texto22 = malloc(1);
    assert(texto22 != NULL);
    texto22[0] = '\0';
    strDelete(texto22);

    // CASO 3: Liberar string más largo
    char *texto32 = malloc(100);
    assert(texto32 != NULL);
    for (int i = 0; i < 99; i++) texto32[i] = 'A';
    texto32[99] = '\0';
    strDelete(texto32);

    // Si llegamos hasta acá, no hubo errores de memoria (a nivel assert).
    printf("✅ Todos los tests de strDelete pasaron.\n");


   char *s1 = strClone("hola");
    assert(strcmp(s1, "hola") == 0);
    free(s1);

    // Test 2: cadena vacía
    char *s2 = strClone("");
    assert(strcmp(s2, "") == 0);
    free(s2);

    // Test 3: cadena con espacios
    char *s3 = strClone("cadena con espacios");
    assert(strcmp(s3, "cadena con espacios") == 0);
    free(s3);

    // Si todos pasaron:
    printf("✅ Todos los tests de strClone pasaron correctamente.\n");
	return 0;
}
