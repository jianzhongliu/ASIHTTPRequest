//
//  Security.h
//  xuzhq
//
//  Created by xuzhq on 12-10-18.
//  Copyright (c) 2012年 xuzhq. All rights reserved.
//

#ifndef Htinns_Security_h
#define Htinns_Security_h

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include <string.h>


//-- Base64 ------------------------
void *NewBase64Decode(const char *inputBuffer, size_t length, size_t *outputLength);

char *NewBase64Encode(const void *inputBuffer, size_t length, 
                      bool separateLines, size_t *outputLength);

//-- RC4 ---------------------------
typedef struct rc4_key 
{      
    unsigned char state[256];      
    unsigned char x;      
    unsigned char y; 
} rc4_key; 

void prepare_key(const unsigned char *key_data_ptr,int key_data_len, rc4_key *key); 
void rc4(unsigned char *buffer_ptr,int buffer_len,rc4_key * key); 
//static void swap_byte(unsigned char *a, unsigned char *b);

#endif
