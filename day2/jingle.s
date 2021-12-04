.global jingle_imp

// extern int jingle_imp(const Lines *lines);

// these are all 8 byte objects so the struct is contigious (i hope).
//typedef struct {
//  uint8_t *steps;
//  char **directions;
//  size_t line_count;
//} Lines;

jingle_imp:
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

  // x4: forward count
  // x5: up count
  // x6: down count
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
  ldrb w11, [x1, x9]
  add w6, w6, w11
  b continue

up:
  add w5, w5, w11
  b continue

forward:
  add w4, w4, w11

continue:
  add x9, x9, #1
  b loop

done:
  // x5 = down count - up count
  sub w5, w6, w5
  mul w0, w5, w4

  ret
