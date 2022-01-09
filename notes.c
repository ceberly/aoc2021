// Misc notes and gut checks.

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <stddef.h>

// Heaps and heapsort (taken from Cormen et al chapter 6).
// All these i's need to be indexed starting at 1 rather than 0 for
// the math to work out. Make sure you subtract 1 when actually
// indexing into the array.
size_t heap_parent(size_t i) {
  return i >> 1;
}

size_t heap_left(size_t i) {
  return i << 1;
}

size_t heap_right(size_t i) {
  return heap_left(i) + 1;
}

void heap_max_heapify(uint16_t *A, size_t len, size_t i) {
  size_t l = heap_left(i);
  size_t r = heap_right(i);

  size_t largest = i;

  if ((l <= len) && (A[l-1] > A[i-1])) largest = l;
  if ((r <= len) && (A[r-1] > A[largest-1])) largest = r;

  if (largest != i) {
    size_t t = A[i-1];
    A[i-1] = A[largest-1];
    A[largest-1] = t;

    heap_max_heapify(A, len, largest);
  }
}

void heap_build_max_heap(uint16_t *A, size_t len) {
  for (size_t i = (len >> 1); i > 0; i--) {
    heap_max_heapify(A, len, i);
  }
}

void heap_sort(uint16_t *A, size_t len) {
  heap_build_max_heap(A, len);

  for (size_t i = len; i > 1; i--) {
    uint16_t t = A[0];
    A[0] = A[i-1];
    A[i-1] = t;

    heap_max_heapify(A, i - 1, 1);
  }
}

int main(void) {
  //uint16_t n[] = {16, 4, 10, 14, 7, 9, 3, 2, 8, 1};
  uint16_t n[] = { 16,1,2,0,4,2,7,1,2,14 };

  printf("before: ");
  for (size_t i = 0; i < sizeof(n) / sizeof(uint16_t); i++) {
    printf("%d ", n[i]);
  }
  printf("\n");

  heap_sort(n, sizeof(n) / sizeof(uint16_t));

  printf("\n after: ");
  for (size_t i = 0; i < sizeof(n) / sizeof(uint16_t); i++) {
    printf("%d ", n[i]);
  }

  printf("\n");

  return EXIT_SUCCESS;
}
