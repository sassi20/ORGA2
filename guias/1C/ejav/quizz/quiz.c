#include <stdio.h>
#include <stdint.h>
#include <stdio.h>

/* int main() {
    char str1[] = "Hola";
    char str2[] = "Mundo";

    char *p1 = str1;
    char *p2 = str2;

    char **pp = &p1;

    pp = &p2;
    **pp = 'X';

    printf("%s %s\n", p1, p2);

    return 0;
} */

int main() {
    int arr[2][3] = {
        {1, 2, 3},
        {4, 5, 6}
    };

    printf("El valor es: %d\n", *(*(arr + 1) + 1));

    return 0;
}

