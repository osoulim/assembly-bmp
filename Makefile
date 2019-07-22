
DEBUG = -DDEBUG
CC = gcc
FLAGS = $(DEBUG) -O2 -Wall -m32 -g -march=k8

default:
	nasm -f elf brightness_sse.asm
	nasm -f elf brightness.asm
	$(CC) -c bitmap.c $(FLAGS)
	$(CC) -o bitmap bitmap.o brightness_sse.o brightness.o $(FLAGS)
	
clean:
	@if [ -e bitmap.o ]; then rm bitmap.o; fi;
	@if [ -e bitmap ]; then rm bitmap; fi;
	@if [ -e brightness.o ]; then rm brightness.o; fi;
	@if [ -e brightness_sse.o ]; then rm brightness_sse.o; fi;
	@echo "Clean!"


