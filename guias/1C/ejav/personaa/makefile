
CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = persona

all: $(TARGET)

$(TARGET): persona.o
	$(CC) $(CFLAGS) $^ -o $@

persona.o: persona.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm *.o $(TARGET)
.PHONY: all clean