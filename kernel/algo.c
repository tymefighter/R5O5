#include "declarations.h"
#include "functions.h"

// Computes maximum of two uint64 values
uint64 max(uint64 x, uint64 y) {
    if(x > y)
        return x;
    else
        return y;
}

// Compute ceiling of x divided by y
// both values are uint64
uint64 ceilDiv(uint64 x, uint64 y) {
    return (x + y - 1) / y;
}
