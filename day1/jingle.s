// https://adventofcode.com/2021/day/1

// Count the number of times an input is larger than the previous input.
// (imperative version).
.global jingle_imp
jingle_imp:
  // end of array = x0 + (w1 * 4)
  // do we need to clear the upper bits of x1, if we're passing
  // in a 32 bit int (w1) ??
  add x7, x0, x1, LSL 2

  // accumulate increase count in w6
  mov x6, #0

  // start at input[1] rather than input[0]
  add x0, x0, #4
while:
  // load input[i]
  ldr w5, [x0], #4

  // load input[i - 1]
  ldr w4, [x0, #-8] // -8 because we've added #4 in the post step above

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

.global jingle_simd
jingle_simd:
  mov w0, #-1

  ret
