
CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = punteros

all: $(TARGET)

$(TARGET): punteros.o
	$(CC) $(CFLAGS) $^ -o $@

punteros.o: punteros.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm *.o $(TARGET)
.PHONY: all clean