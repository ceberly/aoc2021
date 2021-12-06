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
jingle_imp:
  // x1: is the beginning of the deferenced input struct.
  // This is also the address of the first element of binary_digits
  ldr x1, [x0], #8 // pointer is 8 bytes 

  // x3: line count
  ldr x3, [x0]

  // given a list of string representations of 12 bit binary digits,
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

//  // x4: half of line count
//  mov x4, x3, LSR #1

// index for loop 
eor x9, x9, x9

// See notes.txt for an explanation of this loop...
// first pack a vector full of ascii "1"
movi v4.16b, #49

// set up two half word vectors to hold our bit position counters
movi v10.8h, #0
movi v11.8h, #0

loop:
  // x1 points to the start of our blob of input.
  // We load 3 registers each with 16 bytes.
  ld1 { v0.16b, v1.16b, v2.16b }, [x1], #48

  // compare and set "1"'s to 255 and "0"'s to 0
  cmeq v0.16b, v0.16b, v4.16b
  cmeq v1.16b, v1.16b, v4.16b
  cmeq v2.16b, v2.16b, v4.16b
  
done:
  umov w0, v0.16b[1]
  ret
