#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "list.h"



list_t* listNew(type_t t) {
    list_t* l = malloc(sizeof(list_t));
    l->type = t; // l->type es equivalente a (*l).type
    l->size = 0;
    l->first = NULL;
    return l;
}

void listAddFirst(list_t* l, void* data) {
    node_t* n = malloc(sizeof(node_t));
    switch(l->type) {
        case TypeFAT32:
            n->data = (void*) copy_fat32((fat32_t*) data);
            break;
        case TypeEXT4:
            n->data = (void*) copy_ext4((ext4_t*) data);
            break;
        case TypeNTFS:
            n->data = (void*) copy_ntfs((ntfs_t*) data);
            break;
    }
    n->next = l->first;
    l->first = n;
    l->size++;
}

void* listGet(list_t* l, uint8_t i){
    node_t* n = l->first;
    for(uint8_t j = 0; j < i; j++)
    n = n->next;
    return n->data;
    }

//se asume: i < l->size
void* listRemove(list_t* l, uint8_t i){
    node_t* tmp = NULL;
    void* data = NULL;
    if(i == 0){
        data = l->first->data;
        tmp = l->first;
        l->first = l->first->next;
    }else{
    node_t* n = l->first;
    for(uint8_t j = 0; j < i - 1; j++)
        n = n->next;
    data = n->next->data;
    tmp = n->next;
    n->next = n->next->next;
    }
    free(tmp);
    l->size--;
    return data;
}

void listDelete(list_t* l){
    node_t* n = l->first;
    while(n){
        node_t* tmp = n;
    n = n->next;
    switch(l->type) {
        case TypeFAT32:
            rm_fat32((fat32_t*) tmp->data);
            break;
        case TypeEXT4:
            rm_ext4((ext4_t*) tmp->data);
            break;
        case TypeNTFS:
        rm_ntfs((ntfs_t*) tmp->data);
        break;
    }
    free(tmp);
    }
    free(l);
}

void listSwapNodes(list_t* l, uint8_t i, uint8_t j) {
    if (!l || i >= l->size || j >= l->size || i == j || l->size < 2)
        return;
    // si no hay nada o hay solo uno mo hago nada

    node_t* n1 = l->first;
    node_t* n2 = l->first;
    for (uint8_t k = 0; k < i; k++) 
        n1 = n1->next;
    for (uint8_t k = 0; k < j; k++) 
        n2 = n2->next;

    void* tmp = n1->data;
    n1->data = n2->data;
    n2->data = tmp;
} 
