.global jingle2

// Everything is the same as part 1 (jingle.s)
// except we calculate the score for the *last* board to bingo
// instead of the first (let the squid win!). Comments removed for brevity.
jingle2:
  ldr x1, [x0], #8
  ldr x2, [x0], #8
  ldr x3, [x0], #8
  ldr x4, [x0] // x4 is the number of board numbers
  add x5, x1, x2
  mov x2, #25
  udiv x6, x4, x2
  // save the total game count.
  mov x15, x6
  // total number of bingos counter.
  eor x16, x16, x16
  mov x6, x6, lsl #2
  sub w6, w6, #1
  orr w6, w6, w6, lsr #1
  orr w6, w6, w6, lsr #2
  orr w6, w6, w6, lsr #4
  orr w6, w6, w6, lsr #8
  orr w6, w6, w6, lsr #16
  add w6, w6, #1
  sub sp, sp, w6
  sub sp, sp, #4
  str w6, [sp], #4
  mov w10, #0
clear:
  strb w10, [sp, x6]
  subs x6, x6, #1
  bge clear
  mov w6, 0x851F
  movk w6, 0x51eb, lsl #16
draw:
  mov x7, x3
  ldrb w8, [x1], #1
search:
  ldrb w9, [x7]
  cmp w8, w9
  bne next_search
  sub x12, x7, x3
  umull x9, w12, w6
  lsr x9, x9, #35
  msub w12, w9, w2, w12
  mov x9, x9, lsl #2
  ldr w10, [sp, x9]
  mov w11, #1
  lsl w12, w11, w12
  orr w10, w10, w12
  str w10, [sp, x9]
  and w12, w10, #0x1f
  cmp w12, #0x1f
  beq bingo
  and w12, w10, #0x3e0
  cmp w12, #0x3e0
  beq bingo
  mov w11, #0x7c00
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0xf8000
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0x1f00000
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0x8421
  movk w11, #0x10, lsl #16
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0x842
  movk w11, #0x21, lsl #16
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0x1084
  movk w11, #0x42, lsl #16
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0x2108
  movk w11, #0x84, lsl #16
  and w12, w10, w11
  cmp w12, w11
  beq bingo
  mov w11, #0x4210
  movk w11, #0x108, lsl #16
  and w12, w10, w11
  cmp w12, w11
  beq bingo
next_search:
  add x7, x7, #1
  sub x13, x7, x3
  cmp x13, x4
  beq next_draw
  b search
next_draw:
  b draw
bingo:
  // are we on the last possible bingo?
  // (w15: number of boards, w16: how many bingos so far)
  add w16, w16, #1
  subs wzr, w15, w16
  beq winner

  // otherwise remove the bingo'ed board from the game.
  mov x17, x9, lsr #2
  umull x17, w17, w2
  add x17, x3, x17
  add x18, x17, x2
  mov w19, #-1
remove:
  strb w19, [x17], #1
  subs xzr, x18, x17
  bne remove

  b next_search

winner:
  mov x1, x9, lsr #2
  umull x1, w1, w2
  add x3, x3, x1
  add x5, x3, x2
  eor w11, w11, w11
  ldr w4, [sp, x9]
  mov w6, #0x80000000
sum:
  ldrb w10, [x3], #1
  ror w4, w4, #1
  ands wzr, w6, w4
  bne continue
  add w11, w11, w10
continue:
  subs xzr, x3, x5
  bne sum
  umull x0, w11, w8
  ldr w1, [sp, #-4]
  add sp, sp, w1

  ret
