#include <assert.h>

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>


typedef struct Input {
  uint8_t *draw_numbers;
  size_t draw_number_count;
  uint8_t *game_numbers;
  size_t game_number_count;
} Input;

extern int jingle(Input *input);
extern int jingle2(Input *input);

int main(void) {
  FILE *file = fopen("input.txt", "r"); 
  assert(file != NULL);

  Input input = { NULL, 0, NULL, 0 };

  {
    char line_buf[1024] = {0};
    fgets(line_buf, sizeof line_buf, file);

    uint8_t draw_numbers[256] = {0};
    size_t draw_number_count = 0;

    char *tok = strtok(line_buf, ",");
    while (tok != NULL) {
      // atoi is ok with the last value having a newline
      // so we don't need rtrim()
      int v = atoi(tok);
      draw_numbers[draw_number_count++] = v;

      tok = strtok(NULL, ",");
    }

    input.draw_numbers = draw_numbers;
    input.draw_number_count = draw_number_count;
  }

  {
    uint8_t game_numbers[4096] = {0};
    size_t game_number_count = 0;

    char line_buf[16] = {0};
    while(fgets(line_buf, sizeof line_buf, file) != NULL) {
      if (line_buf[0] == '\n') continue;

      char *tok = strtok(line_buf, " ");
      while (tok != NULL) {
        int v = atoi(tok);
        game_numbers[game_number_count++] = v; 

        tok = strtok(NULL, " ");
      }
    }

    input.game_numbers = game_numbers;
    input.game_number_count = game_number_count;
  }

  int output = jingle(&input);
  int output2 = jingle2(&input);
  printf("output: %d\n", output);
  printf("output2: %d\n", output2);

  fclose(file);
  return EXIT_SUCCESS;
}
