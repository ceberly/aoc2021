#pragma once

#include <assert.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#define MAX_STRING_BYTES 1048576 // 1 MB
#define MAX_UINT16 65535


enum NumberParserState {
  parser_begin,
  parser_did_digit,
  parser_did_separator,
  // didEnd 
};

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
    // grow
    uint16_t *n = malloc(sizeof(uint16_t) * (a->capacity * 2));
    assert(n != NULL);
    memcpy(a->a, n, a->len);
    
    free(a->a);
    a->a = n;
    a->capacity = a->capacity * 2;
  }

  a->a[a->len - 1] = v;
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
  if (s->len == 0) return new_uint16_array(1);

  Uint16Array *r = new_uint16_array(1024); // cool default.
  assert(r != NULL);

  enum NumberParserState state = parser_begin;
  size_t spos = 0;

  size_t end = s->len;
  while(1) {
    if (spos == end) {
      if (state != parser_did_digit) goto bad_parse;
    }

    char c = s->s[spos];  
    if (c == sep) {
      if (state != parser_did_digit) goto bad_parse;
    }

    uint8_t digit = '9' - c;
    if (digit >= 10) goto bad_parse;

    spos += 1;
  }

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
