#pragma once

#include <string.h>
#include <stdlib.h>

#define MAX_STRING_BYTES 1048576 // 1 MB

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

void string_free(String *s) {
  if (s == NULL) return;
  if (s->s == NULL) return;

  free(s->s);
  free(s);
}
