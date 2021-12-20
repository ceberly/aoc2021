.global jingle

jingle:
  // Input looks like this, each member is 8 bytes.
  // 
  // typedef struct Input {
  //   uint8_t *draw_numbers;
  //   size_t draw_number_count;
  //   uint8_t *game_numbers;
  //   size_t game_number_count;
  // } Input;

  // x1: address of draw_numbers
  // x2: draw_number_count
  // x3: address of board numbers
  // x4: board number count
  // x5: address of end of draw numbers
  ldr x1, [x0], #8
  ldr x2, [x0], #8
  ldr x3, [x0], #8
  ldr x4, [x0]
  add x5, x1, x2

  // x2: number of numbers per game
  mov x2, #25
  // x6: game count = game number count / numbers per game
  udiv x6, x4, x2

  // Allocate space on the stack for the game bitmaps.
  // Each game needs 4 bytes to get all 25 bits (board numbers).
  // total games * 4
  mov x6, x6, lsl #2

  // Every power of 2 > 16 is divisible by 16, we have 100 games so cheat
  // and round up to a number we can use for the stack subtraction.
  // Bit twiddling: https://graphics.stanford.edu/~seander/bithacks.html#RoundUpPowerOf2
  sub w6, w6, #1
  orr w6, w6, w6, lsr #1
  orr w6, w6, w6, lsr #2
  orr w6, w6, w6, lsr #4
  orr w6, w6, w6, lsr #8
  orr w6, w6, w6, lsr #16
  add w6, w6, #1

  // allocate space on the stack
  sub sp, sp, w6
  
  // stash the stack size so we can restore before ret
  sub sp, sp, #4
  str w6, [sp], #4

  // zero the stack bytes so we don't have to revist memory in the main loop.
  mov w10, #0
clear:
  // zero the 32bits of the game bitmap.
  strb w10, [sp, x6]
  subs x6, x6, #1
  bge clear

  // game number is floor(board number index / 25)
  // known divisor trick: https://stackoverflow.com/questions/4361979/how-does-the-gcc-implementation-of-modulo-work-and-why-does-it-not-use-the
  // magic number: https://godbolt.org/z/bzM3rseWb
  // put the 1/25 value in w9 so we can just multiply and right shift
  // in the loop.
  mov w6, 0x851F
  movk w6, 0x51eb, lsl #16
  
  // At this point the registers we need to save look like this:
  // x1: address of draw numbers
  // x2: constant 25
  // x3: address of board numbers
  // x4: board number count
  // x5: address of end of draw numbers
  // x6: magic division by 25

draw:
  // x7: reset current board address to start of board addresses
  mov x7, x3

  // need to preserve w8 throughout the whole search loop!
  // load draw number
  ldrb w8, [x1], #1
search:
  // load next board number
  ldrb w9, [x7]
  // compare with the draw number
  cmp w8, w9
  bne next_search

  // Hit!
  // index = address of current board number - address of start of boards
  // XXX: if you use a different register after this you don't have
  // to subtract at the end again.
  sub x12, x7, x3

  // what game number are we on?
  // floor(index / total games).
  // found by finishing the division operation from above.
  // x9 = w12 * (1/25 ** 35)
  umull x9, w12, w6
  // x9 = index * 1/25
  lsr x9, x9, #35

  // bit number within game is the remainder (modulus)
  // of the previous division.
  // x12 = index - (game_number * 25)
  msub w12, w9, w2, w12

  // set the hit bit to 1
  // game number * 4
  mov x9, x9, lsl #2
  // 32 bit (4 byte number) for the game
  ldr w10, [sp, x9]

  // set the hit bit within the game word.
  mov w11, #1
  lsl w12, w11, w12
  orr w10, w10, w12

  // store the game word back for next time.
  str w10, [sp, x9]

  // row winners
  //
  // v high                         v low
  // 00000000 00000000 00000000 00011111   // 0x1f
  // 00000000 00000000 00000011 11100000   // 0x3e0
  // 00000000 00000000 01111100 00000000   // 0x7c00
  // 00000000 00001111 10000000 00000000   // 0xf8000
  // 00000001 11110000 00000000 00000000   // 0x1F00000
  //
  //
  // column winners
  //
  // v high                         v low  
  // 00000000 00010000 10000100 00100001   // 0x108421
  // 00000000 00100001 00001000 01000010   // 0x210842
  // 00000000 01000010 00010000 10000100   // 0x421084
  // 00000000 10000100 00100001 00001000   // 0x842108
  // 00000001 00001000 01000010 00010000   // 0x1084210
  //

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
  // advance to the right place.
  // address of current game number - address of start of game numbers
  // XXX this needs to end at 99 not 100
  add x7, x7, #1
  sub x13, x7, x3
  cmp x13, x4
  beq next_draw

  b search

next_draw:
  // if there's no bingo, this will loop infinitely. A fitting punishment.
  // (actually it will simply segfault)
  b draw

bingo:
  // at this point, the game number * 4 is in w9.
  // We need that address for the bit field and also
  // the address / 4 for the game numbers.
  mov x1, x9, lsr #2

  // the final answer is the sum of the unmarked numbers 
  // multiplied by the last draw number used (w8).

  // point to correct game board numbers
  umull x1, w1, w2
  add x3, x3, x1
  // point to end of game numbers
  add x5, x3, x2

  // accumulate sum
  eor w11, w11, w11
  // load bits for the winning game
  ldr w4, [sp, x9]
  // rotate mask
  mov w6, #0x80000000
sum:
  ldrb w10, [x3], #1
  // shift game bits to the right, check if the rotated bit was a 1
  // or a 0, and then add the opposite (unmarked numbers get added).
  ror w4, w4, #1
  // if the bit was set, don't accumulate
  ands wzr, w6, w4
  bne continue

  // do accumulate.
  add w11, w11, w10

continue:
  subs xzr, x3, x5
  bne sum

  // multiply accumulated sum by final number
  umull x0, w11, w8

  // pop the size we need to restore the stack.
  ldr w1, [sp, #-4]
  add sp, sp, w1

  ret
