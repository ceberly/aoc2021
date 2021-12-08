#include <assert.h>

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>


extern int jingle_imp(unsigned short *input, int line_count);
extern int jingle_simd(unsigned short *input, int line_count);
extern int jingle_simd_steve(unsigned short *input, int line_count);

extern int jingle_p2(unsigned short *input, int line_count);

int get_input(unsigned short **input) {
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

  *input = (unsigned short *)malloc(line_count * sizeof(unsigned short));
  assert(input != NULL);

  rewind(f);
  for (size_t i = 0; i < line_count; i++) {
    unsigned short reading = 0;
    assert(fscanf(f, "%hu\n", &reading) == 1);
    (*input)[i] = reading;
  }

  assert(fclose(f) != -1);

  return line_count;
}

int main(void) {
  unsigned short *input = NULL;

  int line_count = get_input(&input);

  int output1 = jingle_imp(input, line_count);
  int output2 = jingle_simd(input, line_count);
  int output3 = jingle_simd_steve(input, line_count);

  int part2_output = jingle_p2(input, line_count);

  free(input);

  printf("output imperative: %d output simd: %d output steve: %x\n",
      output1, output2, output3);

  printf("part 2 output: %d\n", part2_output);

  return EXIT_SUCCESS;
}
