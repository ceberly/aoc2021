#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>

#include "types.h"

bool test_unsigned_16bit_split(void) {
  const String *s = new_string("1,23,456,7890,65535");

  Uint16Array *r = unsigned_16bit_split(s, ',');

  if (r == NULL) {
    fprintf(stderr, "split failed\n"); return false;
  }

  if (r->len != 5) {
    fprintf(stderr, "expected len 5, got %lu.\n", r->len);
    return false;
  }

  if (r->a[0] != 1) {
    fprintf(stderr, "expected 1, got %u\n.", r->a[0]);
    return false;
  }

  if (r->a[1] != 23) {
    fprintf(stderr, "expected 23, got %u\n.", r->a[1]);
    return false;
  }

  if (r->a[2] != 456) {
    fprintf(stderr, "expected 456, got %u\n.", r->a[2]);
    return false;
  }

  if (r->a[3] != 7890) {
    fprintf(stderr, "expected 7890, got %u\n.", r->a[3]);
    return false;
  }

  if (r->a[4] != 65535) {
    fprintf(stderr, "expected 65535, got %u\n.", r->a[4]);
    return false;
  }

  return true;
}

bool test_string(void) {
  String *s = new_string("from char");

  if (s == NULL) {
    fprintf(stderr, "string is null\n");
    return false;
  }
  
  if (s->len != 9) {
    fprintf(stderr, "expected len = 9, got %lu instead.\n", s->len);
    return false;
  }

  if (strncmp(s->s, "from char", s->len) != 0) {
    fprintf(stderr, "expected strings to be the same, got %s instead.\n",
        s->s);
    return false;
  }

  string_free(s);

  return true;
}

bool test_array_grow(void) {
  Uint16Array *a = new_uint16_array(2);
  uint16_array_append(a, 1);
  uint16_array_append(a, 2);
  uint16_array_append(a, 3);

  if (a->len != 3) {
    fprintf(stderr, "expected len 3, got %lu instead.\n", a->len);
    return false;
  }

  if (a->capacity != 4) {
    fprintf(stderr, "expected capacity 4, got %lu instead.\n", a->capacity);
    return false;
  }

  if (a->a[0] != 1) {
    fprintf(stderr, "expected a[0] == 1, got %u instead.\n", a->a[0]);
    return false;
  }

  if (a->a[1] != 2) {
    fprintf(stderr, "expected a[0] == 2, got %u instead.\n", a->a[1]);
    return false;
  }

  if (a->a[2] != 3) {
    fprintf(stderr, "expected a[0] == 3, got %u instead.\n", a->a[2]);
    return false;
  }

  return true;
}

int main(void) {
  if (!test_unsigned_16bit_split()) {
    fprintf(stderr, "failed.\n");
    return EXIT_FAILURE;
  }

  if (!test_array_grow()) {
    fprintf(stderr, "failed.\n");
    return EXIT_FAILURE;
  }

  if (!test_string()) {
    fprintf(stderr, "failed.\n");
    return EXIT_FAILURE;
  }

  fprintf(stderr, "passed.\n");

  return EXIT_SUCCESS;
}
