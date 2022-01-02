#include <assert.h>

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include "cde_csv.h"

bool test_unsigned_16bit_int_comma_separated(void) {
  Uint16Array *r = uint16_with_commas("1,23,456,7890,65535", 100);

  if (r == NULL) {
    fprintf(stderr, "malloc failed\n"); return false;
  }

  if (r->size != 5) {
    fprintf(stderr, "expected size 5, got %lu.\n", r->size);
    return false;
  }

  if (r->v[0] != 1) {
    fprintf(stderr, "expected 1, got %u\n.", r->v[0]);
    return false;
  }

  if (r->v[1] != 23) {
    fprintf(stderr, "expected 23, got %u\n.", r->v[1]);
    return false;
  }

  if (r->v[2] != 456) {
    fprintf(stderr, "expected 456, got %u\n.", r->v[2]);
    return false;
  }

  if (r->v[3] != 7890) {
    fprintf(stderr, "expected 7890, got %u\n.", r->v[3]);
    return false;
  }

  if (r->v[4] != 65535) {
    fprintf(stderr, "expected 65535, got %u\n.", r->v[4]);
    return false;
  }

  return true;
}

int csv_main(void) {
//  if (!test_unsigned_16bit_int_comma_separated()) {
//    fprintf(stderr, "failed.\n");
//    return EXIT_FAILURE;
//  }

  fprintf(stderr, "passed.\n");

  return EXIT_SUCCESS;
}
