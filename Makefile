.PHONY: test
test: types.h
	gcc -g -pedantic -Wall -Werror -std=c99 test.c -o test -D_POSIX_C_SOURCE=200809L
	./test
