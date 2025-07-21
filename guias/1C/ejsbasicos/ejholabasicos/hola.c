#include <stdio.h>
#include <stdint.h>

/* 
gcc -c hola.c -o hola.o
gcc hola.o -o hola
./hola 
make
*/

unsigned long long factorialIterativo(int n) {
    unsigned long long rta = 1;
    for (int i = 2; i <= n; i++) {
        rta *= i;
    }
    return rta;
}

int main() {
        printf("Hola Tontita!\n");
        /* 
        char c = 127;
        short s = - 3712;
        int i = 123456;
        long l = 1234567890;
        unsigned int m = 71U;
        signed long int sli = 9223372036854775807L;
        unsigned long long int n = 18446744073709551615ULL;

        printf("char(%lu): %d \n",  sizeof(c),c);
        printf("short(%lu): %d \n",  sizeof(s),s);

        printf("int(%lu): %d \n",  sizeof(i),i);
        printf("long(%lu): %ld \n",  sizeof(l),1L);

        printf("int8_t: %lu \n",  sizeof(int8_t));
        printf("int8_t: %lu bytes\n", sizeof(int8_t));
        printf("uint8_t: %lu bytes\n", sizeof(int8_t));
    
        printf("int16_t: %lu bytes\n", sizeof(int16_t));
        printf("uint16_t: %lu bytes\n", sizeof(int16_t));
    
        printf("int32_t: %lu bytes\n", sizeof(int32_t));
        printf("uint32_t: %lu bytes\n", sizeof(int32_t));
    
        printf("int64_t: %lu bytes\n", sizeof(int64_t));
        printf("uint64_t: %lu bytes\n", sizeof(int64_t));

        printf("unsigned int: %u\nsigned long int: %ld\nunsigned long long int: %llu\n", m, sli, n);

        int mensaje_secreto[] = {116, 104, 101, 32, 103, 105, 102, 116, 32, 111,
        102, 32, 119, 111, 114, 100, 115, 32, 105, 115, 32, 116, 104, 101, 32,
        103, 105, 102, 116, 32, 111, 102, 32, 100, 101, 99, 101, 112, 116, 105,
        111, 110, 32, 97, 110, 100, 32, 105, 108, 108, 117, 115, 105, 111, 110};
        size_t length = sizeof(mensaje_secreto) / sizeof(int);
        char decoded[length];
        for (int i = 0; i < length; i++) {
        decoded[i] = (char) (mensaje_secreto[i]); // casting de int a char
        }
        for (int i = 0; i < length; i++) {
        printf("%c", decoded[i]);
        }


         float f = 0.1f;
        double d = 0.1;

        printf("Valor como float: %f\n", f);
        printf("Valor como double: %f\n", d);

        
        int f_to_int = (int)f;
        printf("Cast de float a int: %d\n", f_to_int);

        
        int d_to_int = (int)d;
        printf("Cast de double a int: %d\n", d_to_int);
       
        
         int a = 5, b = 3, c = 2, d = 1;

        printf("a + b * c / d = %d\n", a + b * c / d); // 5 + (3 * 2) / 1 = 5 + 6 / 1 = 11
        printf("a %% b = %d\n", a % b); // 5 % 3 = 2

        printf("a == b = %d\n", a == b); // 5 == 3 es falso imprime 0
        printf("a != b = %d\n", a != b); // 5 != 3 es verdadero imprime 1

        printf("a & b = %X\n", a & b); // 5 (bin: 0101) & 3 (bin: 0011) = 0001 (decimal 1, hex 1)
        printf("a | b = %X\n", a | b); // 5 (bin: 0101) | 3 (bin: 0011) = 0111 (decimal 7, hex 7)
        printf("~a = %X\n", ~a); // ~5 depende del tamaño del int, pero en 32 bits: ~00000005 = 11111110 (hex FFFFFFFA en complemento a dos)

        printf("a && b = %d\n", a && b); // 5 && 3 es verdadero imprime 1
        printf("a || b = %d\n", a || b); // 5 || 3 es verdadero  imprime 1

        printf("a << 1 = %d\n", a << 1); // 5 << 1 = 10 (5 * 2)
        printf("a >> 1 = %d\n", a >> 1); // 5 >> 1 = 2 (5 / 2)


        printf("a += b = %d\n", a += b); // a = 5 + 3 = 8
        printf("a -= b = %d\n", a -= b); // a = 8 - 3 = 5
        printf("a *= b = %d\n", a *= b); // a = 5 * 3 = 15
        printf("a /= b = %d\n", a /= b); // a = 15 / 3 = 5
        printf("a %%= b = %d\n", a %= b); // a = 5 % 3 = 2

        

        unsigned long palabra1 = 0x80000007;
        unsigned long palabra2 = 0x00000007;

        unsigned long bits_altos_p1 = (palabra1 >> 29) & 0x7;
        unsigned long bits_bajos_p2 = palabra2 & 0x7;

        if (bits_altos_p1 == bits_bajos_p2) {
                printf("iguales.\n");
        } else {
                printf("distintos\n");
        }

        printf("Bits altos de palabra1: %lX\n", bits_altos_p1);
        printf("Bits bajos de palabra2: %lX\n", bits_bajos_p2);
       

        
        uint32_t a[N];
        a[0] = 0;
        a[1] = 20;
        a[2] = 14;
        a[3] = 40;
       

        #define N 100
        uint32_t a[N];
        for (int i = 0; i < N; i++){
                a[i] = i; 
        }
        uint32_t b[] = {0, 20, 14, 40};


        // Imprimir cada elemento del array
        for (int i = 0; i < N; i++) {
        printf("b[%d] = %u\n", i, b[i]);
        }


        #define N 4
        int a[N] = {1, 2, 3, 4};
        int rta[N]; 

        printf(" original: ");
        for (int i = 0; i < N; i++) {
                printf("%d ", a[i]);
         }
         printf("\n");


        for (int i = 0; i < N - 1; i++) {
                rta[i] = a[i + 1];
         }
        rta[N - 1] = a[0]; 

        printf("Después de rotar 1 posición a la izquierda: ");
         for (int i = 0; i < N; i++) {
                printf("%d ", rta[i]);
        }
        printf("\n");
       

       int numero;
    
        printf("numero please: ");
        scanf("%d", &numero);
    
        if (numero < 0) {
                printf("positivo hermana\n");
        } else {
                unsigned long long resultado = factorialIterativo(numero);
                printf("El factorial de %d es %llu\n", numero, resultado);
        }
        
        int a = 0;
        for (int i = 10; i >= 0; i--){
                a++;
        }
        a-=i;
        */
       int n = 0 ;
       int i = 4 ;
       while (i){
        i>>=1 ;
        n += 1;
       }
       printf("%d", n);
       return n;
}
