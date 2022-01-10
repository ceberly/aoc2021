#include <assert.h>

#include <stdio.h>
#include <stdlib.h>

#include "../types.h"

extern void heap_sort(Uint16Array *input);
extern int jingle(Uint16Array *input);
extern int jingle2(Uint16Array *input);

int main(void) {
  FILE *file = fopen("input.txt", "r"); 
  assert(file != NULL);

  assert(fseek(file, 0L, SEEK_END) == 0);
  int size = ftell(file);
  assert(size > 0);
  assert(fseek(file, 0L, SEEK_SET) == 0);

  char *contents = malloc(size * sizeof(char));
  assert(contents != NULL);

  size_t n = fread(contents, sizeof(char), size, file);
  assert(n == size);

  String *s = new_string(contents);
  assert(s->len == size);

  fprintf(stderr, "parsing input length %lu...\n", s->len);
  Uint16Array *input = unsigned_16bit_split(s, ',');
  assert(input != NULL);

  fprintf(stderr, "found %lu uint16_t items...\n", input->len);

  heap_sort(input);

  int output = jingle(input);
  int output2 = jingle2(input);
  printf("output: %d\n", output);
  printf("output2: %d\n", output2);

  uint16_array_free(input);
  string_free(s);
  free(contents);
  fclose(file);
  return EXIT_SUCCESS;
}
