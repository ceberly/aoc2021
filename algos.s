.global heap_sort

// This is basically an asm version of what is in notes.c, follows
// Cormen et al.

// input:
//typedef struct {
//  uint16_t *a;
//  size_t len;
//  size_t capacity;
//} Uint16Array;
heap_sort:
  ldr x1, [x0] // a
  ldr x2, [x0, #8] // len

  cmp x2, #1
  ble end // nothing to do if size is 0 or 1

  // x2 holds the len of the complete (to-be-sorted) array,
  // it is decremented in the outermost loop.
  // start of build_max_heap

  // x0: i
  mov x0, x2, lsr #1 // len >> 1

  // x10 will hold largest, initially it's set to i, which is initially x0
  mov x10, x0
max_heapify:
  mov x11, x10 // save initial largest
  // heap_left (also x4 = i * 2 which we can use in address calculation).
  // You can check this by plugging the whole notes.c part into godbolt...
  mov x3, x10, lsl #1  // heap_left(i)

  // l <= len
  cmp x3, x2 // check left
  bhi check_right

  // The values we need are l * 2 (because 16bits) and i * 2 (because 16bits).
  // i * 2 is already in x4, so we just need l * 2:
  add x7, x1, x3, lsl #1 // l * 2 + base
  ldrh w5, [x7, #-2] // A[l-1]

  add x8, x1, x3 // i * 2 + base because i * 2 is the same as heap_left()
  ldrh w6, [x8, #-2] // A[i-1]

  cmp w5, w6
  csel x10, x3, x10, hi // largest = l or back to original i.

check_right:
  add x3, x3, #1 // heap_right()
  cmp x3, x2
  bhi possibly_swap

  add x7, x1, x3, lsl #1
  ldrh w5, [x7, #-2] // A[r-1]

  add x8, x1, x10, lsl #1
  ldrh w6, [x8, #-2] // A[largest-1]

  cmp w5, w6
  csel x10, x3, x10, hi

possibly_swap:
  // if (largest != i) { ... }
  cmp x10, x11
  beq build_max_heap_break

  // swap ...
  add x9, x1, x11, lsl #1 // A[i]
  add x4, x1, x10, lsl #1 // A[largest]

  ldrh w5, [x9, #-2]
  ldrh w6, [x4, #-2]
  strh w6, [x9, #-2]
  strh w5, [x4, #-2]
  
  // x10 holds new i (largest)
  b max_heapify
  
build_max_heap_break:
  subs x0, x0, #1
  mov x10, x0
  bgt max_heapify

sort_swap:
  subs x2, x2, #1
  beq end

  ldrh w5, [x1] // A[0]
  ldrh w6, [x1, x2, lsl #1] // A[i-1] (already subtracted 1 above).
  strh w6, [x1]
  strh w5, [x1, x2, lsl #1]

  // in order to trick the code above into being max_heapify rather than
  // build_max_heap, we set x0 to 1 on each iteration so it never loops.
  // A better way would be to just bite the bullet and use a function.
  mov x0, #1
  mov x10, #1
  b max_heapify
end:
  ret
