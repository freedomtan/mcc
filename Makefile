CC=clang
CFLAGS=-Wall -O2 -g

FRAMEWORKS=-framework Foundation -framework IOKit

TARGETS=mcc

all: ${TARGETS}

mcc: mcc.o
	${CC} -o $@ $< ${FRAMEWORKS} ${LIBS}

clean:
	rm -rf ${TARGETS} *.o
