
CC = gcc
CFLAGS = -Wall -Wextra -pedantic
TARGET = quiz

all: $(TARGET)

$(TARGET): quiz.o
	$(CC) $(CFLAGS) $^ -o $@

arrays.o: quiz.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm *.o $(TARGET)
.PHONY: all clean