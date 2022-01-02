#include <stdlib.h>
#include <stdio.h>

#include <string.h>

#include "cde_string.h"

int string_main(void) {
  String *s = new_string("from char");

  if (s == NULL) {
    fprintf(stderr, "string is null\n");
    return EXIT_FAILURE;
  }
  
  if (s->len != 9) {
    fprintf(stderr, "expected len = 9, got %lu instead.\n", s->len);
    return EXIT_FAILURE;
  }

  if (strncmp(s->s, "from char", s->len) != 0) {
    fprintf(stderr, "expected strings to be the same, got %s instead.\n",
        s->s);
    return EXIT_FAILURE;
  }

  string_free(s);

  return EXIT_SUCCESS;
}
