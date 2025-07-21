
CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = arrays

all: $(TARGET)

$(TARGET): arrays.o
	$(CC) $(CFLAGS) $^ -o $@

arrays.o: arrays.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm *.o $(TARGET)
.PHONY: all clean