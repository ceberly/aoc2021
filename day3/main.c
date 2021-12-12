#include <assert.h>

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <stdint.h>

typedef struct {
  char *binary_numbers; // fixed size strings so we just pack contiguously
  size_t line_count;
} Lines;

extern int jingle_imp(const Lines *lines);

Lines get_input() {
  FILE *f = fopen("input.txt", "rb");
  assert(f != NULL);

  assert(fseek(f, 0, SEEK_END) == 0);

  long int size = ftell(f);
  assert(size != -1L);

  char *fbuf = malloc(size * sizeof(char));
  assert(fbuf != NULL);

  rewind(f);
  assert(fread(fbuf, size, 1, f) == 1);

  size_t line_count = 0;
  for (size_t i = 0; i < size; i++) {
    if (fbuf[i] == '\n') line_count++;
  }

  assert(line_count > 0);

  char *binary_numbers = (char *)malloc(line_count * sizeof(char *) * 12); // contiguously packed
  assert(binary_numbers != NULL);

  rewind(f);
  char b[13] = {0};

  char *p = binary_numbers;
  for (size_t i = 0; i < line_count; i++) {
    assert(fscanf(f, "%s\n", b) == 1);
    memcpy(p, (char *)b, 12);
    p += 12;
  }

  Lines n = { binary_numbers, line_count };

  assert(fclose(f) != -1);

  return n;
}

int main(void) {
  Lines input = get_input();

  unsigned long output = jingle_imp(&input);
  printf("output: 0x%lx\n", output);

  return EXIT_SUCCESS;
}
