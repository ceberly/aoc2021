#include <stdlib.h>
#include <stdio.h>

extern unsigned int poly(unsigned int m, unsigned int n);

int main(void) {
  unsigned int r = poly(0x1, 0x2);

  printf("%u\n", r);

  return EXIT_SUCCESS;
}
