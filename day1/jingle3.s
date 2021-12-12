// https://adventofcode.com/2021/day/1
// Part 1

// this version is from @stephentyrone via:
// https://twitter.com/stephentyrone/status/1466865096739725330
//
// I have changed some of the registers used for addresses
// to match what the c driver does. I also use 16 bit ints intead of 32...

.global jingle_simd_steve

jingle_simd_steve:
  // input is a pointer to unsigned short int (16 bit) array
  // ie if the input (in hex!!!) is:
  // [1234, 5678, 9012, 3456, 7890, 1234, 5678, 9012]

  // in memory (little endian) this goes:
  // 34  12  78  56  12  90  56  34  90  78  34  12  78  56  12  90
  // ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
  // b0  b1  b2  b3  b4  b5  b6  b7  b8  b9  b10 b11 b12 b13 b14 b15
 
   // pointer to the end of measurements
  // x9 = x0 + (x1 * 2) 
  add x9, x0, x1, LSL #1

  // accumulate the number of times the measurement increases in v4
  eor v4.16b, v4.16b, v4.16b
 
  // x0: address of elements
  // x1: element count

  // load first 32 bytes (16 measurements) into q0
  //ldp q0, q1, [x0], #32
  ldr q0, [x0], #16

loop:
  // load the next 32 bytes (16 measurements) into q1
  ldr q1, [x0], #16

  // at this point q0 looks like this if the input was as above
  // q0:   90 12 56 78 12 34 78 90 34 90 56 12 56 78 12 34
  //       ^     ^     ^     ^     ^     ^     ^     ^
  // meas. 7     6     5     4     3     2     1     0
  // byte: 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
  // 
  // q1 has the next set of measurements laid out the same way

  // extract pulls the first 2 bytes from the right of v0 (q0)
  // and puts them in the highest bytes of v2. Then the 14 bytes
  // from the left of v1 (q1) into the remaining bytes of v2.
  // 
  // assume q1 looks like this (same deal as above):
  // q1:   FF EE DD CC BB AA 99 88 77 66 55 44 33 22 11 00
  //       ^     ^     ^     ^     ^     ^     ^     ^
  // meas. 7     6     5     4     3     2     1     0
  // byte: 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
  //
  // after this instruction the new vector v2 (q2) looks like this:
  // v2:   11 00 90 12 56 78 12 34 78 90 34 90 56 12 56 78
  //       ^     ^     ^     ^     ^     ^     ^     ^
  // meas. 7     6     5     4     3     2     1     0
  // byte: 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
  ext v2.16b, v0.16b, v1.16b, #2

  // basically we've slid q0 by 2 bytes (1 measurement) so now it's
  // straightforward to compare the two to get next - previous like we need.
  //
  // We actually do a compare higher operation with a neat trick.
  // `cmhi` will put all 1 bits in the place of whichever element is higher,
  // and zero in the bits of whichever is lower:
  // qX: 11 22 33 44
  // qY: 00 33 00 55
  // ---------------
  // qD: FF 00 FF 00
  cmhi v3.8h, v2.8h, v0.8h

  // Seemingly useless until we remember that FF is -1 as a signed integer.
  // So we can now magically *increment* a count-of-higher-items
  // by signed *subtracting* 00 or FF, ie C minus -1 = C plus 1!
  sub v4.8h, v4.8h, v3.8h // counters - new counts (increments the counters)

  // make the current next set up measurements the new previous
  mov v0.16b, v1.16b

  // loop if we're not past the end of measurements (x9)
  subs x10, x9, x0
  bhi loop

  // deal with leftover elements
  // see steve's post for a nicer way to do this,
  // but since we have a number of elements divisible by 8 measurements
  // we can just do the last set like before. TODO: do the real one.
  ext v2.16b, v0.16b, v1.16b, #2
  cmhi v3.8h, v2.8h, v0.8h
  sub v4.8h, v4.8h, v3.8h

  // sum accumulators and return total.
  addv h0, v4.8h
  umov w0, v0.8h[0]

  ret
