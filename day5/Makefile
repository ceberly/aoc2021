# debug:
# 	aarch64-linux-gnu-gdb -q --nh -ex 'file a.out' -ex 'target remote localhost:1234' -ex 'layout split' -ex 'layout regs'

default:
	aarch64-linux-gnu-gcc -static -std=c99 -pedantic -Wall -Werror -march=armv8.4-a -g main.c jingle2.s
	qemu-aarch64 a.out
