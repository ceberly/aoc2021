.PHONY: test
test: cde_string.h cde_csv.h
	gcc -g -pedantic -Wall -Werror -std=c99 test.c string_test.c csv_test.c -o test -D_POSIX_C_SOURCE=200809L
	./test
