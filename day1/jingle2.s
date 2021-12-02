// https://adventofcode.com/2021/day/1
// Part 2

// create a rolling 3 event sum, if its larger than the previous
// 3 event sum, increase the count.
.global jingle_p2
jingle_p2:
  // x0: input array of 16 bit unsigned shorts
  // x1: input count
  // x7: end of input array = x0 + (x1 * 2)
  add x7, x0, x1, LSL 1

  // collect and sum the first 3 elements
  ldrh w2, [x0], #2
  ldrh w3, [x0], #2
  ldrh w4, [x0]
  add w2, w2, w3
  add w2, w2, w4

  // point x0 to the n + 1 element
  add x0, x0, #-2

  // x6: accumulate the count of "hits"
  mov x6, #0

loop:
  // check if there's 3 more elements.
  // x7 is the address of 1 past the end of the array.
  // we need x0 + (3 * sizeof(16bits)) to be less than or equal to x7
  add x9, x0, #6
  cmp x9, x7
  bgt done

  // load the next sum into w3
  ldrh w3, [x0], #2
  ldrh w4, [x0], #2
  ldrh w5, [x0]
  add w3, w3, w4
  add w3, w3, w5

  // compare current to previous, count "hit" if greater than
  cmp w3, w2
  ble continue
  add x6, x6, #1

continue:
  // make the current input the previous and set the input pointer
  mov w2, w3
  add x0, x0, #-2
  b loop

done:
  mov x0, x6
  ret
