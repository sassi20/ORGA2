#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>


#include "../test-utils.h"
#include "ABI.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */
	assert(alternate_sum_4_using_c(8, 2, 5, 1) == 10);
	assert(alternate_sum_4_using_c_alternative(8, 2, 5, 1) == 10);
	
	assert(alternate_sum_8(8, 2, 5, 1 , 1, 1, 1, 1) == 10);
	assert(alternate_sum_8(0,0,0,0,0,0,0,0) == 0);  // -5-3-2-7-4-1-8-2
	assert(alternate_sum_8(5, 5, 5, 5, 5, 5, 5, 5) == 0);

	//uint32_t result1;
	//product_2_f(&result1, 5, 2.5f);
	//assert(result1 == 12);  // 5 * 2.5 = 12.5, truncado a 12

	uint32_t result2;
	product_2_f(&result2, 10, -3.7f);
	assert(result2 == (uint32_t)-37);  // 10 * -3.7 = -37.0, truncado a -37

	uint32_t result3;
	product_2_f(&result3, 0, 5.5f);
	assert(result3 == 0);  // 0 * 5.5 = 0
	
	return 0;
}
