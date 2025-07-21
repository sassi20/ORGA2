/* ** por compatibilidad se omiten tildes **
================================================================================
 TRABAJO PRACTICO 3 - System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones del manejador de memoria
*/

#include "mmu.h"
#include "i386.h"

#include "kassert.h"

static pd_entry_t* kpd = (pd_entry_t*)KERNEL_PAGE_DIR;
static pt_entry_t* kpt = (pt_entry_t*)KERNEL_PAGE_TABLE_0;

static const uint32_t identity_mapping_end = 0x003FFFFF;
static const uint32_t user_memory_pool_end = 0x02FFFFFF;

static paddr_t next_free_kernel_page = 0x100000;
static paddr_t next_free_user_page = 0x400000;

/**
 * kmemset asigna el valor c a un rango de memoria interpretado
 * como un rango de bytes de largo n que comienza en s
 * @param s es el puntero al comienzo del rango de memoria
 * @param c es el valor a asignar en cada byte de s[0..n-1]
 * @param n es el tamaño en bytes a asignar
 * @return devuelve el puntero al rango modificado (alias de s)
*/
static inline void* kmemset(void* s, int c, size_t n) {
  uint8_t* dst = (uint8_t*)s;
  for (size_t i = 0; i < n; i++) {
    dst[i] = c;
  }
  return dst;
}

/**
 * zero_page limpia el contenido de una página que comienza en addr
 * @param addr es la dirección del comienzo de la página a limpiar
*/
static inline void zero_page(paddr_t addr) {
  kmemset((void*)addr, 0x00, PAGE_SIZE);
}


void mmu_init(void) {}


/**
 * mmu_next_free_kernel_page devuelve la dirección física de la próxima página de kernel disponible. 
 * Las páginas se obtienen en forma incremental, siendo la primera: next_free_kernel_page
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de kernel
 */
paddr_t mmu_next_free_kernel_page(void) {
  paddr_t next_free_page = next_free_kernel_page; //guardo lo q voy a devolver
  if (next_free_kernel_page+ 0x1000 <= identity_mapping_end)//avanzo solo si no se pasa del identity mapping (area libre del kernel)
  {
    next_free_kernel_page = next_free_kernel_page + 0x1000; //avanzo 4KB(prox pagina)
  }
  return next_free_page;
}

/**
 * mmu_next_free_user_page devuelve la dirección de la próxima página de usuarix disponible
 * @return devuelve la dirección de memoria de comienzo de la próxima página libre de usuarix
 */
paddr_t mmu_next_free_user_page(void) {
  paddr_t next_free_page = next_free_user_page; //guardo lo q voy a devolver
  if (next_free_user_page + PAGE_SIZE <= user_memory_pool_end)//avanzo solo si no se pasa del user memory pool
  {
    next_free_user_page = next_free_user_page + PAGE_SIZE; //avanzo 4KB(prox pagina)
  }
  return next_free_page;
}

/**
 * mmu_init_kernel_dir inicializa las estructuras de paginación vinculadas al kernel y
 * realiza el identity mapping
 * @return devuelve la dirección de memoria de la página donde se encuentra el directorio
 * de páginas usado por el kernel
 */
paddr_t mmu_init_kernel_dir(void) {
  // voy a tener que mappear hasta 0x3fffff,
  // limpio pagina y tabla para que o tengan valores viejos que me exploten
  zero_page(KERNEL_PAGE_DIR);
  zero_page(KERNEL_PAGE_TABLE_0); 

  // cargo primera entrada con presente, lectura/escritura, modo kernel y que apunte a la tabla
  kpd[0].attrs = (MMU_P | MMU_W);
  kpd[0].pt = (uint32_t)KERNEL_PAGE_TABLE_0 >> 12;

  //relleno tabla con identity mapping
  // es page size/4  por lo que tengo que mapear 1024 entradas
  // cada pagina va a estar disponible en mem y writeable pero no user xq es para el kernel 
  // pag va a ser el numero de la pag fisica  por eso al poner page = pag la entrada apunta a la dir fisica
  for (int pag = 0; pag < PAGE_SIZE/4 ; pag ++){
    kpt[pag].attrs = (MMU_P | MMU_W);
    kpt[pag].page = (uint32_t)pag;
  }
  return KERNEL_PAGE_DIR;
}

/**
 * mmu_map_page agrega las entradas necesarias a las estructuras de paginación de modo de que
 * la dirección virtual virt se traduzca en la dirección física phy con los atributos definidos en attrs
 * @param cr3 el contenido que se ha de cargar en un registro CR3 al realizar la traducción
 * @param virt la dirección virtual que se ha de traducir en phy
 * @param phy la dirección física que debe ser accedida (dirección de destino)
 * @param attrs los atributos a asignar en la entrada de la tabla de páginas
 */
void mmu_map_page(uint32_t cr3, vaddr_t virt, paddr_t phy, uint32_t attrs) {

  /* busco el directorio */
  pd_entry_t* directorio = (pd_entry_t*) CR3_TO_PAGE_DIR(cr3);

  if(((directorio[VIRT_PAGE_DIR(virt)].attrs) & 0x1) != 0x1){
    /* si no esta presente la creo*/
    pd_entry_t tabla;
    tabla.pt = mmu_next_free_kernel_page() >> 12;
    tabla.attrs = attrs | MMU_P;
    directorio[VIRT_PAGE_DIR(virt)] = tabla;
  } else {
    directorio[VIRT_PAGE_DIR(virt)].attrs |= attrs ;
  }



  pt_entry_t entrada_tabla;
  entrada_tabla.page = phy >> 12;
  entrada_tabla.attrs = attrs | MMU_P;

  
  pt_entry_t* pt = (pt_entry_t*)(directorio[VIRT_PAGE_DIR(virt)].pt << 12);
  pt[VIRT_PAGE_TABLE(virt)] = entrada_tabla;



  tlbflush();
}

/**
 * mmu_unmap_page elimina la entrada vinculada a la dirección virt en la tabla de páginas correspondiente
 * @param virt la dirección virtual que se ha de desvincular
 * @return la dirección física de la página desvinculada
 */
paddr_t mmu_unmap_page(uint32_t cr3, vaddr_t virt) {

  /* busco el directorio */
  pd_entry_t* directorio = (pd_entry_t *) CR3_TO_PAGE_DIR(cr3);

  /* busco la tabla*/
  pt_entry_t* tabla = (pt_entry_t* ) (directorio[VIRT_PAGE_DIR(virt)].pt << 12);

  /* limpio el bit de presente*/
  tabla[VIRT_PAGE_TABLE(virt)].attrs = tabla[VIRT_PAGE_TABLE(virt)].attrs & 0xFFFFFFFE;

  return tabla[VIRT_PAGE_TABLE(virt)].page;

}

#define DST_VIRT_PAGE 0xA00000
#define SRC_VIRT_PAGE 0xB00000

/**
 * copy_page copia el contenido de la página física localizada en la dirección src_addr a la página física ubicada en dst_addr
 * @param dst_addr la dirección a cuya página queremos copiar el contenido
 * @param src_addr la dirección de la página cuyo contenido queremos copiar
 *
 * Esta función mapea ambas páginas a las direcciones SRC_VIRT_PAGE y DST_VIRT_PAGE, respectivamente, realiza
 * la copia y luego desmapea las páginas. Usar la función rcr3 definida en i386.h para obtener el cr3 actual
 */
void copy_page(paddr_t dst_addr, paddr_t src_addr) {
  uint32_t cr3 = rcr3();

  /* map */
  mmu_map_page(cr3, SRC_VIRT_PAGE, src_addr, 0x00000001);
  mmu_map_page(cr3, DST_VIRT_PAGE, dst_addr, 0x00000001);

  /*copia, habria que copiar la pagina entera pero no tenemos un tipo page, alguna forma de copiar 4kb?*/
  uint8_t* dst_pointer = (uint8_t *) DST_VIRT_PAGE;
  uint8_t* src_pointer = (uint8_t *) SRC_VIRT_PAGE;

  for(int i = 0; i < PAGE_SIZE ; i++){
    dst_pointer[i] = src_pointer[i];
  }

  /* unmap */
  mmu_unmap_page(cr3, DST_VIRT_PAGE);
  mmu_unmap_page(cr3, SRC_VIRT_PAGE);
}

 /**
 * mmu_init_task_dir inicializa las estructuras de paginación vinculadas a una tarea cuyo código se encuentra en la dirección phy_start
 * @param phy_start es la dirección donde comienzan las dos páginas de código de la tarea asociada a esta llamada
 * @return el contenido que se ha de cargar en un registro CR3 para la tarea asociada a esta llamada
 */
paddr_t mmu_init_task_dir(paddr_t phy_start) {

  pd_entry_t*  page_directory = (pd_entry_t*) mmu_next_free_kernel_page();
  pt_entry_t*  page_table = (pt_entry_t* ) mmu_next_free_kernel_page();
  
  zero_page(page_directory);
  zero_page(page_table);
  
  // cargo primera entrada con presente, lectura/escritura, modo kernel y que apunte a la tabla
  page_directory[0].attrs = (MMU_P | MMU_W);
  page_directory[0].pt = (uint32_t) page_table >> 12;


  // cargo primera entrada con presente, lectura/escritura, modo kernel y que apunte a la tabla
  kpd[0].attrs = (MMU_P | MMU_W);
  kpd[0].pt = (uint32_t)KERNEL_PAGE_TABLE_0 >> 12;

  //relleno tabla con identity mapping
  // es page size/4  por lo que tengo que mapear 1024 entradas
  // cada pagina va a estar disponible en mem y writeable pero no user xq es para el kernel 
  // pag va a ser el numero de la pag fisica  por eso al poner page = pag la entrada apunta a la dir fisica
  for (int pag = 0; pag < identity_mapping_end; pag += PAGE_SIZE){
    mmu_map_page((uint32_t)page_directory, pag, pag, MMU_W);  
  }

  mmu_map_page((uint32_t)page_directory, TASK_CODE_VIRTUAL, phy_start, MMU_U);
  mmu_map_page((uint32_t)page_directory, TASK_CODE_VIRTUAL + PAGE_SIZE, phy_start + PAGE_SIZE, MMU_U);   //inicializamos las 2 paginas iniciales de la tarea
  
  mmu_map_page((uint32_t)page_directory, TASK_STACK_BASE - PAGE_SIZE, mmu_next_free_user_page(), MMU_U | MMU_W); //armamos el stack

  mmu_map_page((uint32_t)page_directory, TASK_SHARED_PAGE, SHARED, MMU_U);

  return page_directory;
}

// COMPLETAR: devuelve true si se atendió el page fault y puede continuar la ejecución 
// y false si no se pudo atender
bool page_fault_handler(vaddr_t virt) {
  print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
  pd_entry_t *pd = (pd_entry_t*)(CR3_TO_PAGE_DIR(rcr3()));
  pd_entry_t *pde = &(pd[VIRT_PAGE_DIR(virt)]);
  bool ans = false;
  if (ON_DEMAND_MEM_START_VIRTUAL <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL && !(pde->attrs & MMU_P))
  {
    // Mapeamos la página on demand en sí
    mmu_map_page(rcr3(), virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_U | MMU_W);
    
    ans = true;
  }

  return ans;
}
