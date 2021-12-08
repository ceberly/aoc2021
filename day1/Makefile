default:
	aarch64-linux-gnu-gcc -static -pedantic -Wall -Werror -march=armv8.4-a -g main.c jingle.s jingle2.s jingle3.s
	qemu-aarch64 a.out
