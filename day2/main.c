#include <assert.h>

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <stdint.h>

typedef struct {
  uint8_t *steps;
  char **directions;
  size_t line_count;
} Lines;

extern int jingle_imp(const Lines *lines);
extern int jingle_imp2(const Lines *lines);

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

  uint8_t *steps = (uint8_t *)malloc(line_count * sizeof(uint8_t));
  assert(steps != NULL);

  char **directions = (char **)malloc(line_count * sizeof(char *));
  assert(directions != NULL);
  for (size_t i = 0; i < line_count; i++) {
    // save space for the largest value
    directions[i] = (char *)malloc(8 * sizeof(char));
  }

  rewind(f);
  for (size_t i = 0; i < line_count; i++) {
    assert(fscanf(f, "%s %hhu\n", directions[i], &steps[i]) == 2);
  }

  Lines n = { steps, directions, line_count };

  assert(fclose(f) != -1);

  return n;
}

int main(void) {
  Lines input = get_input();

  int output = jingle_imp(&input);
  int output2 = jingle_imp2(&input);
  printf("output: %d\n", output);
  printf("output2: %d\n", output2);

  return EXIT_SUCCESS;
}
