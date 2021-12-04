default:
	aarch64-linux-gnu-gcc -static -std=c99 -pedantic -Wall -Werror -march=armv8.4-a -g main.c jingle.s jingle2.s
	qemu-aarch64 a.out
