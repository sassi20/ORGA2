#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3


void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
	// Completar:
	// - Pueden definir funciones auxiliares para imprimir en pantalla
	// - Pueden usar `task_print`, `task_print_dec`, etc. 
			
		for(int task_id = 0; task_id < CANT_PONGS; task_id++){
			uint32_t* base = (uint32_t*) SHARED_SCORE_BASE_VADDR + ((uint32_t) task_id  * 8);
			task_print_dec(pantalla, base[0], 3, 0, task_id, C_FG_CYAN);
			task_print_dec(pantalla, base[1], 3, 10, task_id, C_FG_CYAN);
		}
		syscall_draw(pantalla);
	}
}
