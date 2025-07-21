#include <stdio.h>

// gcc 19.c -o 19.exe

int g = 10;
void functionA() {
    int a = 20;
    static int b = 30;
    printf(" g = %d/n",g);
    printf(" a = %d/n",a);
    printf(" b = %d/n",b);
    // Modificaci ́on de las variables
    g += 5;
    a += 10;
    b += 5;
}

void functionB() {
    int a = 40;
    static int c = 50;
    printf("Dentro de functionB:\n");
    printf("  g = %d\n", g);
    printf("  a = %d\n", a);
    printf("  c = %d\n", c);
    g += 5;
    a += 10;
    c += 5;

}

int main() {
    printf("dentro de main:\n");
    printf("g = %d\n",g);
    functionA();
    functionB();
    functionA();
    functionB();
    printf("\n final en main:\n");
    printf(" g = %d\n",g);
    return 0; 
}
