CC = gcc
CFLAGS = -std=c11 -O2 -Wall -Wextra -Wpedantic -Werror
LDFLAGS = -static

.PHONY: all run clean

all: sysinfo_aluno

sysinfo_aluno: sysinfo_aluno.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

run: sysinfo_aluno
	./sysinfo_aluno

clean:
	rm -f sysinfo_aluno
