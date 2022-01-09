#include <assert.h>

#include <stdlib.h>
#include <stdio.h>

#include "types.h"

extern void heap_sort(Uint16Array *);

int main(void) {
  Uint16Array *A = new_uint16_array(10);
  uint16_array_append(A, 16);
  uint16_array_append(A, 1);
  uint16_array_append(A, 2);
  uint16_array_append(A, 0);
  uint16_array_append(A, 4);
  uint16_array_append(A, 2);
  uint16_array_append(A, 7);
  uint16_array_append(A, 1);
  uint16_array_append(A, 2);
  uint16_array_append(A, 14);

  heap_sort(A);

  // expected build_max_heap output:
  // before: 16 1 2 0 4 2 7 1 2 14
  //  after: 16 14 7 2 4 2 2 1 0 1
  // expected sort:
  // before: 16 1 2 0 4 2 7 1 2 14
  //
  //  after: 0 1 1 2 2 2 4 7 14 16
  assert(A->a[0] == 0);
  assert(A->a[1] == 1);
  assert(A->a[2] == 1);
  assert(A->a[3] == 2);
  assert(A->a[4] == 2);
  assert(A->a[5] == 2);
  assert(A->a[6] == 4);
  assert(A->a[7] == 7);
  assert(A->a[8] == 14);
  assert(A->a[9] == 16);
}
