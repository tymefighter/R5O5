#include "declarations.h"
#include "functions.h"

// Initialize `n` bytes of data from `dst`
// with `c`
void* memset(void *dst, int c, uint n) {
    char *cdst = (char *) dst;
    int i;
    for(i = 0; i < n; i++){
        cdst[i] = c;
    }
    return dst;
}