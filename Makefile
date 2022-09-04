# AVR cross-compiler toolchain is used here
CC = avr-gcc
OBJCOPY = avr-objcopy
DUDE = avrdude

CFLAGS = -Wall -Os -Iusbdrv -mmcu=attiny20
OBJFLAGS = -j .text -j .data -O ihex
DUDEFLAGS = -v -pattiny20 -carduino -P/dev/ttyACM0 -b19200

# Object files for the firmware (usbdrv/oddebug.o not strictly needed I think)
OBJECTS = main.o

fall: fuse flash

fuse:
	$(DUDE) $(DUDEFLAGS) -U lfuse:w:0xe1:m -U hfuse:w:0xdd:m

# With this, you can flash the firmware by just typing "make flash" on command-line
flash: main.hex
	$(DUDE) $(DUDEFLAGS) -U flash:w:$<

# Housekeeping
clean:
	$(RM) *.o *.hex *.elf usbdrv/*.o

# From .elf file to .hex
%.hex: %.elf
	$(OBJCOPY) $(OBJFLAGS) $< $@

# Main.elf requires additional objects to the firmware, not just main.o
main.elf: $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) -o $@

# Without this dependance, .o files will not be recompiled if you change the config!
$(OBJECTS): config.h

# From C source to .o object file
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# From assembler source to .o object file
%.o: %.S
	$(CC) $(CFLAGS) -x assembler-with-cpp -c $< -o $@
