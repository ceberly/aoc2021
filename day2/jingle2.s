.global jingle_imp2

// extern int jingle_imp(const Lines *lines);

// these are all 8 byte objects so the struct is contigious (i hope).
//typedef struct {
//  uint8_t *steps;
//  char **directions;
//  size_t line_count;
//} Lines;

jingle_imp2:
  // x1: is the beginning of the deferenced input struct.
  // This is also the address of the first element of steps.
  ldr x1, [x0], #8 // pointer is 8 bytes 

  // x2: address of the the first element of directions.
  // remember that these elements are pointers to strings so you
  // could return the first ascii character of the first string eg. by:
  // ldr x2, [x0]
  // ldr x4, [x2]
  // ldrb w0, [x4]
  ldr x2, [x0], #8

  // x3: line count
  ldr x3, [x0]

  // x4: aim
  // x5: depth
  // x6: horizontal
  eor w4, w4, w4
  eor w5, w5, w5
  eor w6, w6, w6

  // index for each
  eor x9, x9, x9
loop:
  // are we at the last line?
  cmp x9, x3
  beq done

  // load step count
  ldrb w11, [x1, x9]

  // options for directions are forward, up, down
  // so we can cheat and only look at the first letter.
  lsl x10, x9, #3 // offset into array is sizeof(pointer) * index
  ldr x7, [x2, x10]
  ldrb w8, [x7]

  cmp w8, #102 // 'f'
  beq forward

  cmp w8, #117 // 'u'
  beq up

  // else down
  add w4, w4, w11
  b continue

up:
  sub w4, w4, w11
  b continue

forward:
  // increase horizontal by w11
  add w6, w6, w11
  // depth = depth + (aim * w11)
  umaddl x5, w4, w11, x5

continue:
  add x9, x9, #1
  b loop

done:
  mul w0, w5, w6

  ret
