#include <stdio.h>
#include <stdint.h>

extern int64_t en_blacklist_asm(char* comercio, char** blacklist, uint8_t tam);

int main() {
    char* comercio = "zara";

    char* lista_negra[] = {
        "adidas",
        "zara",
        "nike"
    };

    uint8_t tam = 3;

    int64_t res = en_blacklist_asm(comercio, lista_negra, tam);

    if (res == 1) {
        printf("'%s' está en la blacklist\n", comercio);
    } else {
        printf("'%s' NO está en la blacklist\n", comercio);
    }

    return 0;
}
