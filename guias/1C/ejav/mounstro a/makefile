
CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = mounstr

all: $(TARGET)

$(TARGET): mounstr.o
	$(CC) $(CFLAGS) $^ -o $@

mounstr.o: mounstr.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm *.o $(TARGET)
.PHONY: all clean