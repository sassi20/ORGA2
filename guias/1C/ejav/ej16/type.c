#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "type.h"

// news
fat32_t* new_fat32(){
    fat32_t* f = malloc(sizeof(fat32_t));
    return f;
};

ext4_t* new_ext4(){
    ext4_t* e = malloc(sizeof(ext4_t));
    return e;
};

ntfs_t* new_ntfs(){
    ntfs_t* n = malloc(sizeof(ntfs_t));
    return n;
};

// copy
fat32_t* copy_fat32(fat32_t* file){
    fat32_t* copia = malloc(sizeof(fat32_t));
    *copia = file;
    return copia;
};

ext4_t* copy_ext4(ext4_t* file){
    ext4_t* copia = malloc(sizeof(ext4_t));
    *copia = file;
    return copia;    
};
ntfs_t* copy_ntfs(ntfs_t* file){
    ntfs_t* copia = malloc(sizeof(ntfs_t));
    *copia = file;
    return copia;
};

//rem
void rm_fat32(fat32_t* file){
    free(file);
};
void rm_ext4(ext4_t* file){
    free(file);
};
void rm_ntfs(ntfs_t* file){
    free(file);
};