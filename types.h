#pragma once

#include <assert.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#define MAX_STRING_BYTES 1048576 // 1 MB
#define MAX_UINT16 65535


// A Go-like slice that can (only) be appended to.
typedef struct {
  uint16_t *a;
  size_t len;
  size_t capacity;
} Uint16Array;

Uint16Array *new_uint16_array(size_t capacity) {
  Uint16Array *r = malloc(sizeof(Uint16Array));
  assert(r != NULL);

  uint16_t *a = malloc(sizeof(uint16_t) * capacity);
  assert(r != NULL);

  r->a = a;
  r->len = 0;
  r->capacity = capacity;

  return r;
}

uint8_t uint16_array_append(Uint16Array *a, uint16_t v) {
  if (a->len == a->capacity) {
    if (a->capacity == 0) a->capacity = 1;

    // grow
    uint16_t *n = malloc(sizeof(uint16_t) * (a->capacity * 2));
    assert(n != NULL);
    memcpy(n, a->a, a->len * sizeof(uint16_t));
    
    free(a->a);
    a->a = n;
    a->capacity = a->capacity * 2;
  }

  a->a[a->len] = v;
  a->len = a->len + 1;
  return 1;
}

void uint16_array_free(Uint16Array *a) {
  if (a == NULL) return;
  if (a->a == NULL) return;

  free(a->a);
  free(a);
}

typedef struct {
  char *s;
  size_t len;
} String;

// Copies the memory from input into a sanity-preserving type.
// Conveniently fails silently on a string >= 1MB.
String *new_string(const char *c) {
  size_t len = strnlen(c, MAX_STRING_BYTES); 
  if (len == MAX_STRING_BYTES) return NULL;

  char *p = strndup(c, len);
  if (p == NULL) return NULL;

  String *r = malloc(sizeof(String));
  if (r == NULL) return NULL;

  r->s = p;
  r->len = len;

  return r;
}

Uint16Array *unsigned_16bit_split(const String *s, char sep) {
  Uint16Array *r = new_uint16_array(1024); // cool default.
  assert(r != NULL);

  size_t spos = 0;
  size_t end = s->len;

  uint8_t buflen = 0;
  uint8_t buf[5] = {0};

  while(spos < end) {
    char c = s->s[spos];
    if (c == sep) {
      if (buflen == 0) goto bad_parse;
      unsigned int digits_place = 1;
      uint16_t val = 0;
      for (size_t i = buflen - 1; i < buflen; i--) {
        //XXX: check for overflow. i believe the Is Parallel Programming Hard
        // book has an example of how to do this safely.
        val += (buf[i] * digits_place);
        digits_place *= 10; 
      }

      assert(uint16_array_append(r, val) == 1);

      buflen = 0;
      goto next;
    }

    uint8_t digit = c - '0';
    if (digit >= 10) goto bad_parse;
    buf[buflen++] = digit;

next:
    spos += 1;
  }
  
  // should end on a number without a separator following it.
  if (buflen == 0) goto bad_parse;
  unsigned int digits_place = 1;
  uint16_t val = 0;
  for (size_t i = buflen - 1; i < buflen; i--) {
    //XXX: check for overflow. i believe the Is Parallel Programming Hard
    // book has an example of how to do this safely.
    val += (buf[i] * digits_place);
    digits_place *= 10; 
  }

  assert(uint16_array_append(r, val) == 1);

  return r;

bad_parse:
  fprintf(stderr, "parse failed on bad input.\n");
  uint16_array_free(r);
  return NULL;
}

void string_free(String *s) {
  if (s == NULL) return;
  if (s->s == NULL) return;

  free(s->s);
  free(s);
}
