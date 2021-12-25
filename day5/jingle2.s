.global jingle2

//typedef struct Input {
//  uint16_t packed_pairs[500 * 4];
//  size_t pair_count;
//} Input;

jingle2:
  ldr x1, [x0], #8 // start of packed pairs
  ldr x2, [x0] // pair count


  eor x4, x4, x4 // max x
  eor x5, x5, x5 // max y

  mov x3, x2 // preserve number of pairs for later.
rmax:
  ldrh w6, [x1], #2 // x1
  ldrh w7, [x1], #2 // x2
  ldrh w8, [x1], #2 // y1
  ldrh w9, [x1], #2 // y2

ok:
  cmp w6, w4
  csel w4, w6, w4, hi

  cmp w7, w4
  csel w4, w7, w4, hi

  cmp w8, w5
  csel w5, w8, w5, hi

  cmp w9, w5
  csel w5, w9, w5, hi

skip:
  subs w3, w3, #1
  bne rmax

  ////////////////

  // ok now for the actual problem!
  // Create a maxX * maxY amount of space and paint in the lines.
  // With our input, this creates 1M of stack space with rounding up.

  // coordinates start at 0 so we need to add 1.
  add x4, x4, #1
  add x5, x5, #1

  mov x10, x4 // preserve max x
  mul x3, x4, x5

  // Round up to the nearest multiple of 16.
  add x3, x3, #15
  lsr x3, x3, #4 // divide by 16
  lsl x3, x3, #4 // multiply by 16

  sub sp, sp, x3
  // zero the stack space
  mov w4, #0
  mov x5, x3
clear:
  strb w4, [sp, x5]
  subs x5, x5, #1
  bge clear //XXX: is this the right condition ?
  
  // accumulate the number of places the overlap is >= 2
  eor x12, x12, x12

  // reset pointer to start of input
  ldr x1, [x0, #-8]
nextline:
  ldrh w4, [x1], #2 // x1
  ldrh w5, [x1], #2 // x2
  ldrh w6, [x1], #2 // y1
  ldrh w7, [x1], #2 // y2

  subs w4, w4, w5 // signed distance between x1 and x2
  subs w6, w6, w7 // signed distance between y1 and y2

  // for Part 2, we need two increments, one for x and one for y
  mov w8, #1 // x increment amount.
  mov w9, #1 // y increment amount.

  cmp w4, #0
  cneg w8, w8, gt

  cmp w6, #0
  cneg w9, w9, gt

paint:
  add w11, w5, w4 // paint x coordinate
  add w13, w7, w6 // paint y coordinate

  mov w0, w13
  ret

  // memory location (in the stack) of this "pixel" is: y * max x + x
  madd x9, x13, x10, x11

  // we can use x6 register here because we'll never do the veritcal line now.
  ldrb w11, [sp, x9]
  cmp w11, #2
  beq skipwrite

  add w11, w11, #1
  strb w11, [sp, x9]
  cmp w11, #2 // increment the total overlap counter if we need to.
  cinc w12, w12, eq

skipwrite:
  add w4, w4, w8
  add w6, w6, w9
  cmp w4, w8 // the end, 0 distance + inc, will be 1 or -1
  bne paint

continue:
  subs w2, w2, #1
  bne nextline

  mov x0, x12

  add sp, sp, x3
  ret
