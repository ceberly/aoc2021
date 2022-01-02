#pragma once

#include <stddef.h>

#include "string.h"

typedef struct {
  uint16_t *v;
  size_t size;
} Uint16Array;

const char COMMA = ',';

Uint16Array *uint16_with_commas(const char *c, size_t n) {

  Uint16Array *r = malloc(sizeof(Uint16Array));
  if (r == NULL) return NULL;

  r->v = NULL;
  r->size = 0;

  uint16_t *v = malloc(sizeof(uint16_t) * n);
  if (v == NULL) return NULL;

  size_t count = 0;
  //char buf[] = "00000"; // max 65535
  size_t buf_pos = 4;
  //const char *pc = c;

  while (1) {
    // no way to indicate what the error is here?
    if (buf_pos < 5) return NULL;
    if (count == n) break;
    count += 1;
  }

  r->v = v;
  r->size = count;

  return r;
}
