# Project:     Rubik's Cube (implemented in Prolog)
# Course:      Functional and Logic Programming
# Author:      Lucie Svobodova, xsvobo1x@stud.fit.vutbr.cz 
# Year:        2023/2024
# University:  Brno University of Technology, Faculty of Information Technology
#
# Description: Makefile.

SWIPL = swipl
PLFLAGS = -q -g start -G16g
TARGET = flp23-log
SOURCE = flp23-log.pl

all: $(TARGET)

$(TARGET): $(SOURCE)
	$(SWIPL) $(PLFLAGS) -o $(TARGET) -c $(SOURCE)

clean:
	rm -f $(TARGET)
