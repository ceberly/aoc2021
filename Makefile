CFLAGS=-g -pedantic -Wall -Werror -std=c99 -D_POSIX_C_SOURCE=200809L

default: algos types

notes: notes.c
	gcc ${CFLAGS} notes.c -o notes
	./notes

algos:
	gcc ${CFLAGS} test_algos.c algos.s -o test_algos
	./test_algos

types:
	gcc ${CFLAGS} test.c -o test
	./test

