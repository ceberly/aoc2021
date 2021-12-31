#include <assert.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>


typedef struct Input {
  uint16_t *pos;
  size_t crab_count;
} Input;

extern int jingle(Input *input);

int main(void) {
  FILE *file = fopen("input.txt", "r"); 
  assert(file != NULL);

  Input input = { NULL, 0 };

  // cat input.txt | awk -F, '{print NF}'
  // I'll fix this next year for advent of code in C :)
  input.pos = malloc(1000 * sizeof(uint16_t));
  assert(input.packed_pairs != NULL);

  uint16_t *packed = input.pos;
  size_t crab_count = 0;
  while(1) {
    int x1, y1, x2, y2 = 0;

    int n = fscanf(file, "%d,%d,%d,%d\n", &x1, &y1, &x2, &y2);
    if (n == -1) {
      break;
    }

    // need to have complete input.
    assert(n == 4);

    *packed++ = x1;
    *packed++ = x2;
    *packed++ = y1;
    *packed++ = y2;

    pair_count += 1;
  }

  input.pair_count = pair_count;

  //int output = jingle(&input);
  int output2 = jingle2(&input);
  //printf("output: %d\n", output);
  printf("output2: %d\n", output2);

  fclose(file);
  return EXIT_SUCCESS;
}
