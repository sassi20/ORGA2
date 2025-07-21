--BASTANTES CORRECCIONES, CORREGIDO EN SEGUNDOS_PARCIALES
PRIMER EJERCICIO

Lo primero que voy a necesitar para crear mis nuevas syscalls va a ser definirle a cada una su idtentry 

IDTENTRY3(99);     -> va a ser la correspondiente a crear_pareja

#define IDT_ENTRY3(99)
idt[99] = (idt_entry_t) {
.offset_31_16 = HIGH_16_BITS(&_isr 99),
.offset_15_0 = LOW_16_BITS(&_isr 99),
.segsel = GDT_CODE_0_SEL,
.type = INTERRUPT_GATE_TYPE,
.dpl = 3,
.present = 1
}

IDTENTRY3(100);   -> va a ser la correspondiente a juntarse_con

#define IDT_ENTRY3(100)
idt[100] = (idt_entry_t) {
.offset_31_16 = HIGH_16_BITS(&_isr 100),
.offset_15_0 = LOW_16_BITS(&_isr 100),
.segsel = GDT_CODE_0_SEL,
.type = INTERRUPT_GATE_TYPE,
.dpl = 3,
.present = 1
}

IDTENTRY3(101);  -> correspondiente a abandonar_pareja

#define IDT_ENTRY3(101)
idt[101] = (idt_entry_t) {
.offset_31_16 = HIGH_16_BITS(&_isr 101),
.offset_15_0 = LOW_16_BITS(&_isr 101),
.segsel = GDT_CODE_0_SEL,
.type = INTERRUPT_GATE_TYPE,
.dpl = 3,
.present = 1
}

Una vez que estas ya estan definidas, en isr.asm agrego la rutina para mis tres interrupciones 

global _isr99
_isr99:
    pushad
    call crear_pareja
    popad
    iret

global _isr100
_isr99:
    pushad
    push EDI
    call juntarse_con
    pop EDI
    mov [ESP + offset_EAX], EAX
    popad
    iret


global _isr101
_isr101:
    pushad
    call abandonar_pareja
    popad
    iret


Voy a traerme la estructura sched_entry_t del tp pero le voy a hacer unas modificaciones para que se ajuste a mis necesitades para estas syscalls

typedef struct {
    int16_t selector;
    task_state_t state;      -> creo un estado bloqueado o available
    bool en_pareja;          -> 1 si en pareja 0 sino
    bool lider;              -> 1 si lider 0 sino
    bool no_quiere_mas;      -> 1 si quiere irse de tarea
    bool creo;               -> 1 si llamo a crear pareja y no tiene pareja todavia
    vadder_t dirasignada;    -> dejo atributo para que se guarde dir cuando crea pero no tiene pareja todavia 
} sched_entry_t;

Asumo que todas las tareas cuando se inician en mis campos nuevos como en_pareja, lider, no_quiere_mas y creo estan en cero,que dirasignada no tiene nada y estado empieza en available.

Tambien a parte de la estructura modificada voy a crearme una nueva estructura que se va llamar pareja va a ser elemento de un array de parejas. 

typedef struct {
    uint8_t id_lider;
    bool liderout = 0;      -> 1 si lider se quiere ir pero tiene que esperar que el otro se vaya primero 
    uint8_t compa;          -> va a tener el id de la tarea compañera y -1 en caso de haber abandonado
    bool habilitada = 1;    -> en principio van a estar habilitada hasta que ambas persdonas de la pareja se hayan ido de esta 
    vadder_t dir_asig; 
} pareja

Me defino ahora ya con mis estructuras algunas constantes que voy a ir utilizando despues 

DEF MAXMEM 4 MB
MAX_CANT_PAREJAS va a ser el numero maximo de parejas que se pueden generar y va a ser el tamano de mi array pareja
int8_t current_task = 0
array <pareja>  parejas   --> array que va a ser de elementos de tipo pareja y va a tener tamaño MAX_CANT_PAREJAS
uint8_t pareja_i = 0
entregador_memoria = 0xC0C00000


void crear_pareja(){
    if (sched_entry_t[current_task].en_pareja == 1){
        return
    }
    if (sched_entry_t[current_task].en_pareja == 0 && sched_entry_t[current_task].creo == 1){
        sched_entry_t[current_task].estado = bloqueada;
        return
    }
    sched_entry_t[current_task].creo = 1;
    sched_entry_t[current_task].dir_asignada = entregador_memoria;
    entregador_memoria += MAXMEM
    return
}

En void crear_pareja lo que se hace es dado un current_task que me esta pidiendo crear una pareja lo que hago es: primero miro que no este en pareja ya si este es el caso no hago nada y returno, luego me fijo que no este buscando paraja, es decir que ya creo_pareja antes pero todavia no tiene compañer@, de ser asi lo marco como bloqueado hasta que consiga companero y por ultimo si no entra en ninguno de los dos casos anteriores indico que creo la pareja, le doy una direccion que va a tener derecho a acceder por ultimo de todo "avanzo entregador_memoria para que no entregue la misma direccion a mas de una pareja.

int juntarse_con(int id_tarea){
    if (sched_entry_t[current_task].en_pareja == 1){
        return 1;
    }
    if (sched_entry_t[id_tarea].creo == 0){
        return 1;
    }
    parejas[pareja_index].lider = id_tarea;
    parejas[pareja_index].liderout = 0;
    parejas[pareja_index].compa = current_task;
    parejas[pareja_index].dir_asig = sched_entry_t[id_tarea].dir_asignada
    pareja_index =+ 1;
    sched_entry_t[id_tarea].en_pareja = 1;
    sched_entry_t[id_tarea].lider = 1;
    sched_entry_t[id_tarea].estado = available;
    sched_entry_t[id_tarea].creo = 0;
    sched_entry_t[current_task].en_pareja = 1;
    sched_entry_t[current_task].dir_asignada = sched_entry_t[id_tarea].dir_asignada
    return 0;
}

En int juntarse_con(int id_tarea) lo que se hace es dado un nuevo id con el que quiere juntarse nuestra tarea llamadora es: primero chequeo que mi tarea llamadora no sea parte de una pareja ya o que la tarea a la cual se quiere unir (id_tarea) no haya creado una pareja, en ambos casos retorno un 1 y no hago mas nada, de no entrar en estos dos casos formo la pareja que consta de agregar una nueva entrada a parejas en donde voy a poner al id_tarea como lider y a current_task como compi, tambien voy a "actualizar" los atributos tanto de id_tarea (haciendolo lider, cambiando el estado de haber estado bloqueado y sacandole que quero pareja ya qie ya la formo y no sigue buscando) como de current_task (que ahora va a estar en pareja y va a tener una direccion asignada de memoria compartida con su pareja). Por ultimo le doy acceso de lectura a current_task sobre la memoria que va a compartir con su pareja mappeando la dirreccion con permiso solamente de lectura.

void abandonar_pareja(){
    if (sched_entry_t[current_task].en_pareja == 0){
        return
    }
    if (sched_entry_t[current_task].en_pareja == 1 && sched_entry_t[current_task].lider == 0 ){
        sched_entry_t[current_task].en_pareja = 0;
        sched_entry_t[current_task].dir_asignada = 0;
        for (uint8 i = 0, i< MAX_PAREJAS; i ++){
            if (pareja[i].compa == current_task && pareja[i].habilitada == 1 ){
                pareja[i].compa = -1;
            }
        }
        // aca voy a desmapear mi direecion compartida por que en caso de haberla mapeado ya no voy a poder acceder mas porque me estoy yendo de la pareja
        uint32_t cr3 = obtener_cr3(sched_entry_t[current_task].selector)
        mmu_unmap_page(cr3, sched_entry_t[current_task].dir_asignada)
    }
    if (sched_entry_t[current_task].en_pareja == 1 && sched_entry_t[current_task].lider == 1 ){
        //busco companerito con un for despues me doy cuenta que lo prodria haber hecho en auxiliar pero basicamente es mirar en mis parejas que currrent_task sea el lider, que pareja este habilitada y que coincida mi dir_asignada
        uint8 compi;
        uint8 parejanum;
        for (uint8 i = 0, i< MAX_PAREJAS; i ++){
            if (parejas[i].lider == current_task && parejas[i].habilitada && parejas[i].dir_asig == sched_entry_t[current_task].dir_asig){
                compi = pareja[i].compi
                parejanum = i
            }
        }
        //caso en que mi companero ya se fue de la pareja
        if (compi == -1){
            sched_entry_t[id_tarea].en_pareja = 0;
            sched_entry_t[id_tarea].lider = 0;
            sched_entry_t[id_tarea].dir_asignada = 0;
            parejas[parejanum] = 0
            // aca voy a desmapear mi direecion compartida por que en caso de haberla mapeado ya no voy a poder acceder mas porque me estoy yendo de la pareja
            uint32_t cr3 = obtener_cr3(sched_entry_t[current_task].selector)
            mmu_unmap_page(cr3, sched_entry_t[current_task].dir_asignada)
        }
        // caso en el que mi compañero sigue ahi
        sched_entry_t[id_tarea].no_quiere_mas = 1;
        parejas[parejanum].liderout = 1;
        sched_entry_t[id_tarea].estado = bloqueado;
    }
}

En void abandonar_pareja() lo que voy a hacer es: si la tarea no pertenece a ninguna pareja no hago nada, si la tarea pertenece a una pareja pero no es el lider, voy a dejar de tener acceso a la direccion de memoria de pareja compartida y me voy a marcar con un -1 como que me fui, si la tarea pertenece a una pareja y es la lider voy a tener dos posibles casos para ambos de estos voy a necesitar saber en que pareja estoy y quien es mi companero asique antes que nads busco eso, una vez que tengo esta info me fijo: si mi companerito ya abandono la tarea yo voy a perder el derecho de acceso a la memoria, voy a salir de la tarea y voy a marcar la pareja en el array de pareja como inhabilitada. Si mi amiguito sigue estando en la pareja solo voy a marcar que me quiero ir de la pareja y me voy a bloquear.

Funcion Auxiliar:
obtener_cr3 lo pienso como lo hicimos en la clase preparcial
1. Quedarnos con el indice del selector.
2. Obtener la base de la gdt.
3. Sumarle el indice multiplicado por el tamaño de la entrada (indexar en el
índice a un puntero de structs si se hace en C).
4. Sumarle el offset del cr3 y retornar el valor apuntado. (Obtener el elemento
cr3 del struct si se hace en C).

Ahora para que el ejercicio quede completo voy a tener que modificar el page_faul_handler ya que aunque mis interrupciones le dan el derecho de acceso a la direccion entregada para la tarea estas no le dan el acceso real. Es por esto que en el page_fault_handler del tp voy a agregar que se mappen las paginas dadas con sus debidos permisos de ser requerido y contar con los derechos.

bool page_fault_handler(vaddr_t virt) {
    print("Atendiendo page fault...", 0, 0, C_FG_WHITE | C_BG_BLACK);
    pd_entry_t *pd = (pd_entry_t*)(CR3_TO_PAGE_DIR(rcr3()));
    pd_entry_t *pde = &(pd[VIRT_PAGE_DIR(virt)]);
     bool ans = false;
    if (ON_DEMAND_MEM_START_VIRTUAL <= virt && virt <= ON_DEMAND_MEM_END_VIRTUAL && !(pde->attrs & MMU_P)){
    // Mapeamos la página on demand en sí
    mmu_map_page(rcr3(), virt, ON_DEMAND_MEM_START_PHYSICAL, MMU_U | MMU_W);
    ans = true;
    }
    // estoy casi 100% segura que la guarda esta mal pero lo que quiero hacer es mirar si es lider entonces mapear la pagina como lectura y escritura
    if(sched_entry_t[current_task].lider == 1 && sched_entry_t[current_task].en_pareja == 1){
        paddr_t* nueva_pagina = mmu_next_free_user_page(); 
        zero_page(nueva_pagina)
        mmu_map_page(rcr3(), virt, nueva_pagina, MMU_U | MMU_W);
        ans = true;
    }
    // y este es el caso en que no sea el lider pero este en la pareja entonces mapeo tambien pero solo con permiso de lectura
    if(sched_entry_t[current_task].lider == 1 && sched_entry_t[current_task].en_pareja == 1 ){
        paddr_t* nueva_pagina = mmu_next_free_user_page(); 
        zero_page(nueva_pagina)
        mmu_map_page(rcr3(), virt, nueva_pagina, MMU_U | MMU_R);
        ans = true;
    }
  return ans;
}

No estoy segura que mi page_fault_handler este corrctamente implementado pero mi idea es que si se pide el acceso a la direccion asignada y la tarea tiene derecho a acceder a esta, se chequea que tipo de acceso se tiene y en caso de no poseerlo no se hace nada.

EJERCICIO 2 

Lo que se me ocurre que nose si voy a llegar a implementar bien para uint32_t uso_de_memoria_de_las_parejas(); es agregar a mi struct de parejas dos atributo mas consumo que sea que si pareja accedio a memoria compartida cuanto de esta escribio/leyo, sumando cuando se mapea y restando en caso de que se desmapee esta memoria compartida. Con esto lo que podria hacer para el periodo dado es fijarme que parejas estan habilitadas y de estas ir sumando estos consumos, con este chequeo de que esten habilitadas estoy teniendo en cuenta tanto las parejas que siguen en parejas como las parejas que solo tienen a su lider porque yo habilito a la pareja al momento de crearla y la deshabilito al momento que se van ambos de esta.
Las modificaciones que me quedarian por hacer son:
- sumar atributo a mi struct
- en abandonar pareja restarle a mi atributo consumo todo lo que este liberando 
- en page_fault_habndler deberia sumar a consumo cada vez que mapeo y cuanto
- en juntarse_con cuando creo la pareja voy a tener que habilitarla
- hacer uso_de_memoria_de_las_parejas vaya recorriendo mi array parejas y que si la pareja esta habilitada sume en una variable de tipo uint32_t todos los consumos de las tareas habilitadas y devuelva este resultado 


uint32_t uso_de_memoria_de_las_parejas(){
    uint32_t usado = 0;
    for (uint8_t i = 0 ; i <= MAX_PAREJAS; i++){
        if (parejas[i].habilitada == 1){
            usado += parejas[i].consumo;
        }
    }
    return usado;
}

camb