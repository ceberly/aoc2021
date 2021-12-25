.global jingle

//typedef struct Input {
//  uint16_t packed_pairs[500 * 4];
//  size_t pair_count;
//} Input;

jingle:
  ldr x1, [x0], #8 // start of packed pairs
  ldr x2, [x0] // pair count

  // pairs are 4 numbers, 2 bytes each. (x1, x2, y1, y2)
  // 1 pair = 8 bytes, 2 pairs per vector, 4 vectors at a time = 8 pairs
  mov x3, x2, lsr #3

  // just do the number of pairs for now
  mov x3, x2

  eor x4, x4, x4 // max x
  eor x5, x5, x5 // max y

  // do the complete pairs
  mov x8, x3 // preserve the original count.

  //cmp x3, #0
  //beq rmax
  // skip vectorization for now
  b rmax

max:
//  ld4 { v0.8h, v1.8h, v2.8h, v3.8h }, [x1], #64
//
//  // Per the challenge, we are only interested in pairs where
//  // x1 == x2 OR y1 == y2 (vertical or horizontal lines).
//
//  cmeq v4.8h, v0.8h, v1.8h
//  cmeq v5.8h, v2.8h, v3.8h
//
//  and v0.16b, v0.16b, v4.16b
//  and v1.16b, v1.16b, v4.16b
//  and v2.16b, v2.16b, v5.16b
//  and v3.16b, v3.16b, v5.16b
//
//  umaxp v0.8h, v0.8h, v1.8h // pairwise max of x
//  umaxp v2.8h, v2.8h, v3.8h // pairwise max of y
//
//  umaxv h0, v0.8h // max x
//  umaxv h1, v2.8h // max y
//  umov w6, v0.8h[0]
//  umov w7, v1.8h[0]
//
//  cmp w6, w4
//  csel w4, w6, w4, hi
//  cmp w7, w5
//  csel w5, w7, w5, hi
//
//  subs x8, x8, #1
//  bne max


rmax:
  ldrh w6, [x1], #2 // x1
  ldrh w7, [x1], #2 // x2
  ldrh w8, [x1], #2 // y1
  ldrh w9, [x1], #2 // y2

  // pairs we care about?
  cmp w7, w6
  beq ok

  cmp w8, w9
  beq ok
  
  b skip
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
  mov x14, x5 // preserve max y
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

  // if one or the other are zero we can paint.
  // if both are zero (ie we have a point not a line), we paint.
  // if both are none zero, we don't have a horizontal or vertical line,
  // so we skip.
  ands wzr, w4, w6
  bne continue

  mov w8, #1 // increment amount
paint:
  cmp w6, #0 // y1 = y2, paint horizontal incrementing x's.
  bne vert
  // Basic algorithm:
  // (731, 697, 828, 697)
  // w4 = -97 = x1 - x2
  // w5 = 828 = x2
  // 828 + -97 = PAINT (731, 697)
  // w4 = w4 + 1
  // w4 <= 0 -> keep going
  // 828 + -96 = PAINT (730, 697)
  // w4 = w4 + 1
  // ...
  // (482, 383, 388, 383)
  // w4 = 482 - 388 = 94 = x1 - x2
  // w5 = 388 = x2
  // 388 + 94 = PAINT (482, 383)
  // w4 >= 0 -> keep going
  // w4 = w4 - 1
  // ...

  cmp w4, #0
  cneg w8, w8, gt
horiz:
  add w9, w5, w4 // paint x coordinate
  // w7 is the y coordinate

  // memory location (in the stack) of this "pixel" is: y * max x + x
  madd x9, x7, x10, x9
  // we can use x6 register here because we'll never do the veritcal line now.
  ldrb w6, [sp, x9]
  cmp w6, #2
  beq hskipwrite

  add w6, w6, #1
  strb w6, [sp, x9]
  cmp w6, #2 // increment the total overlap counter if we need to.
  cinc w12, w12, eq

hskipwrite:
  add w4, w4, w8
  cmp w4, w8 // the end, 0 distance + inc, will be 1 or -1
  bne horiz

  b continue

vert:
  // XXX: we rely on branching from the same comparison above.
  // (cmp w6, #0)
  cneg w8, w8, gt
nvert:
  // x1 == x2
  // paint vertical incrementing y's.
  // w7: y2
  add w9, w7, w6 // paint y coordinate
  // w5 is the x coordinate 

  madd x9, x9, x10, x5

  ldrb w4, [sp, x9]
  cmp w4, #2
  beq vskipwrite
  
  add w4, w4, #1
  strb w4, [sp, x9]
  cmp w4, #2
  cinc w12, w12, eq

vskipwrite:
  add w6, w6, w8
  cmp w6, w8
  bne nvert

continue:
  subs w2, w2, #1
  bne nextline

  mov x0, x12

  add sp, sp, x3
  ret
