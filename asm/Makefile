FLAG = as --32
FLAG_2 = ld -m elf_i386
FLAG_3 = gcc

all: bin/asm_main

bin/asm_main: obj/asm_main.o
	$(FLAG_2) -o bin/asm_main obj/asm_main.o

obj/asm_main.o:
	$(FLAG_3) src/main.c -o obj/c_main.o
	$(FLAG) -o obj/asm_main.o src/main.s src/system_calls.s

clean:
	rm -rf obj/asm_main.o obj/c_main.o bin/asm_main