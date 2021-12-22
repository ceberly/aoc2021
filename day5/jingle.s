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

  eor x4, x4, x4 // max x
  eor x5, x5, x5 // max y

  // do the complete pairs
  mov x8, x3 // preserve the original count.
max:
  ld4 { v0.8h, v1.8h, v2.8h, v3.8h }, [x1], #64

  // Per the challenge, we are only interested in pairs where
  // x1 == x2 OR y1 == y2 (vertical or horizontal lines).

  cmeq v4.8h, v0.8h, v1.8h
  cmeq v5.8h, v2.8h, v3.8h

  and v0.16b, v0.16b, v4.16b
  and v1.16b, v1.16b, v4.16b
  and v2.16b, v2.16b, v5.16b
  and v3.16b, v3.16b, v5.16b

  umaxp v0.8h, v0.8h, v1.8h // pairwise max of x
  umaxp v2.8h, v2.8h, v3.8h // pairwise max of y

  umaxv h0, v0.8h // max x
  umaxv h1, v2.8h // max y
  umov w6, v0.8h[0]
  umov w7, v1.8h[0]

  cmp w6, w4
  csel w4, w6, w4, hi
  cmp w7, w5
  csel w5, w7, w5, hi

  subs x8, x8, #1
  bne max

  // x3 is the count of complete 8 pair-at-a-time fills.
  // total bytes remaining = total_pairs * 8 bytes - x3 * 8bytes * 8 pairs
  mov x3, x3, lsl #6
  mov x6, x2, lsl #3
  sub x3, x6, x3

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
  subs w3, w3, #8
  bne rmax

  ////////////////

  // ok now for the actual problem!
  // Create a maxX * maxY amount of space and paint in the lines.
  // With our input, this creates 1M of stack space with rounding up.
  mul x3, x4, x5

  // Round up to the nearest power of 2.
  // The number extent is larger than 16 so we are good.
  // See day 4 for an example.
  sub w3, w3, #1
  orr w3, w3, w3, lsr #1
  orr w3, w3, w3, lsr #2
  orr w3, w3, w3, lsr #4
  orr w3, w3, w3, lsr #8
  orr w3, w3, w3, lsr #16
  add w3, w3, #1

  sub sp, sp, w3
  // zero the stack space
  mov w4, #0
  mov w5, w3
clear:
  strb w4, [sp, x5]
  subs w5, w5, #1
  bge clear //XXX: is this the right condition ?
  
  // reset pointer to start of input
  ldr x1, [x0, #-8]

nextline:
  ldrh w4, [x1], #2 // x1
  ldrh w5, [x1], #2 // x2
  ldrh w6, [x1], #2 // y1
  ldrh w7, [x1], #2 // y2

  subs w2, w2, #1
  bne nextline

  mov w0, w4

  add sp, sp, w3
  ret
