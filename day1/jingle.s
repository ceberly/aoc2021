// https://adventofcode.com/2021/day/1
// Part 1

// Count the number of times an input is larger than the previous input.
// (imperative version).
.global jingle_imp
jingle_imp:
  // end of array = x0 + (w1 * 2)
  // do we need to clear the upper bits of x1, if we're passing
  // in a 16 bit int (w1) ??
  add x7, x0, x1, LSL 1

  // accumulate increase count in w6
  mov x6, #0

  // start at input[1] rather than input[0]
  add x0, x0, #2
while:
  // load input[i]
  ldrh w5, [x0], #2

  // load input[i - 1]
  ldrh w4, [x0, #-4] // -4 because we've added #2 in the post step above

  cmp w5, w4
  ble decreasing
  // if not decreasing, add 1 to counter
  add w6, w6, #1

decreasing:
  // compare current input address to the end
  cmp x0, x7
  blt while

  // all done, move our accumulator to the return register
  mov x0, x6

  ret

// Count the number of times an input is larger than the previous input.
// (simd version).
.global jingle_simd
jingle_simd:
  // update iteration count in x1 per
  // https://developer.arm.com/documentation/102159/0400/Load-and-store---leftovers?lang=en
  add x1, x1, #7 // operating on 8 lanes
  lsr x1, x1, #3

  // accumulate the hit count in w4
  mov w4, #0

loop:
  //              n1, n2, n3, n4
  //(cmp higher)  n0, n1, n2, n3
  //              --------------
  //              b0, b1, b2, b3

  // load 8 values at once
  ld1 { v2.8h }, [x0]
  add x0, x0, #2 // shift left one input value
  ld1 { v3.8h }, [x0]
  add x0, x0, #14

  // this puts a value of 65535 (16 1's) in each of v1.h's elements
  cmhi v1.8h, v3.8h, v2.8h

  // after cnt(), each 2 byte sequence will either be 8, 8 or 0, 0
  // the highest sequence is 16 8's in a row so the max
  // value for addv will be 128
  cnt v0.16b, v1.16b
  addv h0, v0.8h

  // accumulate the result.
  // h0 will be 8x the correct count
  umov w2, v0.16b[0]
  lsr w2, w2, #3
  add w4, w4, w2

  subs x1, x1, #1
  bne loop

  mov w0, w4
  ret
