#include <stdlib.h>

extern int string_main(void);
extern int csv_main(void);

int main(void) {
  if (string_main() != EXIT_SUCCESS) return EXIT_FAILURE;
  if (csv_main() != EXIT_SUCCESS) return EXIT_FAILURE;

  return EXIT_SUCCESS;
}
